


Most of the time you will probably want [`VNA.stimdata`](vna.md#InstrumentControl.VNA.stimdata), [`VNA.data`](vna.md#InstrumentControl.VNA.data), and [`VNA.FrequencySweep`](vna.md#InstrumentControl.VNA.FrequencySweep).


<a id='Stimuli-and-responses-1'></a>

## Stimuli and responses

<a id='InstrumentControl.VNA.FrequencySweep' href='#InstrumentControl.VNA.FrequencySweep'>#</a>
**`InstrumentControl.VNA.FrequencySweep`** &mdash; *Type*.



```
type FrequencySweep <: Response
    ins::InstrumentVNA
    reject::Int
end
```

Your standard frequency sweep using a VNA. `reject` lets you reject a number of traces to reject before keeping measurements.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L15-L25' class='documenter-source'>source</a><br>


<a id='Instrument-properties-1'></a>

## Instrument properties

<a id='InstrumentControl.VNA.Format' href='#InstrumentControl.VNA.Format'>#</a>
**`InstrumentControl.VNA.Format`** &mdash; *Type*.



Format of returned data. Search for `VNA.Format` in the instrument template files to find valid options; some examples include `:LogMagnitude`, `:GroupDelay`, `:PolarComplex`, etc.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L87-L91' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.Graphs' href='#InstrumentControl.VNA.Graphs'>#</a>
**`InstrumentControl.VNA.Graphs`** &mdash; *Type*.



Graph layout on the VNA display. Specify with a matrix of integers.

The following example will have graph 1 occupying the top half of the screen, graph 2 occupying the lower-left, and graph 3 the lower-right:

```
ins[Graphs] = [1 1; 2 3]
```


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L94-L103' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.Marker' href='#InstrumentControl.VNA.Marker'>#</a>
**`InstrumentControl.VNA.Marker`** &mdash; *Type*.



Marker state for a given marker (on/off).


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L106-L108' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.MarkerX' href='#InstrumentControl.VNA.MarkerX'>#</a>
**`InstrumentControl.VNA.MarkerX`** &mdash; *Type*.



X-axis value for a given marker.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L111-L113' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.MarkerY' href='#InstrumentControl.VNA.MarkerY'>#</a>
**`InstrumentControl.VNA.MarkerY`** &mdash; *Type*.



Y-axis value for a marker.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L116-L118' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.Parameter' href='#InstrumentControl.VNA.Parameter'>#</a>
**`InstrumentControl.VNA.Parameter`** &mdash; *Type*.



Scattering parameter. For two-port VNAs, you can specify `:S11`, `:S12`, `:S21`, or `:S22`.

Example:

```
channel, trace = 1, 2
ins[Parameter, channel, trace] = :S21
```


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L121-L130' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.SearchTracking' href='#InstrumentControl.VNA.SearchTracking'>#</a>
**`InstrumentControl.VNA.SearchTracking`** &mdash; *Type*.



Do a marker search with each trace update (yes/no).


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L133-L135' class='documenter-source'>source</a><br>


<a id='Methods-1'></a>

## Methods

<a id='InstrumentControl.VNA.clearavg' href='#InstrumentControl.VNA.clearavg'>#</a>
**`InstrumentControl.VNA.clearavg`** &mdash; *Function*.



```
clearavg(ins::InstrumentVNA, ch::Integer=1)
```

Restart averaging for a given channel `ch` (defaults to 1).


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L206-L212' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.data' href='#InstrumentControl.VNA.data'>#</a>
**`InstrumentControl.VNA.data`** &mdash; *Function*.



```
data(ins::InstrumentVNA, fmt::Symbol, ch::Integer=1, tr::Integer=1)
data(ins::InstrumentVNA, ch::Integer=1, tr::Integer=1)
```

Read the trace data from the VNA. If you provide `fmt` (which should be a symbol suitable for setting the `VNA.Format` property) the data will be returned in that format.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L217-L226' class='documenter-source'>source</a><br>

<a id='Base.search-Tuple{InstrumentControl.VNA.InstrumentVNA,InstrumentControl.VNA.MarkerSearch,InstrumentControl.VNA.MarkerSearch,Vararg{InstrumentControl.VNA.MarkerSearch,N}}' href='#Base.search-Tuple{InstrumentControl.VNA.InstrumentVNA,InstrumentControl.VNA.MarkerSearch,InstrumentControl.VNA.MarkerSearch,Vararg{InstrumentControl.VNA.MarkerSearch,N}}'>#</a>
**`Base.search`** &mdash; *Method*.



```
search(ins::InstrumentVNA, m1::MarkerSearch, m2::MarkerSearch, m3::MarkerSearch...)
```

Execute marker searches defined by any number of `MarkerSearch` objects.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L244-L250' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.shotgun' href='#InstrumentControl.VNA.shotgun'>#</a>
**`InstrumentControl.VNA.shotgun`** &mdash; *Function*.



```
shotgun(ins::InstrumentVNA, m::AbstractArray=1:9, ch::Integer=1, tr::Integer=1)
```

Markers with numbers in the range `m` are spread across the frequency span. The first marker begins at the start frequency but the last marker is positioned before the stop frequency, such that each marker has the same frequency span to the right of it within the stimulus window.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L254-L263' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.stimdata' href='#InstrumentControl.VNA.stimdata'>#</a>
**`InstrumentControl.VNA.stimdata`** &mdash; *Function*.



```
stimdata(ins::InstrumentVNA, ch::Integer=1)
```

Short for "stimulus data," reads the frequency axis from the VNA.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L235-L241' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.sweeptime' href='#InstrumentControl.VNA.sweeptime'>#</a>
**`InstrumentControl.VNA.sweeptime`** &mdash; *Function*.



```
sweeptime(ins::InstrumentVNA)
```

Returns the sweep time for a given VNA, including averaging.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L274-L280' class='documenter-source'>source</a><br>


<a id='Miscellaneous-1'></a>

## Miscellaneous

<a id='InstrumentControl.VNA.MarkerSearch' href='#InstrumentControl.VNA.MarkerSearch'>#</a>
**`InstrumentControl.VNA.MarkerSearch`** &mdash; *Type*.



```
immutable MarkerSearch{T}
    ch::Int
    tr::Int
    m::Int
    val::Float64
    pol::Polarity
end
```

Type encapsulating a marker search query. The type parameter should be a symbol specifying the search type. The available options may depend on VNA capabilities.

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


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L151-L178' class='documenter-source'>source</a><br>

<a id='InstrumentControl.VNA.MarkerSearch-Tuple{Symbol,Any,Any,Any}' href='#InstrumentControl.VNA.MarkerSearch-Tuple{Symbol,Any,Any,Any}'>#</a>
**`InstrumentControl.VNA.MarkerSearch`** &mdash; *Method*.



```
MarkerSearch(typ::Symbol, ch, tr, m, val=0.0, pol::Polarity=Both())
```

You are recommended to construct a `MarkerSearch` object using this function, which makes a suitable one given the type of search you want to do (specified by `typ::Symbol`), the channel `ch`, trace `tr`, marker number `m`, value `val` and polarity `pol::Polarity` (`Positive()`, `Negative()`, or `Both()`). The value will depend on what you're doing but is typically a peak excursion or transition threshold.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/38abbfe31015b5a2086f8e03b4cb9848bee446ac/src/instruments/VNAs/VNA.jl#L187-L198' class='documenter-source'>source</a><br>

