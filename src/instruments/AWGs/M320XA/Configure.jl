import Base: setindex!
export configure_channels!

"""
    configure_channels!(ins::InsAWGM320XA , num_of_channels::Integer = 4)

This function configures all channel properties to default settings (NOTE:
chosen by me Vinicius, eventually this will change to allow more initialization
flexibility for each user) and records them in the `ins.channels` dictionary. First,
the function sets `num_of_channels`, the number of channels on the AWG, as a global
constant of the module. Then, by looping through a list of channel numbers, the
function configures each channnel and populates the `ins.channels` dictionary with
the standard configuration settings: either through the instrument setindex! methods,
or by manually manipulating the dictionary itself for recording and using the instrument
native C functions to configure.
"""
function configure_channels!(ins::InsAWGM320XA , num_of_channels::Integer = 4)
    global const CHANNELS = num_of_channels
    for i = 1:CHANNELS
        ins.channels[ch] = Dict{Any, Any}()
        ins.channels[ch][Queue] = Dict{Int, Int}()
        #I configure these settings and populate ins.channels manually, instead of
        #using the overloaded setindex! methods, because some of these functions
        #only set two or more properties at once, so you can't just set one setting
        #individually without first having a record of the other setting
        SD_AOU_AWGtriggerExternalConfig(ins.index, ch, 4000, symbol_to_keysight(:Rising))
        ins.channels[ch][TrigSource] = 0
        ins.channels[ch][TrigBehavior] = :Rising
    end
    ins[WaveformShape] = :Arbitrary
    ins[FGFrequency] = 1e8
    ins[FGPhase] = 0
    ins[WaveAmplitude] = 0.2 #NEEDS CHANGING
    ins[DCOffset] = 0
    ins[QueueCycleMode] = :Cyclic
    ins[QueueSyncMode] = :CLKPXI
    nothing
end


#Below are overloaded setindex! methods for each instrument property
function setindex!(ins::InsAWGM320XA, wav_type::Symbol,
                  ::Type{WaveformShape}, ch::Integer)
    SD_AOU_channelWaveShape(ins.index, ch, symbol_to_keysight(wav_type))
    ins.channels[ch][WaveformShape] = wav_type
    nothing
end

function setindex!(ins::InsAWGM320XA, amplitude::Float64,
                  ::Type{WaveAmplitude}, ch::Integer)
    SD_AOU_channelAmplitude(ins.index, ch, amplitude)
    ins.channels[ch][WaveAmplitude] = amplitude
    nothing
end

function setindex!(ins::InsAWGM320XA, offset::Float64,
                  ::Type{DCOffset}, ch::Integer)
    SD_AOU_channelOffset(ins.index, ch, offset)
    ins.channels[ch][DCOffset] = offset
    nothing
end

function setindex!(ins::InsAWGM320XA, frequency::Float64,
                  ::Type{FGFrequency}, ch::Integer)
    SD_AOU_channelFrequency(ins.index, ch, frequency)
    ins.channels[ch][FGFrequency] = frequency
    nothing
end

function setindex!(ins::InsAWGM320XA, phase::Float64,
                  ::Type{FGPhase}, ch::Integer)
    SD_AOU_channelPhase(ins.index, ch, phase)
    ins.channels[ch][FGPhase] = phase
    nothing
end

function setindex!(ins::InsAWGM320XA, PXI_trig_num::Integer,
                  ::Type{TrigSource}, ch::Integer)
    behavior = ins.channels[ch][TrigBehavior]
    SD_AOU_AWGtriggerExternalConfig(ins.index, ch, PXI_trig_num + KSI.TRIG_PXI_AWG,
                                    symbol_to_keysight(behavior))
    ins.channels[ch][TrigSource] = PXI_trig_num
    nothing
end

function setindex!(ins::InsAWGM320XA, source::Symbol,
                  ::Type{TrigSource}, ch::Integer)
    behavior = ins.channels[ch][TrigBehavior]
    SD_AOU_AWGtriggerExternalConfig(ins.index, ch, symbol_to_keysight(source),
                                    symbol_to_keysight(behavior))
    ins.channels[ch][TrigSource] = source
    nothing
end

function setindex!(ins::InsAWGM320XA, behavior::Symbol,
                  ::Type{TrigBehavior, ch::Integer})
    source = ins.channels[ch][TrigSource]
    if typeof(source) == Symbol
        SD_AOU_AWGtriggerExternalConfig(ins.index, ch, symbol_to_keysight(source)
                                        symbol_to_keysight(behavior))
    else
        SD_AOU_AWGtriggerExternalConfig(ins.index, ch, source + 4000,
                                        symbol_to_keysight(behavior))
    end
    ins.channels[ch][TrigBehavior] = behavior
    nothing
end

function setindex!(ins::InsAWGM320XA, queue_mode::Symbol,
                  ::Type{QueueCycleMode}, ch::Integer)
    SD_AOU_AWGqueueConfig(ins.index, ch, symbol_to_keysight(queue_mode))
    ins.channels[ch][QueueCycleMode] = queue_mode
    nothing
end

function setindex!(ins::InsAWGM320XA, queue_sync_mode::Symbol,
                  ::Type{QueueSyncMode}, ch::Integer)
    SD_AOU_AWGqueueSyncMode(ins.index, ch, symbol_to_keysight(queue_sync_mode))
    ins.channels[ch][QueueSyncMode] = queue_sync_mode
    nothing
end

# if no channel is specified, then the setindex! method is either going to change
# the non-channel specific settings :ClockMode and ClockFrequency, or it will change
# all channel properties at once. This method then checks if T == ClockMode or ClockFrequency,
# and changes that accordingly if it is. If not, it is assumed that T is a channel
# specific channel property, and the method configures T for all channels to be
# the passed property_val argument
function setindex!(ins::InsAWGM320XA, property_val::Any,
                  ::Type{T}) where {T<:InstrumentProperty}
    if T == ClockMode && typeof(property_val) == Symbol
        SD_AIN_clockSetFrequency(ins.index, SD_AIN_clockGetFrequency(ins.index),
                                symbol_to_keysight(property_val))
        ins.clock_mode = property_val
    elseif T == ClockFrequency && typeof(property_val) == Float64
        mode = ins.clock_mode
        SD_AIN_clockSetFrequency(ins.index, property_val, symbol_to_keysight(mode))
    else
        for ch in keys(ins.channels)
            setindex!(ins,property_val,T,ch)
        end
    end
    nothing
end
