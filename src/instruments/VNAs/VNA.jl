module VNA

importall InstrumentControl
using ICCommon
using AxisArrays
import Base: search

export InstrumentVNA
export MarkerSearch

# export Format, Parameter
export clearavg, data, search, shotgun, stimdata, sweeptime
abstract InstrumentVNA  <: Instrument

"""
```
type FrequencySweep <: Response
    ins::InstrumentVNA
    reject::Int
end
```

Your standard frequency sweep using a VNA. `reject` lets you reject a number of
traces to reject before keeping measurements.
"""
type FrequencySweep <: Response
    ins::InstrumentVNA
    reject::Int
end
FrequencySweep(ins::InstrumentVNA) = FrequencySweep(ins, 0)
axisnames(::FrequencySweep) = [:f, :sparameter]
axisscales(x::FrequencySweep) = (stimdata(x.ins), [:S11, :S21])

function measure(x::FrequencySweep)

    old_timeout = x.ins[Timeout]
    old_avgtrig = x.ins[AveragingTrigger]

    x.ins[Timeout] = 10000
    x.ins[NumTraces] = 3
    x.ins[VNA.Graphs] = [1 2; 1 3]
    x.ins[VNA.Format] = :PolarComplex
    x.ins[VNA.Format, 1, 2] = :LogMagnitude
    x.ins[VNA.Format, 1, 3] = :Phase
    x.ins[VNA.Parameter, 1, 2] = :S21
    x.ins[VNA.Parameter, 1, 3] = :S21
    x.ins[VNA.Parameter] = :S21
    x.ins[TriggerSource] = :BusTrigger

    if x.reject > 0
        old_avg = x.ins[Averaging]
        x.ins[Averaging] = false
        for i in 1:x.reject
            trig1(x.ins)
            sleep(sweeptime(x.ins))
            opc(x.ins)
        end
        x.ins[Averaging] = old_avg
    end

    x.ins[Averaging] && (x.ins[AveragingTrigger] = true)

    trig1(x.ins)
    sleep(sweeptime(x.ins))
    opc(x.ins)

    npts = x.ins[NumPoints]
    sparams = [:S11, :S21]
    result = AxisArray(Array{Complex{Float64}}(npts, length(sparams)),
        Axis{:f}(stimdata(x.ins)), Axis{:sparam}(sparams))
    for s in sparams
        x.ins[VNA.Parameter] = s
        result[Axis{:sparam}(s)] = VNA.data(x.ins, :PolarComplex)
    end
    result = transpose(result)

    autoscale(x.ins,1,1)
    autoscale(x.ins,1,2)
    autoscale(x.ins,1,3)

    # respect previous settings
    x.ins[Timeout] = old_timeout
    x.ins[AveragingTrigger] = old_avgtrig

    result
end

"""
Format of returned data. Search for `VNA.Format` in the instrument
template files to find valid options; some examples include `:LogMagnitude`,
`:GroupDelay`, `:PolarComplex`, etc.
"""
abstract Format <: InstrumentProperty

"""
Graph layout on the VNA display. Specify with a matrix of integers.

The following example will have graph 1 occupying the top half of the screen,
graph 2 occupying the lower-left, and graph 3 the lower-right:

```
ins[Graphs] = [1 1; 2 3]
```
"""
abstract Graphs <: InstrumentProperty

"""
Marker state for a given marker (on/off).
"""
abstract Marker <: InstrumentProperty

"""
X-axis value for a given marker.
"""
abstract MarkerX <: InstrumentProperty

"""
Y-axis value for a marker.
"""
abstract MarkerY <: InstrumentProperty

"""
Scattering parameter. For two-port VNAs, you can specify
`:S11`, `:S12`, `:S21`, or `:S22`.

Example:
```
channel, trace = 1, 2
ins[Parameter, channel, trace] = :S21
```
"""
abstract Parameter <: InstrumentProperty

"""
Do a marker search with each trace update (yes/no).
"""
abstract SearchTracking <: InstrumentProperty


"Polarity for peak and dip searching with VNAs."
abstract Polarity

"Positive polarity (a peak)."
immutable Positive <: Polarity end

"Negative polarity (a dip)."
immutable Negative <: Polarity end

"Both polarities (peak or dip)."
immutable Both <: Polarity end

"""
```
immutable MarkerSearch{T}
    ch::Int
    tr::Int
    m::Int
    val::Float64
    pol::Polarity
end
```

Type encapsulating a marker search query. The type parameter should be a
symbol specifying the search type. The available options may depend on
VNA capabilities.

The E5071C supports:

```jl
:Max
:Min
:Peak
:LeftPeak
:RightPeak
:Target
:LeftTarget
:RightTarget
```
"""
immutable MarkerSearch{T}
    ch::Int
    tr::Int
    m::Int
    val::Float64
    pol::Polarity
end

"""
```
MarkerSearch(typ::Symbol, ch, tr, m, val=0.0, pol::Polarity=Both())
```

You are recommended to construct a `MarkerSearch` object using this function,
which makes a suitable one given the type of search you want to do
(specified by `typ::Symbol`), the channel `ch`, trace `tr`, marker number `m`,
value `val` and polarity `pol::Polarity` (`Positive()`, `Negative()`, or `Both()`).
The value will depend on what you're doing but is typically a peak excursion
or transition threshold.
"""
function MarkerSearch(typ::Symbol, ch, tr, m, val=0.0, pol::Polarity=Both())
    typ == :Max && return MarkerSearch{:Global}(ch, tr, m, 0.0, Positive())
    typ == :Min && return MarkerSearch{:Global}(ch, tr, m, 0.0, Negative())
    typ == :Bandwidth && return MarkerSearch{:Bandwidth}(ch, tr, m, val, Both())
    return MarkerSearch{typ}(ch, tr, m, val, pol)
end

"""
```
clearavg(ins::InstrumentVNA, ch::Integer=1)
```

Restart averaging for a given channel `ch` (defaults to 1).
"""
function clearavg(ins::InstrumentVNA, ch::Integer=1)
    write(ins, ":SENS#:AVER:CLE", ch)
end

"""
```
data(ins::InstrumentVNA, fmt::Symbol, ch::Integer=1, tr::Integer=1)
data(ins::InstrumentVNA, ch::Integer=1, tr::Integer=1)
```

Read the trace data from the VNA. If you provide `fmt` (which should be a symbol
suitable for setting the `VNA.Format` property) the data will be returned
in that format.
"""
function data end

data(ins::InstrumentVNA, fmt::Symbol, ch::Integer=1, tr::Integer=1) =
    data(ins, Val{fmt}, ch, tr)

data(ins::InstrumentVNA, ch::Integer=1, tr::Integer=1) =
    data(ins, Val{ins[VNA.Format, ch, tr]}, ch, tr)

"""
```
stimdata(ins::InstrumentVNA, ch::Integer=1)
```

Short for "stimulus data," reads the frequency axis from the VNA.
"""
function stimdata end

"""
```
search(ins::InstrumentVNA, m1::MarkerSearch, m2::MarkerSearch, m3::MarkerSearch...)
```

Execute marker searches defined by any number of `MarkerSearch` objects.
"""
search(ins::InstrumentVNA, m1::MarkerSearch, m2::MarkerSearch, m3::MarkerSearch...) =
    [search(ins, s) for s in [m1, m2, m3...]]

"""
```
shotgun(ins::InstrumentVNA, m::AbstractArray=1:9, ch::Integer=1, tr::Integer=1)
```

Markers with numbers in the range `m` are spread across the frequency span.
The first marker begins at the start frequency but the last marker is
positioned before the stop frequency, such that each marker has the same
frequency span to the right of it within the stimulus window.
"""
function shotgun(ins::InstrumentVNA, m::AbstractArray=1:9,
        ch::Integer=1, tr::Integer=1)
    f1, f2 = (ins[FrequencyStart, ch], ins[FrequencyStop, ch])
    fs = linspace(f1,f2,length(m)+1)
    for marker in 1:length(m)
        ins[Marker,  m[marker], ch, tr] = true
        ins[MarkerX, m[marker], ch, tr] = fs[marker]
    end
end

"""
```
sweeptime(ins::InstrumentVNA)
```

Returns the sweep time for a given VNA, including averaging.
"""
function sweeptime(ins::InstrumentVNA)
    ti = ins[SweepTime]
    ins[Averaging] && ins[AveragingTrigger] && (ti *= ins[AveragingFactor])
    ti
end

"Determines if an error code reflects a peak search failure."
function peaknotfound end

"How to specify a window layout in a command string, given a matrix."
function window end

end
