import Base: setindex!


"""
    configure_channels!(ins::InsDigitizerM3102A , num_of_channels::Integer)

    This function configures all channel properties to default settings (NOTE:
    chosen by me Vinicius, eventually this will change to allow more initialization
    flexibility for each user) and records them in the `ins.channels` dictionary. It takes
    as inputs the instrument objects and  the number of channels. Then, by looping through
    a list of channel numbers, the function configures each channnel and populates the
    `ins.channels` dictionary with the standard configuration settings: either through
    the instrument setindex! methods,or by manually manipulating the dictionary itself
    for recording and using the instrument native C functions to configure.The latter
    is done because there isn't a native C function to configure each setting individually;
    rather, one function will configure multiple settings at once. Thus, we use such functions
    to configure multiple properties at once, and then record these settings in the
    `ins.channels` dictionary, which will allow us to configure settings individually later.
"""
function configure_channels!(ins::InsDigitizerM3102A, num_channels::Integer)
    for ch = 1:num_channels
        ins.channels[ch] = Dict{Any, Any}()
        #I configure these settings and populate ins.channels manually, instead of
        #using the overloaded setindex! methods, because some of these functions
        #only set two or more properties at once, so you can't just set one setting
        #individually without first having a record of the other setting
        @KSerror_handler SD_AIN_channelInputConfig(ins.ID, ch, 4,  #NEEDS TO BE CHANGED!!
            symbol_to_keysight(:Ohm_50), symbol_to_keysight(:AC))
        ins.channels[ch][InputMode] = :AC
        ins.channels[ch][FullScale] = 4
        ins.channels[ch][Impedance] = :Ohm_50
        @KSerror_handler SD_AIN_channelTriggerConfig(ins.ID, ch,
                                            symbol_to_keysight(:RisingAnalog), 2)
        ins.channels[ch][AnalogTrigBehavior] = :RisingAnalog
        ins.channels[ch][AnalogTrigThreshold] = 0.1
        @KSerror_handler SD_AIN_DAQconfig(ins.ID, ch, 1000, 0, 0, symbol_to_keysight(:Analog))
        ins.channels[ch][DAQTrigMode] = :Analog
        ins.channels[ch][DAQCycles] = 0
        ins.channels[ch][DAQTrigDelay] = 0
        ins.channels[ch][DAQPointsPerCycle] = 1000
        @KSerror_handler SD_AIN_DAQtriggerExternalConfig(ins.ID, ch, 0, symbol_to_keysight(:Rising))
        ins.channels[ch][ExternalTrigSource] = :TRGPort
        ins.channels[ch][ExternalTrigBehavior] = :Rising
    end
    ins[Prescaler] = 0
    ins[AnalogTrigSource] = 1
    nothing
end

#Below are overloaded setindex! methods for each instrument property
function setindex!(ins::InsDigitizerM3102A, fullscale::Real,
                  ::Type{FullScale}, ch::Integer)
    mode = ins.channels[ch][InputMode]
    impedance = ins.channels[ch][Impedance]
    @KSerror_handler SD_AIN_channelInputConfig(ins.ID, ch, fullscale,
                        symbol_to_keysight(impedance), symbol_to_keysight(mode))
    ins.channels[ch][FullScale] = fullscale
    nothing
end

function setindex!(ins::InsDigitizerM3102A, mode::Symbol,
                  ::Type{InputMode}, ch::Integer)
    fullscale = ins.channels[ch][FullScale]
    impedance = ins.channels[ch][Impedance]
    @KSerror_handler SD_AIN_channelInputConfig(ins.ID, ch, fullscale,
                        symbol_to_keysight(impedance), symbol_to_keysight(mode))
    ins.channels[ch][InputMode] = mode
    nothing
end

function setindex!(ins::InsDigitizerM3102A, impedance::Symbol,
                  ::Type{Impedance}, ch::Integer)
    fullscale = ins.channels[ch][FullScale]
    mode = ins.channels[ch][InputMode]
    @KSerror_handler SD_AIN_channelInputConfig(ins.ID, ch, fullscale,
                        symbol_to_keysight(impedance), symbol_to_keysight(mode))
    ins.channels[ch][Impedance] = impedance
    nothing
end

function setindex!(ins::InsDigitizerM3102A, prescaler::Integer,
                  ::Type{Prescaler}, ch::Integer)
    @KSerror_handler SD_AIN_channelPrescalerConfig(ins.ID, ch, prescaler)
    ins.channels[ch][Prescaler] = prescaler
    nothing
end

function setindex!(ins::InsDigitizerM3102A, behavior::Symbol,
                  ::Type{AnalogTrigBehavior}, ch::Integer)
    threshold = ins.channels[ch][AnalogTrigThreshold]
    @KSerror_handler SD_AIN_channelTriggerConfig(ins.ID, ch,
                                        symbol_to_keysight(behavior), threshold)
    ins.channels[ch][AnalogTrigBehavior] = behavior
    nothing
end

function setindex!(ins::InsDigitizerM3102A, threshold::Real,
                  ::Type{AnalogTrigThreshold}, ch::Integer)
    behavior = ins.channels[ch][AnalogTrigBehavior]
    @KSerror_handler SD_AIN_channelTriggerConfig(ins.ID, ch,
                                        symbol_to_keysight(behavior), threshold)
    ins.channels[ch][AnalogTrigThreshold] = threshold
    nothing
end

function setindex!(ins::InsDigitizerM3102A, daq_mode::Symbol,
                  ::Type{DAQTrigMode}, ch::Integer)
    daq_delay = ins.channels[ch][DAQTrigDelay]
    cycle_points = ins.channels[ch][DAQPointsPerCycle]
    daq_cycles = ins.channels[ch][DAQCycles]
    @KSerror_handler SD_AIN_DAQconfig(ins.ID, ch, cycle_points, daq_cycles, daq_delay,
                                    symbol_to_keysight(daq_mode))
    ins.channels[ch][DAQTrigMode] = daq_mode
    nothing
end

function setindex!(ins::InsDigitizerM3102A, daq_delay::Integer,
                  ::Type{DAQTrigDelay}, ch::Integer)
    daq_mode = ins.channels[ch][DAQTrigMode]
    cycle_points = ins.channels[ch][DAQPointsPerCycle]
    daq_cycles = ins.channels[ch][DAQCycles]
    @KSerror_handler SD_AIN_DAQconfig(ins.ID, ch, cycle_points, daq_cycles, daq_delay,
                                    symbol_to_keysight(daq_mode))
    ins.channels[ch][DAQTrigDelay] = daq_delay
    nothing
end

function setindex!(ins::InsDigitizerM3102A, cycle_points::Integer,
                  ::Type{DAQPointsPerCycle}, ch::Integer)
    daq_mode = ins.channels[ch][DAQTrigMode]
    daq_delay = ins.channels[ch][DAQTrigDelay]
    daq_cycles = ins.channels[ch][DAQCycles]
    @KSerror_handler SD_AIN_DAQconfig(ins.ID, ch, cycle_points, daq_cycles, daq_delay,
                                    symbol_to_keysight(daq_mode))
    ins.channels[ch][DAQPointsPerCycle] = cycle_points
    nothing
end

function setindex!(ins::InsDigitizerM3102A, daq_cycles::Integer,
                  ::Type{DAQCycles}, ch::Integer)
    daq_mode = ins.channels[ch][DAQTrigMode]
    daq_delay = ins.channels[ch][DAQTrigDelay]
    cycle_points = ins.channels[ch][DAQPointsPerCycle]
    @KSerror_handler SD_AIN_DAQconfig(ins.ID, ch, cycle_points, daq_cycles, daq_delay,
                                    symbol_to_keysight(daq_mode))
    ins.channels[ch][DAQCycles] = daq_cycles
    nothing
end

function setindex!(ins::InsDigitizerM3102A, source::Symbol,
                  ::Type{ExternalTrigSource}, ch::Integer)
    behavior = ins.channels[ch][ExternalTrigBehavior]
    @KSerror_handler SD_AIN_DAQtriggerExternalConfig(ins.ID, ch,
            symbol_to_keysight(source), symbol_to_keysight(behavior))
    ins.channels[ch][ExternalTrigSource] = source
    nothing
end

function setindex!(ins::InsDigitizerM3102A, PXI_trig_num::Integer,
                  ::Type{ExternalTrigSource}, ch::Integer)
    behavior = ins.channels[ch][ExternalTrigBehavior]
    @KSerror_handler SD_AIN_DAQtriggerExternalConfig(ins.ID, ch, PXI_trig_num + 4000,
                                                   symbol_to_keysight(behavior))
    ins.channels[ch][ExternalTrigSource] = PXI_trig_num
    nothing
end

function setindex!(ins::InsDigitizerM3102A, behavior::Symbol,
                  ::Type{ExternalTrigBehavior}, ch::Integer)
    source = ins.channels[ch][ExternalTrigSource]
    if typeof(source) == Symbol
        @KSerror_handler SD_AIN_DAQtriggerExternalConfig(ins.ID, ch,
            symbol_to_keysight(source), symbol_to_keysight(behavior))
    else
        @KSerror_handler SD_AIN_DAQtriggerExternalConfig(ins.ID, ch, source + 4000,
            symbol_to_keysight(behavior))
    end
    ins.channels[ch][ExternalTrigBehavior] = behavior
    nothing
end

function setindex!(ins::InsDigitizerM3102A, number::Integer,
                  ::Type{AnalogTrigSource}, ch::Integer)
    @KSerror_handler SD_AIN_DAQanalogTriggerConfig(ins.ID,ch,number)
    ins.channels[ch][AnalogTrigSource] = number
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
