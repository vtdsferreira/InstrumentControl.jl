# Design overview

## What should good measurement code do?

Anyone who has written code in MATLAB or something comparable (IGOR Pro, in the
author's case) has undoubtedly seen spaghetti code. Often there are many copies
of a measurement routine that differ only slightly, perhaps in the functionality
of what happens inside some for loop, etc.

We would like to have clear, reusable code to avoid redundancy and accidental
errors, both of which consume precious time on the part of the experimenters.
Consider an archetypal measurement scheme wherein we measure a device's response to
various stimuli (perhaps we measure current as a function of applied bias).
We should be able to write just one sweep function to do this:

```julia
# Just an example; only slightly simplified...
function sweep(stimulus::Stimulus, response::Response, iterator)
    for values in iterator
        source(stimulus,value)
        measure(response)
    end
end
```

The idea of *multiple dispatch*, natively supported in Julia, permits writing such
convenient and abstract code. This is just one example where the advantages of
multiple dispatch are obvious. We hope it will more broadly simplify the extension of
measurement code while ensuring continued reliability.

## How do we take measurements?

### Source and measure

Two functions are provided to abstract away many kinds of measurements: `source`
and `measure`. In an experiment you source some stimulus and measure a response.
Therefore `source` takes as an argument an object matching type signature
`Stimulus`, which can have different fields for different types of stimuli, as
well as some value. `measure` takes as an argument an object matching type
signature `Response`. The idea is to write new subtypes of `Stimulus` and `Response`
to describe what you are doing, as well as new methods for `source` and `measure`.

### Stimuli

All stimuli are objects, subtyped from the abstract `Stimulus` type.
Many stimuli, associated with the capabilities of particular instruments,
are already implemented.

Not all stimuli are associated with a physical instrument. For instance, sourcing a
`DelayStimulus` will cause the script to block until a specified time after
creation of the `DelayStimulus` object.

Stimuli could also be associated with several instruments. Maybe a stimulus that
makes sense for a particular experiment would be to change all gate voltages at once.
These gate voltages could of course be sourced by several physical instruments.

### Responses

All responses are objects, subtyped from the abstract parametric `Response{T}` type.
We use a parametric type for responses so that the return type of the numerical data
is clear. Usually a response is associated with a particular instrument.

However, responses need not come from instruments. For test purposes, suppose we want to
mimic a measurement by generating random numbers. `RandomResponse` produces a
random number in the unit interval when it is measured. A `TimerResponse` will
measure the time since creation of the `TimerResponse` object.

## What is an instrument?

For the purposes of this package, an instrument is just something connected to the
computer that we need to communicate with, and which can source or measure something.
Every instrument may connect to the computer by different hardware,
comms protocols, and command dialects.

All instruments are Julia objects, subtypes of the abstract type `Instrument`.

### Instrument types

Many instruments share the same communications protocols. We subtype `Instrument`
based on these protocols.

#### VISA

Many instruments are able to be addressed using the
[VISA](http://www.ivifoundation.org/docs/vpp432_2014-06-19.pdf) standard (Virtual
Instrument Software Architecture), currently maintained by the IVI Foundation.
`InstrumentVISA` is an abstract subtype of `Instrument`.

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
`configure` and `inspect`. Why not `set` and `get`? Ultimately these verbs are
pretty generic and often have implicit meanings in other programming languages.
In Objective C, for instance, `get` implies that the function will return an address
in memory rather than a value.

Both `configure` and `inspect` have a lot of methods that take as one of their
arguments an `InstrumentProperty` subtype. One subtypes `InstrumentProperty` for properties such as `ClockSource`, the
logical states of which have no obvious consistent encoding. One should instead
subtype `NumericalProperty` for properties where a number suffices to describe
the property (up to units).

Properties which may be shared by multiple instruments should be defined in
`src/InstrumentDefs.jl`. Examples include `Frequency`, `Power`, `SampleRate`, etc.
They may be imported in each instrument's module as needed. Properties specific
to a given instrument may of course be defined in that instrument's module.

A design choice was for `configure` and `inspect` to take types rather than
objects. Two examples:

```julia
configure(awg, RisingTrigger)    # not RisingTrigger()
configure(awg, SampleRate, 10e6) # not SampleRate() or SampleRate(10e6)
```

### Difference between stimuli and instrument properties

Because a stimulus is defined so broadly, the difference between a stimulus
and an instrument property is not obvious. A stimulus is like a generalized
instrument property: sourcing a stimulus may entail configuring zero or more
instrument properties.

It is useful to think of a stimulus to be something that what you are measuring
has a chance to react to. For example, this could be applied voltage, sourced by
one or more instruments. The applied voltages would be seen by the device under test,
which would respond accordingly. The stimulus could also just be a time delay,
provided by the measurement computer. It could even be the number of threads used
by Julia for real-time processing.

An instrument property is any persistent setting of an instrument. Tweaking an
instrument property could affect the device under test, but it might not.
Averaging is a good example. With averaging a measurement may look less noisy,
but your device under test doesn't know the difference. The trigger engine of a
digitizer would also have associated instrument properties.

In many cases there is an overlap between stimuli and properties. Consider that
the frequency of a signal generator is an instrument property. In this case
sourcing a frequency stimulus results in configuring an instrument property.
Rather than make a `FrequencyStimulus` type, we provide a `PropertyStimulus` type
which can be used more generically. Consider the following example, where we make a
`PropertyStimulus` for sweeping the frequency of our E8257D signal generator:

```julia
stim = PropertyStimulus(siggen::E8257D, Frequency)
for freq in 1e9:1e8:5e9     # 1 GHz to 5 GHz in steps of 100 MHz
    source(stim, freq)
    # measure(something)
end
```

Note that `Frequency` is a subtype of `NumericalProperty`, which is required for
making a `PropertyStimulus`.

Again, stimuli need not be tied to a particular property. Rather, this is just one
convenient and easily generalized example. In more complicated instances it is
probably better to make a new `Stimulus` subtype rather than use `PropertyStimulus`.


## Future directions

### Feedback loops

In principle, asynchronous software feedback loops could be implemented
with the [Reactive.jl](http://www.github.com/shashi/Reactive.jl) package. This
would probably only be suitable for slowly varying signals, e.g. PID temperature
control. Ultimately benchmarking needs to be done to determine how useful
this approach would be.
