# these are examples of response types and measure functions for those types
# these are meant to illustrate, in general, how one sets up the Digitizer for readout

export SingleChStream
export SingleChPXITrig
export IQTrigResponse

mutable struct SingleChStream <: Response
    ins::InsDigitizerM3102A
    ch::Int #ch for channel
    timeout::Int
    daq_points:: Int #number of DAQpoints, subject to be changed
    #worry about PointsPerCycle? Don't think so
end

function measure(resp::SingleChStream)
    ins = resp.ins
    ins[DAQTrigMode, ch] = :Immediate
    ins[DAQCycles, ch] = -1

    #SET UP BUFFERS, NEEDS WORK
    buffer= Ref{Vector{Int16}} #NEEDS TO BE CHANGED
    @error_handler SD_AIN_DAQbufferAdd(ins.index, resp.ch, buffer, resp.daq_points)
    #Below I assume one buffer is needed for this type of measurement, which is
    #what the manual implies I think
    @error_handler SD_AIN_DAQbufferPoolConfig(ins.index, resp.ch, resp.daq_points, 0)
    #I set the buffer timeout to zero since DAQ read has its own timeout?
    #I think this is what the manual implies
    #if using multiple smaller buffers, maybe make their timeout infinity
    @error_handler SD_AIN_DAQstart(ins.index, resp.ch)
    data = @error_handler SD_AIN_DAQread(ins.index, resp.ch, resp.daq_points, resp.timeout)
    return data
end

mutable struct SingleChPXITrig <: Response
    ins::InsDigitizerM3102A
    ch::Int #ch for channel
    daq_cycles::Int
    points_per_cyle::Int
    PXI_trig_source::Int
end

function measure(resp::SingleChPXITrig)
    ins = resp.ins
    ins[DAQTrigMode, ch] = :Digital
    ins[DAQTrigSource, ch] = :PXI
    ins[DAQTrigPXINumber, ch] = PXI_trig_source
    ins[DAQPointsPerCycle, ch] = resp.points_per_cyle
    ins[DAQCycles, ch] = resp.daq_cycles
    daq_points = resp.points_per_cyle * resp.daq_cycles

    #SET UP BUFFERS, NEEDS WORK
    if daq_points*2 < 2e9
        buffer= Ref{Vector{Int16}} #NEEDS TO BE CHANGED
        @error_handler SD_AIN_DAQbufferAdd(ins.index, resp.ch, buffer, daq_points)
        @error_handler SD_AIN_DAQbufferPoolConfig(ins.index, resp.ch, daq_points, 0)
        @error_handler SD_AIN_DAQstart(ins.index, resp.ch)
        data = @error_handler SD_AIN_DAQread(ins.index, resp.ch, daq_points, 0)
        return data
    else
        total_data = []
        num_buffers = ceil(daq_points/2e9)
        for i in 1:num_buffers
            buffer= Ref{Vector{Int16}} #NEEDS TO BE CHANGED
            @error_handler SD_AIN_DAQbufferAdd(ins.index, resp.ch, buffer, daq_points/num_buffers)
            @error_handler SD_AIN_DAQbufferPoolConfig(ins.index, resp.ch, daq_points/num_buffers, 0)
            @error_handler SD_AIN_DAQstart(ins.index, resp.ch)
            data = @error_handler SD_AIN_DAQread(ins.index, resp.ch, daq_points/num_buffers, 0)
            push!(total_data, data)
        end
        return total_data
    end
end

mutable struct IQTrigResponse <: Response
    ins::InsDigitizerM3102A
    I_ch::Int #ch for channel
    Q_ch::Int
    daq_cycles::Int
    points_per_cyle::Int
    PXI_trig_source::Int
    frequency::Float64
    #worry about PointsPerCycle? Don't think so
end

function measure(resp::IQTrigResponse)
    ins = resp.ins
    daq_points = resp.points_per_cyle * resp.daq_cycles
    for ch in [resp.I_ch, resp.Q_ch]
        ins[DAQTrigMode, ch] = :Digital
        ins[DAQTrigSource, ch] = :PXI
        ins[DAQTrigPXINumber, ch] = PXI_trig_source
        ins[DAQPointsPerCycle, ch] = resp.points_per_cyle
        ins[DAQCycles, ch] = resp.daq_cycles
      #SET UP BUFFERS, NEEDS WORK
    end
    if daq_points*2 < 2e-9
        for ch in [resp.I_ch, resp.Q_ch]
            buffer= Ref{Vector{Int16}} #NEEDS TO BE CHANGED
            @error_handler SD_AIN_DAQbufferAdd(ins.index, ch, buffer, daq_points)
            @error_handler SD_AIN_DAQbufferPoolConfig(ins.index, ch, daq_points, 0)
        end
        mask=chs_to_mask(resp.I_ch, resp.Q_ch)
        @error_handler SD_AIN_DAQstartMultiple(ins.index, mask)
        I_data =  @error_handler SD_AIN_DAQread(ins.index, resp.I_ch, daq_points, 0)
        Q_data = @error_handler SD_AIN_DAQread(ins.index, resp.Q_ch, daq_points, 0)
        #process I_data and Q_data
    else
        total_I_data = []
        total_Q_data = []
        num_buffers = ceil(daq_points/2e-9)
        for i in 1:num_buffers
            for ch in [resp.I_ch, resp.Q_ch]
                buffer= Ref{Vector{Int16}} #NEEDS TO BE CHANGED
                @error_handler SD_AIN_DAQbufferAdd(ins.index, ch, buffer, daq_points/num_buffers)
                @error_handler SD_AIN_DAQbufferPoolConfig(ins.index, ch, daq_points/num_buffers, 0)
            end
            mask=chs_to_mask(resp.I_ch, resp.Q_ch)
            @error_handler SD_AIN_DAQstartMultiple(ins.index, mask)
            I_data =  @error_handler SD_AIN_DAQread(ins.index, resp.I_ch, daq_points, 0)
            Q_data = @error_handler SD_AIN_DAQread(ins.index, resp.Q_ch, daq_points, 0)
            push!(total_I_data, I_data)
            push!(total_Q_data, Q_data)
        end
    #process total_I_data and total_Q_data
    #get I and Q: Daneil Sank's Thesis
    end
end
