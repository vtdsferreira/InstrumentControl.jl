```@meta
CurrentModule = InstrumentControl.DigitizerM3102A
DocTestSetup = quote
    using InstrumentControl
end
```


# Keysight M3102A Digitizer

This module contains the many methods and types necessary to control and configure
the Keysight M3102A Digitizer. In essence, it wraps the [KeysightInstruments.jl](https://github.com/PainterQubits/KeysightInstruments.jl) package,
which in itself is a bare-bones wrapper to the native C library which controls
the Keysight instruments, in a way which affords compatibility with the rest of the InstrumentControl
package, as well as consistency between the control code of this instrument and other
instruments represented in this package.

## Usage/Configuration

###Instrument Overview

Each MM3102A Digitizer card has several channels; each channel has it's own
DAQ for reading data. The DAQ reads data upon acquisition of triggers, and stores the data
in a buffer allocated in the onboard RAM of the digitizer card. Upon reaching a user defined
threshold for data acquisition, either an memory threshold or a time threshold, the contents
of the buffer are passed on to the computer through the (fast) PXI cables. The DAQ can also
be configured to read the data in "cycles", where acquisition for each cycle commences upon
receiving a trigger, in which the user configures the amount of data acquired in each cycle.

Moreover, each Digitizer card has it's own internal 100MHz clock which is phase-locked to the
chassis clock: any actions taken by the AWG occur on a clock tick (so in intervals
of 10ns), and different AWG/Digitizer cards are synchronized through the chassis clock. Each
card also has an extra port called the TRG port, on which triggers can be received or generated

###Usage

All instrument control and configuration happens through the following
`Instrument` subtype:

```@docs
    InsDigitizerM3102A
```
For example, calling `InsDigitizerM3102A(16,1,num_channels = 4)` will open the Digitizer card on slot 16
on the PXI chassis indexed by 1 (internal Keysight software does the chassis "indexing");
`num_channels` corresponds to the number of channels in the Digitizer card. The second input,
which sets the value for the `chassis` field in the `InsDigitizerM3102A` object, is an optional
argument with default value `1` (for the case when only one chassis is connected to
the computer), while the `num_channels` input is a keyword argument whose default
value is `4` --> Hence, `InsDigitizerM3102A(16)` would make an instance of the same object.

###Configuration

Configuration/Inspection of settings happens through setindex!/getindex methods, as
described in [Overview](https://painterqubits.github.io/InstrumentControl.jl/latest/ins_meas/)

These are the following properties which can be configured, each of which has it's
own `InstrumentProperty` subtype:

```@docs
    FullScale
    InputMode
    Impedance
    Prescaler
    AnalogTrigBehavior
    AnalogTrigThreshold
    DAQTrigMode
    DAQTrigDelay
    DAQPointsPerCycle
    DAQCycles
    ExternalTrigSource
    ExternalTrigBehavior
    AnalogTrigSource
```
