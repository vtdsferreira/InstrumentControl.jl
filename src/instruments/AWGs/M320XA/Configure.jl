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
        @error_handler SD_AOU_AWGtriggerExternalConfig(ins.index, ch, 4000,
                        symbol_to_keysight(:Falling), symbol_to_keysight(:CLKsys))
        ins.channels[ch][TrigSource] = 0
        ins.channels[ch][TrigBehavior] = :Falling
        ins.channels[ch][TrigSync] = :CLKsys
        ins.channel[ch][AmpModGain] = 0
        ins.channel[ch][AngModGain] = 0
        ins.channel[ch][AmpModMode] = :NoMod
        ins.channel[ch][AngModeMode] = :NoMod
    end
    ins[WaveformShape] = :Off
    ins[FGFrequency] = 1e8
    ins[FGPhase] = 0
    ins[WaveAmplitude] = 0
    ins[DCOffset] = 0
    ins[QueueCycleMode] = :Cyclic
    ins[QueueSyncMode] = :CLK10
    nothing
end


#Below are overloaded setindex! methods for each instrument property
function setindex!(ins::InsAWGM320XA, wav_type::Symbol,
                  ::Type{WaveformShape}, ch::Integer)
    @error_handler SD_AOU_channelWaveShape(ins.index, ch, symbol_to_keysight(wav_type))
    ins.channels[ch][WaveformShape] = wav_type
    nothing
end

function setindex!(ins::InsAWGM320XA, amplitude::Real,
                  ::Type{WaveAmplitude}, ch::Integer)
    @error_handler SD_AOU_channelAmplitude(ins.index, ch, amplitude)
    ins.channels[ch][WaveAmplitude] = amplitude
    nothing
end

function setindex!(ins::InsAWGM320XA, offset::Real,
                  ::Type{DCOffset}, ch::Integer)
    @error_handler SD_AOU_channelOffset(ins.index, ch, offset)
    ins.channels[ch][DCOffset] = offset
    nothing
end

function setindex!(ins::InsAWGM320XA, frequency::Real,
                  ::Type{FGFrequency}, ch::Integer)
    @error_handler SD_AOU_channelFrequency(ins.index, ch, frequency)
    ins.channels[ch][FGFrequency] = frequency
    nothing
end

function setindex!(ins::InsAWGM320XA, phase::Real,
                  ::Type{FGPhase}, ch::Integer)
    @error_handler SD_AOU_channelPhase(ins.index, ch, phase)
    ins.channels[ch][FGPhase] = phase
    nothing
end

function setindex!(ins::InsAWGM320XA, mode::Symbol, ::Type{AmpModMode},
                  ch::Integer)
    amp_gain = ins.channels[ch][AmpModGain]
    @error_handler SD_AOU_modulationAmplitudeConfig(ins.index, ch, symbol_to_keysight(mode),
                                                amp_gain)
    ins.channel[ch][AmpModMode] =  mode
    nothing
end

function setindex!(ins::InsAWGM320XA, amp_gain::Real, ::Type{AmpModGain},
                  ch::Integer)
    mode = ins.channels[ch][AmpModMode]
    @error_handler SD_AOU_modulationAmplitudeConfig(ins.index, ch, symbol_to_keysight(mode),
                                                amp_gain)
    ins.channel[ch][AmpModGain] =  amp_gain
    nothing
end

function setindex!(ins::InsAWGM320XA, mode::Symbol, ::Type{AngModMode},
                  ch::Integer)
    ang_gain = ins.channels[ch][AngModGain]
    @error_handler SD_AOU_modulationAngleConfig(ins.index, ch, symbol_to_keysight(mode),
                                                ang_gain)
    ins.channel[ch][AngModMode] =  mode
    nothing
end

function setindex!(ins::InsAWGM320XA, ang_gain::Real, ::Type{AngModGain},
                  ch::Integer)
    mode = ins.channels[ch][AngModMode]
    @error_handler SD_AOU_modulationAmplitudeConfig(ins.index, ch, symbol_to_keysight(mode),
                                                ang_gain)
    ins.channel[ch][AngModGain] =  ang_gain
    nothing
end

function setindex!(ins::InsAWGM320XA, PXI_trig_num::Integer,
                  ::Type{TrigSource}, ch::Integer)
    behavior = ins.channels[ch][TrigBehavior]
    sync = ins.channels[ch][TrigSync]
    @error_handler SD_AOU_AWGtriggerExternalConfig(ins.index, ch,
                                                PXI_trig_num + KSI.TRIG_PXI_AWG,
                            symbol_to_keysight(behavior), symbol_to_keysight(sync))
    ins.channels[ch][TrigSource] = PXI_trig_num
    nothing
end

function setindex!(ins::InsAWGM320XA, source::Symbol, ::Type{TrigSource}, ch::Integer)
    behavior = ins.channels[ch][TrigBehavior]
    sync = ins.channels[ch][TrigSync]
    @error_handler SD_AOU_AWGtriggerExternalConfig(ins.index, ch,
        symbol_to_keysight(source), symbol_to_keysight(behavior), symbol_to_keysight(sync))
    ins.channels[ch][TrigSource] = source
    nothing
end

function setindex!(ins::InsAWGM320XA, behavior::Symbol, ::Type{TrigBehavior}, ch::Integer)
    source = ins.channels[ch][TrigSource]
    sync = ins.channels[ch][TrigSync]
    if typeof(source) == Symbol
        @error_handler SD_AOU_AWGtriggerExternalConfig(ins.index, ch,
            symbol_to_keysight(source), symbol_to_keysight(behavior), symbol_to_keysight(sync))
    else
        @error_handler SD_AOU_AWGtriggerExternalConfig(ins.index, ch, source + 4000,
            symbol_to_keysight(behavior), symbol_to_keysight(sync))
    end
    ins.channels[ch][TrigBehavior] = behavior
    nothing
end

function setindex!(InsAWGM320XA, sync::Symbol, ::Type{TrigSync}, ch::Integer)
    source = ins.channels[ch][TrigSource]
    behavior = ins.channels[ch][TrigBehavior]
    if typeof(source) == Symbol
        @error_handler SD_AOU_AWGtriggerExternalConfig(ins.index, ch,
            symbol_to_keysight(source), symbol_to_keysight(behavior), symbol_to_keysight(sync))
    else
        @error_handler SD_AOU_AWGtriggerExternalConfig(ins.index, ch, source + 4000,
            symbol_to_keysight(behavior), symbol_to_keysight(sync))
    end
    ins.channels[ch][TrigSync] = sync
    nothing
end

function setindex!(ins::InsAWGM320XA, cycle_mode::Symbol,
                  ::Type{QueueCycleMode}, ch::Integer)
    @error_handler SD_AOU_AWGqueueConfig(ins.index, ch, symbol_to_keysight(cycle_mode))
    ins.channels[ch][QueueCycleMode] = cycle_mode
    nothing
end

function setindex!(ins::InsAWGM320XA, sync_mode::Symbol,
                  ::Type{QueueSyncMode}, ch::Integer)
    @error_handler SD_AOU_AWGqueueSyncMode(ins.index, ch,
                                           symbol_to_keysight(sync_mode))
    ins.channels[ch][QueueSyncMode] = sync_mode
    nothing
end

#this method configures T for some channels passed
function setindex!(ins::InsAWGM320XA, property_val::Any,
                  ::Type{T}, chs::Vararg{Integer}) where {T<:InstrumentProperty}
    for ch in chs
        setindex!(ins,property_val,T,ch)
    end
    nothing
end

# method configures T for all channels to be the passed property_val argument
function setindex!(ins::InsAWGM320XA, property_val::Any,
                  ::Type{T}) where {T<:InstrumentProperty}
    for ch in keys(ins.channels)
        setindex!(ins,property_val,T,ch)
    end
    nothing
end
