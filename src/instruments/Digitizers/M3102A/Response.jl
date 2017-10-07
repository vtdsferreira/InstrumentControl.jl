# these are examples of response types and measure functions for those types
# these are meant to illustrate, in general, how one sets up the Digitizer for readout

export SingleChStream
export SingleChTrig
export IQTrigResponse

"""
Response type for continuously measuring the output of a channel until a given timeout.
The timeout is measured in terms of milliseconds. It is assumed that the data collection is small
enough that there is no need to configure buffers.
"""
mutable struct SingleChStream <: Response
    dig::InsDigitizerM3102A
    ch::Int #ch for channel
    timeout::Float64
end

function measure(resp::SingleChStream)
#make daq_points 1.1 times the timeout so DAQRead finishes from reaching the timeout
    dig = resp.dig
    ch = resp.ch
    timeout  = resp.timeout
    daq_points = Int(ceil(10 * (resp.timeout* (500e6)))) # making daq_points much larger than data from timeout


    dig[DAQTrigMode, ch] = :Auto
    dig[DAQCycles, ch] = -1 #infinite number of cycles
    dig[DAQPointsPerCycle, ch] = daq_points

    daq_start(dig, ch)
    sleep(0.001)
    data = daq_read(dig, ch, daq_points, Int(ceil(timeout*10e3)))
    return data
end

mutable struct SingleChTrig <: Response
    dig::InsDigitizerM3102A
    ch::Int #ch for channel
    daq_cycles::Int
    points_per_cyle::Int
    delay::Int
    trig_source::Any

end

function measure(resp::SingleChTrig)
    dig = resp.dig
    ch = resp.ch
    @KSerror_handler SD_AIN_triggerIOconfig(dig.ID, 1)
    dig[DAQTrigMode, ch] = :External
    dig[ExternalTrigSource, ch] = resp.trig_source
    dig[DAQPointsPerCycle, ch] = resp.points_per_cyle
    dig[DAQCycles, ch] = resp.daq_cycles
    dig[DAQTrigDelay] = resp.delay

    daq_points = resp.points_per_cyle * resp.daq_cycles
    daq_start(dig, ch)
    data = daq_read(dig, ch, daq_points, 0)
    data = data * (dig[FullScale, ch])/2^15
    return data
end

mutable struct IQTrigResponse <: Response
    dig::InsDigitizerM3102A
    I_ch::Int #ch for channel
    Q_ch::Int
    daq_cycles::Int
    points_per_cyle::Int
    delay::Int
    trig_source::Int
    frequency::Float64
end

function measure(resp::IQTrigResponse)
    dig = resp.dig
    daq_points = resp.points_per_cyle * resp.daq_cycles
    @KSerror_handler SD_AIN_triggerIOconfig(dig.ID, 1)
    for ch in [resp.I_ch, resp.Q_ch]
        dig[DAQTrigMode, ch] = :External
        dig[ExternalTrigSource, ch] = resp.trig_source
        dig[DAQPointsPerCycle, ch] = resp.points_per_cyle
        dig[DAQCycles, ch] = resp.daq_cycles
        dig[DAQTrigDelay] = resp.delay
    end
    daq_start(dig, I_ch, Q_ch)
    I_data = daq_read(dig, I_ch, daq_points, 0)
    I_data = data * (dig[FullScale, I_ch])/2^15
    Q_data = daq_read(dig, Q_ch, daq_points, 0)
    Q_data = data * (dig[FullScale, Q_ch])/2^15
    #get I and Q: Daneil Sank's Thesis
end
