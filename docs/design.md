# Design overview

## What is an instrument?

`abstract Instrument`

For the purposes of this package, an instrument is just something connected to the
computer that we need to communicate with, and which can source or measure something.
Every instrument may connect to the computer by different hardware,
comms protocols, and command dialects.

All instruments are Julia objects, subtypes of the abstract type `Instrument`.

## Instrument types

Many instruments share the same communications protocols. We subtype `Instrument`
based on these protocols.

### VISA

`abstract InstrumentVISA <: Instrument`

Many instruments are able to be addressed using the
[VISA](http://www.ivifoundation.org/docs/vpp432_2014-06-19.pdf) standard (Virtual
Instrument Software Architecture), currently maintained by the IVI Foundation.

To talk to VISA instruments will require the Julia package [VISA.jl](http://www.github.com/ajkeller34/VISA.jl)
as well as the [National Instruments VISA libraries](https://www.ni.com/visa/).
Installation instructions are available at each link.

### Alazar digitizers

`abstract InstrumentAlazar <: Instrument`

Digitizers made by [AlazarTech](http://www.alazartech.com) are notably *not*
compatible with the VISA standard. The VISA standard was probably not intended
for PCIe cards with extreme data throughput. All Alazar digitizers are addressable by an API
supplied by the company, which talks to the card through a shared library (think .dll on
Windows or .so on Linux).

The shared library files and API documentation are only available from AlazarTech.

## Instrument interface

### Properties

Instrument properties are configured and inspected using two functions,
`configure` and `inspect`. Why not `set` and `get`? Ultimately these verbs are
pretty generic and often have implicit meanings in other programming languages.
In C, for instance, `get` often implies that the function will return an address
in memory rather than a value.

["configure"](http://m-w.com/dictionary/configure):
"to arrange or prepare (something) so that it can be used."

["inspect"](http://m-w.com/dictionary/inspect):
"to look at (something) carefully in order to learn more about it, to find problems, etc."

### Source and measure

Two functions are provided to abstract away many kinds of measurements: `source`
and `measure`. In an experiment you source some stimulus and measure a response.
Therefore `source` takes as an argument an object matching type signature
`Stimulus`, which can have different fields for different types of stimuli.
`measure` takes as an argument an object matching type signature `Response`. The
idea is to write new subtypes of `Stimulus` and `Response` to describe what you
are doing, as well as new methods for `source` and `measure`.

#### Stimuli

Many common stimuli are already provided. For example, a signal generator may
have `FrequencyStimulus` objects, with fields `siggen::SignalGenerator`
and `frequency::AbstractFloat`. To source this stimulus (change the frequency),
a method `source(freqstim::FrequencyStimulus)` is defined, which would change
the frequency of the signal sourced by the generator as specified.

Not all stimuli are associated with a physical instrument. For instance, a
`DelayStimulus` will cause the script to block until a specified time after
creation of the `DelayStimulus` object before proceeding with a measurement.
Perhaps in this case the instrument is the computer itself, but in the
implementation, a `DelayStimulus` object has no field matching type signature
`Instrument`.

We have seen that a stimulus need not even be associated with an `Instrument`. It
stands to reason that in principle they could be associated with several `Instrument`
objects. Maybe a stimulus in a particular experiment is to change all gate voltages
at once. If these are gate voltages are sourced by several physical instruments,
then for example, perhaps several `Instrument`s should be a field in a new
`Stimulus` object.

#### Responses

Responses need not come from instruments. For test purposes, suppose we want to
mimic a measurement by generating random numbers. `RandomResponse` produces a
random number in the unit interval when it is measured. A `TimerResponse` will
measure the time since creation of the `TimerResponse` object.

#### Feedback loops

In principle, software feedback loops could be implemented
with the [Reactive.jl](http://www.github.com/shashi/Reactive.jl) package. This
would probably only be suitable for slowly varying signals, e.g. PID temperature control.

### Measurement archetypes

Now that we have abstracted `source` and `measure`, we can think about archetypal
measurement schemes. Often we want to do a 1D sweep:

```
function sweep1d(stimulus::Stimulus, response::Response)
    for value in iterator
        source(stimulus,value)
        measure(response)
    end
end
```

It is clear that in most cases this single 1D sweep function will suffice for
any kind of 1D sweep we want to do. This is a compelling reason to write
measurement code in a language that natively supports mulitple dispatch, such as
Julia.
