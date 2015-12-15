# Design overview

## What is an instrument?

`abstract Instrument`

For the purposes of this package, an instrument is just something connected to the
computer that we need to communicate with, and which can source or measure something.
Every instrument may connect to the computer by different hardware,
comms protocols, and command dialects.

All instruments are Julia objects, subtypes of the abstract type `Instrument`.

### Instrument types

Many instruments share the same communications protocols. We subtype `Instrument`
based on these protocols.

#### VISA

`abstract InstrumentVISA <: Instrument`

Many instruments are able to be addressed using the
[VISA](http://www.ivifoundation.org/docs/vpp432_2014-06-19.pdf) standard (Virtual
Instrument Software Architecture), currently maintained by the IVI Foundation.

To talk to VISA instruments will require the Julia package [VISA.jl](http://www.github.com/ajkeller34/VISA.jl)
as well as the [National Instruments VISA libraries](https://www.ni.com/visa/).
Installation instructions are available at each link.

#### Alazar digitizers

`abstract InstrumentAlazar <: Instrument`

Digitizers made by [AlazarTech](http://www.alazartech.com) are notably *not*
compatible with the VISA standard. The VISA standard was probably not intended
for PCIe cards with extreme data throughput. All Alazar digitizers are addressable by an API
supplied by the company, which talks to the card through a shared library (think .dll on
Windows or .so on Linux).

The shared library files and API documentation are only available from AlazarTech.

## How do we configure instruments?

### Properties

Instrument properties are configured and inspected using two functions,
`configure` and `inspect`. Why not `set` and `get`? Ultimately these verbs are
pretty generic and often have implicit meanings in other programming languages.
In C, for instance, `get` often implies that the function will return an address
in memory rather than a value.

Both `configure` and `inspect` have a lot of methods that take as one of their
arguments an `InstrumentProperty` subtype:

```
abstract InstrumentProperty
abstract NumericalProperty <: InstrumentProperty
```

One subtypes `InstrumentProperty` for properties such as `ClockSource`, the
logical states of which have no obvious consistent encoding. One should instead
subtype `NumericalProperty` for properties where a number suffices to describe
the property (up to units).

Properties which may be shared by multiple instruments should be defined in
`src/InstrumentDefs.jl`. Examples include `Frequency`, `Power`, `SampleRate`, etc.
They may be imported in each instrument's module as needed. Properties specific
to a given instrument may of course be defined in that instrument's module.

A design choice was for `configure` and `inspect` to take types rather than
objects. Two examples:

```
configure(awg, RisingTrigger) # not RisingTrigger()
configure(awg, SampleRate, 10e6) # not SampleRate() or SampleRate(10e6)
```

## How do we take measurements?

### Source and measure

Two functions are provided to abstract away many kinds of measurements: `source`
and `measure`. In an experiment you source some stimulus and measure a response.
Therefore `source` takes as an argument an object matching type signature
`Stimulus`, which can have different fields for different types of stimuli, as
well as some value. `measure` takes as an argument an object matching type
signature `Response`. The idea is to write new subtypes of `Stimulus` and `Response`
to describe what you are doing, as well as new methods for `source` and `measure`.
This will become clearer below when discussing measurement archetypes.

### Stimuli

`abstract Stimulus`

All stimuli are objects, subtyped from the abstract `Stimulus` type.
Many common stimuli are already provided. In fact, a great deal of functionality
is provided by the `PropertyStimulus` type, which allows any `NumericalProperty`
to act as a `Stimulus`. Consider the following example, where we make a
`PropertyStimulus` for sweeping the frequency of our E8257D signal generator:

```jl
stim = PropertyStimulus(siggen::E8257D, Frequency)
for freq in 1e9:1e8:5e9
    source(stim, freq)
    # measure(something)
end
```

Stimuli need not be tied to a particular property. Rather, this is just one
convenient and easily generalized example.

Not all stimuli are associated with a physical instrument. For instance, sourcing a
`DelayStimulus` will cause the script to block until a specified time after
creation of the `DelayStimulus` object.
Perhaps in this case the instrument is the computer itself, but in the
implementation, a `DelayStimulus` object has no field matching type signature
`Instrument`.

We have seen that a stimulus need not even be associated with an `Instrument`. It
stands to reason that in principle they could be associated with several `Instrument`
objects. Maybe a stimulus that makes sense for a particular experiment would be
to change all gate voltages at once. If these gate voltages are sourced by several
physical instruments, then several `Instrument`s should be fields in a new
`Stimulus` subtype.

### Responses

`abstract Response{T}`

Unlike stimuli, all responses are subtypes of an abstract parametric type,
`Response{T}`. Although it may seem unduly abstract to have it be both abstract
and parametric, we use this
functionality to distinguish between desired return types of a measurement.
Suppose an instrument provides data in some kind of awkward format, like 12-bit
unsigned integers. For reasons of convenience we may want the measurement to
return the data in a machine-native `Int64` format, or we may want to specify
a linear or 2D shape for the data, etc.

An important consideration in writing fast Julia code is to ensure type stability.
In other words, the type that is returned from a function should depend only on
the method signature and not depend on some value at run-time. By parameterizing
`Response` types with the return type, we can ensure that `measure` will be
type stable. If we instead had the desired return type as some field
in a `Response` object, then `measure` would not be type stable.

#### Alazar digitizers

A response type is given for each measurement mode:
continuous streaming (`ContinuousStreamResponse`), triggered streaming (
`TriggeredStreamResponse`), NPT records (`NPTRecordResponse`),
and FPGA-based FFT calculations (`FFTHardwareResponse`).
Traditional record mode has not been implemented yet for lack of immediate need.

Looking at the source code, it would
seem that there is some redundancy in the types, for instance there is an
`NPTRecordMode` and an `NPTRecordResponse` object. The difference is that the
former is used internally in the code to denote a particular method of configuring
the instrument, allocating buffers, etc., whereas the latter specifies what you
actually want to do: retrieve NPT records from the digitizer, perhaps doing
some post-processing or processing during acquisition along the way. Perhaps
different responses would dictate different processing behavior, while the
instrument is ultimately configured the same way.

#### Miscellaneous

Responses need not come from instruments. For test purposes, suppose we want to
mimic a measurement by generating random numbers. `RandomResponse` produces a
random number in the unit interval when it is measured. A `TimerResponse` will
measure the time since creation of the `TimerResponse` object.

### Feedback loops

In principle, asynchronous software feedback loops could be implemented
with the [Reactive.jl](http://www.github.com/shashi/Reactive.jl) package. This
would probably only be suitable for slowly varying signals, e.g. PID temperature
control. Ultimately benchmarking needs to be done to determine how useful
this approach would be.

## Measurement archetypes

Now that we have abstracted `source` and `measure`, we can think about archetypal
measurement schemes. Often we want to do a 1D sweep:

```
# Just an example; not necessarily implemented this way...
function sweep1d(stimulus::Stimulus, response::Response, iterator)
    a = Array()
    for value in iterator
        source(stimulus,value)
        r = measure(response)
        push!(a,r)
    end
    return a
end
```

It is clear that in most cases this single 1D sweep function will suffice for
any kind of 1D sweep we want to do. This is a compelling reason to write
measurement code in a language that natively supports mulitple dispatch, such as
Julia.
