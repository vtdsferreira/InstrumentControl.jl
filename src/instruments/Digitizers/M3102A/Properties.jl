export ClockMode
export ClockFrequency
export ChannelScale
export ChannelInputMode
export ChannelPrescaler
export ChAnalogTrigBehavior
export ChAnalogTrigThreshold
export DAQTrigMode
export DAQTrigDelay
export DAQPointsPerCycle
export DAQCycles
export DAQTrigSource
export DAQTrigPXINumber
export DAQTrigBehavior
export DAQAnalogTrigSource

# digitizer properties
abstract type ClockFrequency <: InstrumentProperty end
abstract type ClockMode <: InstrumentProperty end

# channel properties
abstract type ChannelScale <: InstrumentProperty end
abstract type ChannelInputMode <: InstrumentProperty end
abstract type ChannelPrescaler <: InstrumentProperty end
abstract type ChAnalogTrigBehavior <: InstrumentProperty end
abstract type ChAnalogTrigThreshold <: InstrumentProperty end
abstract type DAQTrigMode <: InstrumentProperty end
abstract type DAQTrigDelay <: InstrumentProperty end
abstract type DAQPointsPerCycle <: InstrumentProperty end
abstract type DAQCycles <: InstrumentProperty end
abstract type DAQTrigSource <: InstrumentProperty end
abstract type DAQTrigPXINumber <: InstrumentProperty end
abstract type DAQTrigBehavior <: InstrumentProperty end
abstract type DAQAnalogTrigSource <: InstrumentProperty end

"""
    symbol_to_keysight(sym::Symbol)

This function is used mainly in overloaded `setindex!` methods meant to configure
AWG instrument properties; it converts specific symbol inputs, which correspond to various
AWG settings, into Keysight defined constants from the digitizer M31XXA programming manual.
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
    #digitizer input mode
    if sym == :DC
      return KSI.AIN_COUPLING_DC
    elseif sym == :AC
      return KSI.AIN_COUPLING_AC
    #generated analog trigger configuration
    elseif sym == :RisingAnalog
      return KSI.AIN_RISING_EDGE
    elseif sym == :FallingAnalog
      reurn KSI.AIN_FALLING_EDGE
    elseif sym == :BothAnalog
      return KSI.AIN_BOTH_EDGES
    #daq cycle trigger configuration
    elseif sym == :Immediate
      return KSI.AUTOTRIG
    elseif sym == :Software_HVI
      return KSI.SWHVITRIG
    elseif sym == :Digital
      retun KSI.HWDIGTRIG
    elseif sym == :Analog
      return KSI.HWANATRIG
    #digital trigger source
    elseif sym == :TRGPort
      return KSI.TRIG_EXTERNAL
    elseif sym == :PXI
      return KSI.TRIG_PXI
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
