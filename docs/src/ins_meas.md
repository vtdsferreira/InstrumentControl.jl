# Interfacing with Instruments and Making Measurements

## What is an instrument?

For the purposes of this package, an instrument is just something connected to the
computer that we need to communicate with, and which can apply some stimulus or measure something.
Every instrument may connect to the computer by different hardware,
comms protocols, and command dialects.

All instruments are Julia objects, subtypes of the abstract type `Instrument`.
The implementation of each subtype (it's fields, constructors, etc) depend
on the specific instrument.

### Keysight

Keysight sells AWG and Digitizer module "cards", each of which can be connected to a PXI
chassis which affords a single connection to the computer, as well as "PXI backplane"
which can be used to synchronize actions of multiple module "cards". All cards are controlled
by C libraries programmed by Keysight. We have wrapped these libraries in the
[KeysightInstruments.jl](https://github.com/PainterQubits/KeysightInstruments.jl) package,
and InstrumentControl relies on this wrapper for instrument configuration/control.

#### VISA

Many instruments are able to be addressed using the
[VISA](http://www.ivifoundation.org/docs/vpp432_2014-06-19.pdf) standard (Virtual
Instrument Software Architecture), currently maintained by the IVI Foundation.

To talk to VISA instruments will require the Julia package [VISA.jl](http://www.github.com/ajkeller34/VISA.jl)
as well as the [National Instruments VISA libraries](https://www.ni.com/visa/).
Installation instructions are available at each link.

#### Alazar digitizers

Digitizers made by [AlazarTech](http://www.alazartech.com) are notably *not*
compatible with the VISA standard. All Alazar digitizers are addressable by an API
supplied by the company, which talks to the card through a shared library (a .dll on
Windows or .so on Linux). `InstrumentAlazar` is an abstract subtype of `Instrument`.

The shared library files and API documentation are only available from AlazarTech.

## How do we configure instruments?

### Properties

Instrument properties are configured and inspected using two functions,
`setindex!` and `getindex`, which are methods from the Base module that have been
overloaded in this package to work with instrument objects. This results in a
convenient and concise syntax ([credit due to Oliver Schulz](https://groups.google.com/d/msg/julia-users/Dt6nbfhtaNQ/81KgQmttCwAJ)
for this idea).

For example:

```julia
awg[TriggerSlope] = :Rising
awg[SampleRate] = 10e6
```

## How do we take measurements?

### Source and measure

Two functions are provided to abstract away many kinds of measurements: `source`
and `measure`. In an experiment you source  some stimulus and measure a response.
Therefore `source` takes as arguments: an instance of some subtype of the
`Stimulus` type (which can have different fields for different subtypes), as well as
the numerical value(s) for the particular stimulus. `measure` takes as
argument an instance of some subtype of type `Response`. The idea is to write
new subtypes of `Stimulus` and `Response` to describe what you are doing, as well
as new methods for `source` and `measure` that know how to communicate with the
instrument(s) based on the Stimuli and Response arguments passed to them

### Stimuli

All stimuli are objects, subtyped from the abstract `Stimulus` type.
Many stimuli, either general or associated with the capabilities of particular instruments,
are already implemented. The implementation of each subtype depends on the specific
goals of the user: demonstrations of different stimuli being used can be found in
the example notebooks.

As a simple example, consider the `PropertyStimulus` type (defined in [ICCommon.jl](https://github.com/PainterQubits/ICCommon.jl)) :

```julia
mutable struct PropertyStimulus{T<:InstrumentProperty} <: Stimulus
    typ::Type{T}
    ins::Instrument    
    tuple::Tuple
    axisname::Symbol
    axislabel::String
end
```
with corresponding source method:

```julia
function source(ch::PropertyStimulus, val)
    ch.ins[ch.typ, ch.tuple...] = val
end
```

Notable among the fields  of `PropertyStimulus` are the `typ` and `ins` fields:
`typ` is the instrument property the stimulus object is associated with, and
`ins` is the instrument which that property corresponds to (Type{T} is a
special kind of abstract type whose only instance is the object T; visit the [docs](https://docs.julialang.org/en/stable/manual/types/#man-singleton-types-1)
for further discussion). `tuple` are essentially "qualifiers" or "infixes" for
the instrument property. For example, if we wanted to change (source) the amplitude
of a waveform in a waveform generator instrument with multiple channels, the
instrument property at hand is `SourceLevel` while `tuple` would specify on *what channel*
we are changing the amplitude.  

Thus, this `Stimulus` object holds all the necessary information for a `source`
method to change the value of instrument property `T` to any value passed to it.
And the corresponding source function in fact does just that: it calls a setindex!
method to change property `T` (with qualifiers `tuple`) on instrument `ins` to
value `val`. Again, stimuli need not be tied to a particular property; rather,
this is just one convenient and easily generalizable example.

For a concrete example on the use of `PropertyStimulus`, consider needing to source
various frequencies in our E8257D signal generator, where the frequency of a signal
generator is an instrument property called `Frequency`. We can accomplish this task
using `PropertyStimulus` in the following way:

```julia
stim = PropertyStimulus(siggen::E8257D, Frequency)
for freq in 1e9:1e8:5e9     # 1 GHz to 5 GHz in steps of 100 MHz
    source(stim, freq)
    # measure(something)
end
```
Easy right?

Note that one may assign whatever fields and constructor one wishes for a newly
created `Stimulus` subtype. Also, note that not all stimuli need to be associated
with a physical instrument. For instance, sourcing a `DelayStimulus` will cause
the script to block until a specified time after creation of the `DelayStimulus`
object. Moreover, a Stimulus could also be associated with several instruments. Maybe a
stimulus that makes sense for a particular experiment would be to change all gate
voltages at once. These gate voltages could of course be sourced by several
physical instruments.

### Responses

All responses are objects, subtyped from the abstract `Response` type.
Usually a response is associated with a particular instrument. The implementation
of each subtype depends on the specific goals of the user: demonstrations of
different response being used can be found in the example notebooks.

As a simple example, consider the following M3102A Digitizer `Response` type:

```julia
mutable struct SingleChStream <: Response
    dig::InsDigitizerM3102A
    ch::Int #ch for channel
    timeout::Float64
end
```

with corresponding `measure` method:

```julia
function measure(resp::SingleChStream)
    dig = resp.dig
    ch = resp.ch
    timeout  = ceil(resp.timeout *10e3) #timeout should be integer in units of milliseconds
    daq_points = Int(ceil((resp.timeout* (500e6)))) #number of samples expected

    dig[DAQTrigMode, ch] = :Auto
    dig[DAQCycles, ch] = -1 #infinite number of cycles
    dig[DAQPointsPerCycle, ch] = daq_points

    @KSerror_handler SD_AIN_DAQstart(dig.ID, ch)
    data = @KSerror_handler SD_AIN_DAQread(dig.ID, ch, daq_points, timeout)
    return data
end
```
This response type would be used for measuring data on the M3102A digitizer, upon
a call to it's corresponding `measure` function, on channel `ch` continuously for
a time equal to the `timeout` field of the digitizer. The measure function properly configures
the digitizer, starts the DAQ for trigger acquisition, and takes data for the computer
through the `SD_AIN_DAQread` function. Thus, to perform this type of data acquisition, one
would merely need to instantiate a `SingleChStream` object with desired digitizer object,
channel, and timeout, and call `measure` with that object as input. Easy right?

It is good to keep in mind responses need not come from instruments. For test purposes, suppose we
want to mimic a measurement by generating random numbers. `RandomResponse` produces a
random number in the unit interval when it is measured. A `TimerResponse` will
measure the time since creation of the `TimerResponse` object.

### Difference between stimuli and instrument properties

Because a stimulus is defined so broadly, the difference between a stimulus
and an instrument property is not obvious. While in many cases there is an overlap
between stimuli and properties, a stimulus is like a generalized
instrument property: sourcing a stimulus may entail configuring zero or more
instrument properties, on zero or more different instruments. As was mentioned
earlier, a useful stimulus could be to change gate voltages on multiple different
instruments all at once.

It is useful to think of a stimulus as something which has a chance to react to
what you are measuring. For example, this could be applied voltage, sourced by
one or more instruments. The applied voltages would be seen by the device under test,
which would respond accordingly. The stimulus could also just be a time delay,
provided by the measurement computer. It could even be the number of threads used
by Julia for real-time processing.

An instrument property is any persistent setting of an instrument. Tweaking an
instrument property could affect the device under test, but it might not.
Averaging is a good example. With averaging a measurement may look less noisy,
but your device under test doesn't know the difference.
