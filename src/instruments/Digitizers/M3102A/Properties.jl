export FullScale
export InputMode
export Impedance
export Prescaler
export AnalogTrigBehavior
export AnalogTrigThreshold
export DAQTrigMode
export DAQTrigDelay
export DAQPointsPerCycle
export DAQCycles
export ExternalTrigSource
export ExternalTrigBehavior
export AnalogTrigSource

# channel properties
"""
Fullscale of each channel. For example, if the fullscale is configured to be
1V, the digitizer measures voltages on the range of 1V to -1V, and truncates
any values outside this interval to the interval's boundary. The data acquired
by the digitizer is converted to voltages by the formula data*FullScale/2e15
"""
abstract type FullScale <: InstrumentProperty end

"""
Can be configured to be either :DC or :AC
"""
abstract type InputMode <: InstrumentProperty end

"""
Can be configured to be either :Ohm_50 or :Ohm_High, corresponding to either
50Ω impedance or 1MΩ impedance
"""
abstract type Impedance <: InstrumentProperty end

"""
Used to arbitrarily change the sampling rate of the digitizer: the effective sampling
rate is 500e8/(1+prescaler). Can be configured to be an integer greater than or equal
to zero
"""
abstract type Prescaler <: InstrumentProperty end

"""
Analog trigger means trigger by the incoming data itself. Analog trigger behavior
is what behavior by the incoming data triggers the DAQ to start acquiring data.
Can be configured to either: :RisingAnalog, :FallingAnalog, or :BothAnalog, corresponding to,
respectively, trigger on the rising edge, trigger on the falling edge, or trigger
on any edge
"""
abstract type AnalogTrigBehavior <: InstrumentProperty end

"""
Threshold on which, if the incoming data surpasses, generarates an analog trigger
to the DAQ. Configured to be a `Float64` number.
"""
abstract type AnalogTrigThreshold <: InstrumentProperty end

"""
Configures which type of trigger the DAQ will start measuring data upon trigger
acquisition. Can be configured to :Auto (no trigger), :Software, :External, or
:Analog.
"""
abstract type DAQTrigMode <: InstrumentProperty end

"""
Delay between acquisition of trigger and measurement of incoming data. Configured
to be an integer, the delay is measured in units of samples <-> in units of 2ns.
"""
abstract type DAQTrigDelay <: InstrumentProperty end

"""
Number of "cycles" for which the digitizer will acquire data; data acquisition for
each cycle starts upon receiving whatever trigger is configure by DAQTrigMode
property
"""
abstract type DAQCycles <: InstrumentProperty end

"""
Number of samples measured per DAQ cycle
"""
abstract type DAQPointsPerCycle <: InstrumentProperty end

"""
Source of external trigger. Can be configured to be either a number 0-7, which
corresponds to a PXI line on the PXI backplane, or :TrgPort, which corresponds
to the Trg port on the digitizer card
"""
abstract type ExternalTrigSource <: InstrumentProperty end

"""
External trigger behavior is what behavior by the external trigger actually triggers
the DAQ to start acquiring data. Can be configured to either: :Rising, :Falling,
:High, or :Low; corresponding to, respectively, trigger on the rising edge,
trigger on the falling edge, trigger on high voltage, trigger on low voltage
"""
abstract type ExternalTrigBehavior <: InstrumentProperty end

"""
Source of analog trigger; can be configured to be an integer corresponding
to a channel number in the digitizer
"""
abstract type AnalogTrigSource <: InstrumentProperty end


"""
    symbol_to_keysight(sym::Symbol)

This function is used mainly in overloaded `setindex!` methods meant to configure
digitizer instrument properties; it converts specific symbol inputs, which correspond to various
digitizer settings, into Keysight defined constants from the digitizer M31XXA programming manual.

The manual defines a mapping between specific configuration settings and constants.
However, working with the constants directly is undesirable because they are not
descriptive, and the same constants, for example: 1, have different meanings for
different settings/functions. We thus choose to pass symbols to setindex! methods,
and store configuration settings as symbols in `InsDigitizerM3102A` objects, as they can
be more descriptive than integers and are a more flexible type than integers or
strings. `symbol_to_keysight` thus acts as a mapping from symbols handled by the
methods/types to the appropriate constants that need to be passed to the native
C functions that control the digitizer directly.
"""
function symbol_to_keysight(sym::Symbol)
    #digitizer channel configuration
    if sym == :DC
        return KSI.AIN_COUPLING_DC
    elseif sym == :AC
        return KSI.AIN_COUPLING_AC
    elseif sym == :Ohm_50
        return KSI.AIN_IMPEDANCE_50
    elseif sym == :Ohm_High
        return AIN_IMPEDANCE_HZ
    #generated analog trigger configuration
    elseif sym == :RisingAnalog
        return KSI.AIN_RISING_EDGE
    elseif sym == :FallingAnalog
        return KSI.AIN_FALLING_EDGE
    elseif sym == :BothAnalog
        return KSI.AIN_BOTH_EDGES
    #daq cycle trigger configuration
    elseif sym == :Auto
        return KSI.AUTOTRIG
    elseif sym == :Software
        return KSI.SWHVITRIG
    elseif sym == :External
        return KSI.HWDIGTRIG
    elseif sym == :Analog
        return KSI.HWANATRIG
    #digital trigger source
    elseif sym == :TRGPort
        return KSI.TRIG_EXTERNAL
    #digital trigger behavior
    elseif sym == :High
        return KSI.TRIG_HIGH
    elseif sym == :Low
        return KSI.TRIG_LOW
    elseif sym == :Rising
        return KSI.TRIG_RISE
    elseif sym == :Falling
        return KSI.TRIG_FALL
    #module clock mode
    elseif sym == :LowJitter
        return KSI.CLK_LOW_JITTER
    elseif sym == :FastTune
        return KSI.CLK_FAST_TUNE
    else
        error("Symbol input not acceptable")
    end
end
