export symbol_to_keysight

export DCOffset
export OutputMode
export FGFrequency
export FGPhase
export TrigSource
export TrigBehavior
export TrigSync
export Queue
export QueueCycleMode
export QueueSyncMode
export AmpModMode
export AngModMode
export AmpModGain
export AngModGain

#channel properties

"""
Configures the type of output from an AWG channel. Can be configured to be either
:Off, :Sinusoidal, :Triangular, :Square, :DC, :Arbitrary, or :Differential
"""
abstract type OutputMode <: InstrumentProperty end

"""
Sets a channel's DC offset on output. Configured to be a `Float64` number.
"""
abstract type DCOffset <: InstrumentProperty end

"""
Sets a channel's function generator frequency. Configured to be a `Float64` number.
"""
abstract type FGFrequency <: InstrumentProperty end

"""
Sets a channel's function generator's relative phase. Configured to be a `Float64` number.
"""
abstract type FGPhase <: InstrumentProperty end

"""
Source of external trigger. Can be configured to be either a number 0-7, which
corresponds to a PXI line on the PXI backplane, or :TrgPort, which corresponds
to the Trg port on the AWG card
"""
abstract type TrigSource <: InstrumentProperty end #for external triggers

"""
External trigger behavior is what behavior by the external trigger actually triggers
the DAQ to start acquiring data. Can be configured to either: :Rising, :Falling,
:High, or :Low; corresponding to, respectively, trigger on the rising edge,
trigger on the falling edge, trigger on high voltage, trigger on low voltage
"""
abstract type TrigBehavior <: InstrumentProperty end #for external triggers

"""
Can be configured to be :CLKsys or :CLK10, which, respectively, corresponds to
processing an acquired trigger on the next internal clock tick, or on the next
chassis clock tick.
"""
abstract type TrigSync <: InstrumentProperty end #for external triggers

"""
List of waveform IDs, corresponding to waveforms queued in a particular channel.
Order of waveform IDs corresponds to order of queued waveforms
"""
abstract type Queue <: InstrumentProperty end

"""
Can be configured to, respectively, :Cyclic or :OneShot, which corresponds to,
respectively, configuring the queue to repeat indefinitely, or configuring the
queue to only be outputted one time
"""
abstract type QueueCycleMode <: InstrumentProperty end

"""
Can be configured to be :CLKsys or :CLK10, which, respectively, corresponds to
start sequencing a queue on the next internal clock tick, or on the next
chassis clock tick.
"""
abstract type QueueSyncMode <: InstrumentProperty end

"""
Amplitude modulation mode. Can be configured to either :NoMod, :AmplitudeMod, or
:DCMod
"""
abstract type AmpModMode <: InstrumentProperty end

"""
Angle modulation mode. Can be configure to either :NoMod, :PhaseMod, or :FrequencyMod.
"""
abstract type AngModMode <: InstrumentProperty end

"""
Amplitude of amplitude modulating signal. Configured to be a `Float64` number.
"""
abstract type AmpModGain <: InstrumentProperty end

"""
Amplitude of angle modulating signal. Configured to be a `Float64` number.
"""
abstract type AngModGain <: InstrumentProperty end

"""
    symbol_to_keysight(sym::Symbol)

This function is used mainly in overloaded `setindex!` methods meant to configure
AWG instrument properties; it converts specific symbol inputs, which correspond to various
AWG settings, into Keysight defined constants from the AWG M32XXA programming manual.

The manual defines a mapping between specific configuration settings and constants.
However, working with the constants directly is undesirable because they are not
descriptive, and the same constants, for example: 1, have different meanings for
different settings/functions. We thus choose to pass symbols to setindex! methods,
and store configuration settings as symbols in `InsAWGM320XA` objects, as they can
be more descriptive than integers and are a more flexible type than integers or
strings. `symbol_to_keysight` thus acts as a mapping from symbols handled by the
methods/types to the appropriate constants that need to be passed to the native
C functions that control the AWG directly.
"""
function symbol_to_keysight(sym::Symbol)
    #AWG trigger settings
    if sym == :Auto
        return KSI.AUTOTRIG
    elseif sym == :Software
        return KSI.SWHVITRIG
    elseif sym == :SF_PerCycle
        return KSI.SWHVITRIG_CYCLE
    elseif sym == :External
        return KSI.EXTTRIG
    elseif sym == :ExternalPerCycle
        return KSI.EXTTRIG_CYCLE
    #AWG trigger behavior
    elseif sym == :High
        return KSI.TRIG_HIGH
    elseif sym == :Low
        return KSI.TRIG_LOW
    elseif sym == :Rising
        return KSI.TRIG_RISE
    elseif sym == :Falling
        return KSI.TRIG_FALL
    #AWG trigger source
    elseif sym ==  :TRGPort
        return KSI.TRIG_EXTERNAL
    #module clock mode
    elseif sym == :LowJitter
        return KSI.CLK_LOW_JITTER
    elseif sym == :FastTune
        return KSI.CLK_FAST_TUNE
    #output waveform
    elseif sym == :NoSignal
        return KSI.AOU_HIZ
    elseif sym == :Off
        return KSI.AOU_OFF
    elseif sym == :Sinusoidal
        return KSI.AOU_SINUSOIDAL
    elseif sym == :Triangular
        return KSI.AOU_TRIANGULAR
    elseif sym == :Square
        return KSI.AOU_SQUARE
    elseif sym == :DC
        return KSI.AOU_DC
    elseif sym == :Arbitrary
        return KSI.AOU_AWG
    elseif sym == :Differential
        return KSI.AOU_PARTNER
    #waveform input type
    elseif sym == :Analog16
        return KSI.WAVE_ANALOG_16
    elseif sym == :Analog32
        return KSI.WAVE_ANALOG_32
    elseif sym == :DualAnalog16
        return KSI.WAVE_ANALOG_16_DUAL
    elseif sym == :DualAnalog32
        return KSI.WAVE_ANALOG_32_DUAL
    elseif sym == :IQ
        return KSI.WAVE_IQ
    elseif sym == :ModPhase
        return KSI.WAVE_IQPOLAR
    elseif sym == :Digital
        return KSI.WAVE_DIGITAL
    #AWG queue repition mode
    elseif sym == :OneShot
        return Cint(0)
    elseif sym == :Cyclic
        return Cint(1)
    #sync mode
    elseif sym == :CLKsys
        return KSI.SYNC_NONE
    elseif sym == :CLK10
        return  KSI.SYNC_CLK_0
    #amplitude modulation
    elseif sym == :NoMod
        return KSI.AOU_MOD_OFF
    elseif sym == :AmplitudeMod
        return KSI.AOU_MOD_AM
    elseif sym == :DCMod
        return KSI.AOU_MOD_OFFSET
    elseif sym == :FrequencyMod
        return KSI.AOU_MOD_FM
    elseif sym == :PhaseMod
        return KSI. AOU_MOD_PM
    else
        error("Symbol input not acceptable")
    end
end
