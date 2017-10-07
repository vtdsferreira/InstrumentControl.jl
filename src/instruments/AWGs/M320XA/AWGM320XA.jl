module AWGM320XA

using KeysightInstruments
KSI = KeysightInstruments

import Base: getindex, setindex!, show
importall InstrumentControl
import ICCommon: Stimulus,
    Response,
    source,
    measure,
    axisname,
    axislabel

export InsAWGM320XA
export awg_start
export awg_is_run
export awg_stop


include("Core.jl")
include("Waveform.jl")
include("Properties.jl")
include("Configure.jl")
include("Inspect.jl")

"""
    awg_start(awg::InsAWGM320XA, ch::Integer)
    awg_start(awg::InsAWGM320XA, chs::Vararg{Int})

    Starts acquisition of triggers for generation/ouputting of all waveforms
    queued on the awg(s) of channel `ch` or channels `chs`.
"""
function awg_start end

function awg_start(awg::InsAWGM320XA, ch::Integer)
    @KSerror_handler SD_AOU_AWGstart(awg.ID, ch)
    nothing
end

function awg_start(awg::InsAWGM320XA, chs::Vararg{Int})
    @KSerror_handler SD_AOU_AWGstartMultiple(awg.ID, nums_to_mask(chs...))
    nothing
end

"""
    awg_is_run(awg::InsAWGM320XA, ch::Integer)
    Checks if the AWG corresponding to channel `ch`  or channels `ch` on AWG card
    corresponding to object `awg` is "running", i.e. it is waiting for triggers to
    output waveforms     or is actively outputting waveforms. Prints either "YES" or "NO"
"""
function awg_is_running(awg::InsAWGM320XA, ch::Integer)
    run_result = @KSerror_handler SD_AOU_AWGisRunning(awg.ID, ch)
    if run_result == 0
        println("NO")
    elseif run_result == 1
        println("YES")
    end
    nothing
end

"""
    awg_stop(awg:InsAWGM320XA, ch::Integer)
    awg_stop(awg:InsAWGM320XA, chs::Vararg{Int})
    awg_stop(awg::InsAWGM320XA)

    Stops the arbitrary waveform generator on channel `ch`, or channels `chs`, or
    on all channels if no channel is specified.
"""
function awg_stop end

function awg_stop(awg::InsAWGM320XA, ch::Integer)
    @KSerror_handler SD_AOU_AWGstop(awg.ID, ch)
    nothing
end

function awg_stop(awg::InsAWGM320XA, chs::Vararg{Int})
    @KSerror_handler SD_AOU_AWGstopMultiple(awg.ID, nums_to_mask(chs...))
    nothing
end

function awg_stop(awg::InsAWGM320XA)
    num_channels = size(collect(keys(awg.channels)))[1]
    chs = tuple((1:1:num_channels)...)
    awg_stop(awg, chs...)
end

make(ins::InsAWGM320XA) = "Keysight"
model(ins::InsAWGM320XA) = ins.product_name

#InstrumentException type defined in src/Definitions.jl in InstrumentControl
InstrumentException(ins::InsAWGM320XA, error_code::Integer) =
    InstrumentException(ins, error_code, keysight_error(error_code))

#Miscallenous
"""
    nums_to_mask(chs...)

Function that takes in integers which signify either: AWG channels to start/stop/etc,
or PXI trigger lines to send markers to, and outputs the integer mask that holds
that information. This integer mask, when converted to binary format, has 1's for
the passed integers, and 0 otherwise.
"""
function nums_to_mask(chs...)
    chs_vec = collect(chs)
    chs_vec = sort(chs_vec)
    length = size(chs_vec)[1]
    mask = "0b01"
    for i=0:(length-2)
        zeros_num = chs_vec[length-i]-chs_vec[length-i-1]-1
        if zeros_num>0
            zeros = repeat("0",zeros_num)
            mask = mask*zeros*"1"
        else
            mask = mask*"1"
        end
    end
    mask = mask*repeat("0",chs_vec[1]-1)
    mask = Int(parse(mask))
    return mask
end

end #module
