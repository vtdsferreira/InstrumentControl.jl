# these are examples of response types and measure functions for those types
# these are meant to illustrate, in general, how one sets up the Digitizer for readout

export SingleChStream
export SingleChPXITrig
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
    daq_points = Int(ceil(1.1 * (resp.timeout* (500e6))))


    dig[DAQTrigMode, ch] = :Auto
    dig[DAQCycles, ch] = -1 #infinite number of cycles
    dig[DAQPointsPerCycle, ch] = daq_points

    @KSerror_handler SD_AIN_DAQstart(dig.ID, ch)
    sleep(0.001)
    data = @KSerror_handler SD_AIN_DAQread(dig.ID, ch, daq_points, Int(ceil(timeout*10e3)))
    return data
end

mutable struct SingleChPXITrig <: Response
    dig::InsDigitizerM3102A
    ch::Int #ch for channel
    daq_cycles::Int
    points_per_cyle::Int
    PXI_trig_source::Int
end

function measure(resp::SingleChPXITrig)
    dig = resp.dig
    dig[DAQTrigMode, ch] = :Digital
    dig[DAQTrigSource, ch] = :PXI
    dig[DAQTrigPXINumber, ch] = PXI_trig_source
    dig[DAQPointsPerCycle, ch] = resp.points_per_cyle
    dig[DAQCycles, ch] = resp.daq_cycles
    daq_points = resp.points_per_cyle * resp.daq_cycles

    #SET UP BUFFERS, NEEDS WORK
    if daq_points*2 < 2e9
        buffer= Ref{Vector{Int16}} #NEEDS TO BE CHANGED
        @KSerror_handler SD_AIN_DAQbufferAdd(dig.ID, resp.ch, buffer, daq_points)
        @KSerror_handler SD_AIN_DAQbufferPoolConfig(dig.ID, resp.ch, daq_points, 0)
        @KSerror_handler SD_AIN_DAQstart(dig.ID, resp.ch)
        data = @KSerror_handler SD_AIN_DAQread(dig.ID, resp.ch, daq_points, 0)
        return data
    else
        total_data = []
        num_buffers = ceil(daq_points/2e9)
        for i in 1:num_buffers
            buffer= Ref{Vector{Int16}} #NEEDS TO BE CHANGED
            @KSerror_handler SD_AIN_DAQbufferAdd(dig.ID, resp.ch, buffer, daq_points/num_buffers)
            @KSerror_handler SD_AIN_DAQbufferPoolConfig(dig.ID, resp.ch, daq_points/num_buffers, 0)
            @KSerror_handler SD_AIN_DAQstart(dig.ID, resp.ch)
            data = @KSerror_handler SD_AIN_DAQread(dig.ID, resp.ch, daq_points/num_buffers, 0)
            push!(total_data, data)
        end
        return total_data
    end
end

mutable struct IQTrigResponse <: Response
    dig::InsDigitizerM3102A
    I_ch::Int #ch for channel
    Q_ch::Int
    daq_cycles::Int
    points_per_cyle::Int
    PXI_trig_source::Int
    frequency::Float64
    #worry about PointsPerCycle? Don't think so
end

function measure(resp::IQTrigResponse)
    dig = resp.dig
    daq_points = resp.points_per_cyle * resp.daq_cycles
    for ch in [resp.I_ch, resp.Q_ch]
        dig[DAQTrigMode, ch] = :Digital
        dig[DAQTrigSource, ch] = :PXI
        dig[DAQTrigPXINumber, ch] = PXI_trig_source
        dig[DAQPointsPerCycle, ch] = resp.points_per_cyle
        dig[DAQCycles, ch] = resp.daq_cycles
      #SET UP BUFFERS, NEEDS WORK
    end
    if daq_points*2 < 2e-9
        for ch in [resp.I_ch, resp.Q_ch]
            buffer= Ref{Vector{Int16}} #NEEDS TO BE CHANGED
            @KSerror_handler SD_AIN_DAQbufferAdd(dig.ID, ch, buffer, daq_points)
            @KSerror_handler SD_AIN_DAQbufferPoolConfig(dig.ID, ch, daq_points, 0)
        end
        mask=chs_to_mask(resp.I_ch, resp.Q_ch)
        @KSerror_handler SD_AIN_DAQstartMultiple(dig.ID, mask)
        I_data =  @KSerror_handler SD_AIN_DAQread(dig.ID, resp.I_ch, daq_points, 0)
        Q_data = @KSerror_handler SD_AIN_DAQread(dig.ID, resp.Q_ch, daq_points, 0)
        #process I_data and Q_data
    else
        total_I_data = []
        total_Q_data = []
        num_buffers = ceil(daq_points/2e-9)
        for i in 1:num_buffers
            for ch in [resp.I_ch, resp.Q_ch]
                buffer= Ref{Vector{Int16}} #NEEDS TO BE CHANGED
                @KSerror_handler SD_AIN_DAQbufferAdd(dig.ID, ch, buffer, daq_points/num_buffers)
                @KSerror_handler SD_AIN_DAQbufferPoolConfig(dig.ID, ch, daq_points/num_buffers, 0)
            end
            mask=chs_to_mask(resp.I_ch, resp.Q_ch)
            @KSerror_handler SD_AIN_DAQstartMultiple(dig.ID, mask)
            I_data =  @KSerror_handler SD_AIN_DAQread(dig.ID, resp.I_ch, daq_points, 0)
            Q_data = @KSerror_handler SD_AIN_DAQread(dig.ID, resp.Q_ch, daq_points, 0)
            push!(total_I_data, I_data)
            push!(total_Q_data, Q_data)
        end
    #process total_I_data and total_Q_data
    #get I and Q: Daneil Sank's Thesis
    end
end
