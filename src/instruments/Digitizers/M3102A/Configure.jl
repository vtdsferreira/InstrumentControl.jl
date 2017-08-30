import Base: setindex!
export configure_channels!

"""
    configure_channels!(ins::InsAWGM320XA , num_of_channels::Integer = 4)

This function configures all channel properties to default settings (NOTE:
chosen by me Vinicius, eventually this will change to allow more initialization
flexibility for each user) and records them in the `ins.channels` dictionary. First,
the function sets `num_of_channels`, the number of channels on the digitizer, as a global
constant of the module. Then, by looping through a list of channel numbers, the
function configures each channnel and populates the `ins.channels` dictionary with
the standard configuration settings: either through the instrument setindex! methods,
or by manually manipulating the dictionary itself for recording and using the instrument
native C functions to configure.
"""
function configure_channels!(ins::InsDigitizerM3102A, num_of_channels::Integer = 4)
    global const CHANNELS = num_of_channels
    for i = 1:CHANNELS
        ins.channels[ch] = Dict{Any, Any}()
        #I configure these settings and populate ins.channels manually, instead of
        #using the overloaded setindex! methods, because some of these functions
        #only set two or more properties at once, so you can't just set one setting
        #individually without first having a record of the other setting
        @error_handler SD_AIN_channelInputConfig(ins.index, ch, 0.1, symbol_to_keysight(:AC))
        ins.channels[ch][ChannelInputMode] = :AC
        ins.channels[ch][ChannelScale] = 0.1
        @error_handler SD_AIN_channelTriggerConfig(ins.index, ch,
                                            symbol_to_keysight(:RisingAnalog), 2)
        ins.channels[ch][ChAnalogTrigBehavior] = :RisingAnalog
        ins.channels[ch][ChAnalogTrigThreshold] = 2
        @error_handler SD_AIN_DAQconfig(ins.index, ch, 1000, 0, 0, symbol_to_keysight(:Digital))
        ins.channels[ch][DAQTrigMode] = :Digital
        ins.channels[ch][DAQCycles] = 0
        ins.channels[ch][DAQTrigDelay] = 0
        ins.channels[ch][DAQPointsPerCycle] = 1000
        @error_handler SD_AIN_DAQdigitalTriggerConfig(ins.index, ch, symbol_to_keysight(:PXI),
                                     0, symbol_to_keysight(:Rising))
        ins.channels[ch][DAQTrigSource] = :PXI
        ins.channels[ch][DAQTrigMode] = :Rising
        ins.channels[ch][DAQTrigPXINumber] = 0
    end
    ins[ChannelPrescaler] = 0
    ins[DAQAnalogTrigSource] = 1
    nothing
end

#Below are overloaded setindex! methods for each instrument property
function setindex!(ins::InsDigitizerM3102A, fullscale::Float64,
                  ::Type{ChannelScale}, ch::Integer)
    mode = ins.channels[ch][ChannelInputMode]
    @error_handler SD_AIN_channelInputConfig(ins.index, ch, fullscale,
                                             symbol_to_keysight(mode))
    ins.channels[ch][ChannelScale] = fullscale
    nothing
end

function setindex!(ins::InsDigitizerM3102A, mode::Symbol,
                  ::Type{ChannelInputMode}, ch::Integer)
    fullscale = ins.channels[ch][ChannelScale]
    @error_handler SD_AIN_channelInputConfig(ins.index, ch, fullscale,
                                             symbol_to_keysight(mode))
    ins.channels[ch][ChannelInputMode] = mode
    nothing
end

function setindex!(ins::InsDigitizerM3102A, prescaler::Integer,
                  ::Type{ChannelPrescaler}, ch::Integer)
    @error_handler SD_AIN_channelPrescalerConfig(ins.index, ch, prescaler)
    ins.channels[ch][ChannelPrescaler] = prescaler
    nothing
end

function setindex!(ins::InsDigitizerM3102A, trig_mode::Symbol,
                  ::Type{ChAnalogTrigBehavior}, ch::Integer)
    threshold = ins.channels[ch][ChAnalogTrigThreshold]
    @error_handler SD_AIN_channelTriggerConfig(ins.index, ch,
                                        symbol_to_keysight(trig_mode), threshold)
    ins.channels[ch][ChAnalogTrigBehavior] = trig_mode
    nothing
end

function setindex!(ins::InsDigitizerM3102A, threshold::Float64,
                  ::Type{ChAnalogTrigThreshold}, ch::Integer)
    trig_mode = ins.channels[ch][ChAnalogTrigBehavior]
    @error_handler SD_AIN_channelTriggerConfig(ins.index, ch,
                                        symbol_to_keysight(trig_mode), threshold)
    ins.channels[ch][ChAnalogTrigThreshold] = threshold
    nothing
end

function setindex!(ins::InsDigitizerM3102A, daq_mode::Symbol,
                  ::Type{DAQTrigMode}, ch::Integer)
    daq_delay = ins.channels[ch][DAQTrigDelay]
    daq_points = ins.channels[ch][DAQPointsPerCycle]
    daq_cycles = ins.channels[ch][DAQCycles]
    @error_handler SD_AIN_DAQconfig(ins.index, ch, daq_points, daq_cycles, daq_delay,
                                    symbol_to_keysight(daq_mode))
    ins.channels[ch][DAQTrigMode] = daq_mode
    nothing
end

function setindex!(ins::InsDigitizerM3102A, daq_delay::Integer,
                  ::Type{DAQTrigDelay}, ch::Integer)
    daq_mode = ins.channels[ch][DAQTrigMode]
    daq_points = ins.channels[ch][DAQPointsPerCycle]
    daq_cycles = ins.channels[ch][DAQCycles]
    @error_handler SD_AIN_DAQconfig(ins.index, ch, daq_points, daq_cycles, daq_delay,
                                    symbol_to_keysight(daq_mode))
    ins.channels[ch][DAQTrigDelay] = daq_delay
    nothing
end

function setindex!(ins::InsDigitizerM3102A, daq_points::Integer,
                  ::Type{DAQPointsPerCycle}, ch::Integer)
    daq_mode = ins.channels[ch][DAQTrigMode]
    daq_delay = ins.channels[ch][DAQTrigDelay]
    daq_cycles = ins.channels[ch][DAQCycles]
    @error_handler SD_AIN_DAQconfig(ins.index, ch, daq_points, daq_cycles, daq_delay,
                                    symbol_to_keysight(daq_mode))
    ins.channels[ch][DAQPointsPerCycle] = daq_points
    nothing
end

function setindex!(ins::InsDigitizerM3102A, daq_cycles::Integer,
                  ::Type{DAQCycles}, ch::Integer))
    daq_mode = ins.channels[ch][DAQTrigMode]
    daq_delay = ins.channels[ch][DAQTrigDelay]
    daq_points = ins.channels[ch][DAQPointsPerCycle]
    @error_handler SD_AIN_DAQconfig(ins.index, ch, daq_points, daq_cycles, daq_delay,
                                    symbol_to_keysight(daq_mode))
    ins.channels[ch][DAQCycles] = daq_cycles
    nothing
end

function setindex!(ins::InsDigitizerM3102A, source::Symbol,
                  ::Type{DAQTrigSource}, ch::Integer)
    number = ins.channels[ch][DAQTrigPXINumber]
    behavior = ins.channels[ch][DAQTrigBehavior]
    if source == :TRGPort
      @error_handler SD_AIN_DAQdigitalTriggerConfig(ins.index, ch, symbol_to_keysight(source),
                                   KSI.TRIG_EXTERNAL, symbol_to_keysight(behavior))
    elseif source == :PXI
      @error_handler SD_AIN_DAQdigitalTriggerConfig(ins.index, ch, symbol_to_keysight(source),
                                   number, symbol_to_keysight(behavior))
    ins.channels[ch][DAQTrigSource] = source
    nothing
end

function setindex!(ins::InsDigitizerM3102A, number::Integer,
                  ::Type{DAQTrigPXINumber}, ch::Integer)
    source = ins.channels[ch][DAQTrigSource]
    behavior = ins.channels[ch][DAQTrigBehavior]
    @error_handler SD_AIN_DAQdigitalTriggerConfig(ins.index, ch, symbol_to_keysight(source),
                                   number, symbol_to_keysight(behavior))
    ins.channels[ch][DAQTrigPXINumber] = number
    nothing
end

function setindex!(ins::InsDigitizerM3102A, behavior::Symbol,
                  ::Type{DAQTrigBehavior}, ch::Integer)
    source= ins.channels[ch][DAQTrigSource]
    number = ins.channels[ch][DAQTrigPXINumber]
    @error_handler SD_AIN_DAQdigitalTriggerConfig(ins.index, ch, symbol_to_keysight(source),
                                   number, symbol_to_keysight(behavior))
    ins.channels[ch][DAQTrigBehavior] = behavior
    nothing
end

function setindex!(ins::InsDigitizerM3102A, number::Integer,
                  ::Type{DAQAnalogTrigSource}, ch::Integer)
    @error_handler SD_AIN_DAQanalogTriggerConfig(ins.index,ch,number)
    ins.channels[ch][DAQAnalogTrigSource] = number
    nothing
end

# method configures T for all channels to be the passed property_val argument
function setindex!(ins::InsDigitizerM3102A, property_val::Any,
                  ::Type{T}) where {T<:InstrumentProperty}
    for ch in keys(ins.channels)
        setindex!(ins,property_val,T,ch)
    end
    nothing
end
