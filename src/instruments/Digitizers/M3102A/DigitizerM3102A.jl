module DigitizerM3102A

using KeysightInstruments
using AxisArrays
KSI = KeysightInstruments

import Base: getindex, setindex!, show
importall InstrumentControl
import ICCommon: Stimulus,
    Response,
    source,
    measure,
    axisname,
    axislabel


export InsDigitizerM3102A
export daq_read
export daq_counter
export daq_start
export daq_stop
export daq_flush

"""
```
mutable struct InsDigitizerM3102A <: Instrument
    serial_num::String
    product_name::String
    index::Int
    chassis_num::Int
    slot_num::Int
    channels::Dict{Int,Dict{Any,Any}}
end
```
Object representing an DigitizerM3102A instrument. It holds, as fields, instrument
information such as digitizer card instrument index, slot number, chassis number,
serial number, product name, etc.

This object also holds individual channel properties in a dictionary named `channels`,
where in the type's implementation, the values of the dictionaries are themselves
dictionaries that hold all configuration information for a particular channel.For
example, for an object `ins::InsDigitizerM3102A`, `ins.channels[1]` will return a dictionary
that holds all configuration information for channel 1; its keys will be subtypes
of the `InstrumentProperty` abstract type, and its values will be the values which
the instrument property associated that subtype are configured to in that channel
in the digitizer.

One inner constructor is provided which initializes the object with a given
slot number and chassis number. The inner constructor also takes a `num_channels` keyword
argument, corresponding to the number of channels on the instrument, which is used
for initial configuration of the instrument channels. When the object is initialized,
it obtains all other information described above with the passed arguments, and
initializes all the channels properties to some standard values and records them
in the `channels` dictionary through the `configure_channels!` function
"""
mutable struct InsDigitizerM3102A <: Instrument
    serial_num::String
    product_name::String
    ID::Int
    chassis_num::Int
    slot_num::Int
    channels::Dict{Int,Dict{Any,Any}}

    InsDigitizerM3102A(slot::Integer, chassis::Integer = 1; num_channels::Integer = 4) = begin
        ins = new()
        ins.chassis_num = chassis
        ins.slot_num = slot
        product_name = SD_Module_getProductNameBySlot(ins.chassis_num, ins.slot_num)
        typeof(product_name) <: Integer && error("Error in opening the module. Is the slot number correct?")
        #below we simultaneously "open" the device and get its index
        ins.ID = @KSerror_handler SD_Module_openWithSlot(ins.product_name, ins.chassis_num, ins.slot_num)
        ins.serial_num = @KSerror_handler SD_Module_getSerialNumber(ins.ID)
        ins.channels = Dict{Int, Dict{Any, Any}}()
        configure_channels!(ins, num_channels)
        return ins
    end
end

include("Properties.jl")
include("Configure.jl")
include("Inspect.jl")
include("Response.jl")

"""
    daq_start(dig::InsDigitizerM3102A, ch::Integer)
    daq_start(dig::InsDigitizerM3102A, chs::Vararg{Int})

Starts acquisition of triggers by the DAQ for data recording.
"""
function daq_start end

function daq_start(dig::InsDigitizerM3102A, ch::Integer)
    @KSerror_handler SD_AIN_DAQstart(dig.ID, ch)
    nothing
end

function daq_start(dig::InsDigitizerM3102A, chs::Vararg{Int})
    @KSerror_handler SD_AIN_DAQstartMultiple(dig.ID, chs_to_mask(chs...))
    nothing
end

"""
    daq_read(dig::InsDigitizerM3102A, ch::Integer, daq_points::Integer, timeout::Real)

Acquires data recorded by DAQ, and returns it. Timeout is meant to be inputted in
units of seconds for consistency, but the function calculates it in units of
integer milliseconds, which is the unit that the native C functions actually take.
"""
function daq_read(dig::InsDigitizerM3102A, ch::Integer, daq_points::Integer, timeout::Real)
    (timeout < 0.001 && timeout != 0) && error("timeout has to be at least 1ms")
    timeout_ms = Int(ceil(timeout*10e3))
    data = @KSerror_handler SD_AIN_DAQread(dig.ID, ch, daq_points, timeout_ms)
    return data
end

"""
    daq_counter(dig::InsDigitizerM3102A, ch::Integer)

Gives the number of points acquired by DAQ since the last call to daq_read
"""
function daq_counter(dig::InsDigitizerM3102A, ch::Integer)
    return @KSerror_handler SD_AIN_DAQcounterRead(dig.ID, ch)
end

"""
    daq_stop(dig::InsDigitizerM3102A)
    daq_stop(dig::InsDigitizerM3102A, ch::Integer)
    daq_stop(dig::InsDigitizerM3102A, chs::Vararg{Int})

Stops DAQ acquisition of data
"""
function daq_stop end

function daq_stop(dig::InsDigitizerM3102A, ch::Integer)
    @KSerror_handler SD_AIN_DAQstop(dig.ID, ch)
    nothing
end

function daq_stop(dig::InsDigitizerM3102A, chs::Vararg{Int})
    @KSerror_handler SD_AIN_DAQstopMultiple(dig.ID, chs_to_mask(chs...))
    nothing
end

function daq_stop(dig::InsDigitizerM3102A)
    num_channels = size(collect(keys(dig.channels)))[1]
    chs = tuple((1:1:num_channels)...)
    daq_stop(dig, chs...)
end

"""
daq_flush(dig::InsDigitizerM3102A)
daq_flush(dig::InsDigitizerM3102A, ch::Integer)
daq_flush(dig::InsDigitizerM3102A, chs::Vararg{Int})

Flushes the DAQ buffers
"""
function daq_flush(dig::InsDigitizerM3102A, ch::Integer)
    @KSerror_handler SD_AIN_DAQflush(dig.ID, ch)
    nothing
end

function daq_flush(dig::InsDigitizerM3102A, chs::Vararg{Int})
    @KSerror_handler SD_AIN_DAQflushMultiple(dig.ID, chs_to_mask(chs...))
    nothing
end

function daq_flush(dig::InsDigitizerM3102A)
    num_channels = size(collect(keys(dig.channels)))[1]
    chs = tuple((1:1:num_channels)...)
    daq_flush(dig, chs...)
end

make(ins::InsDigitizerM3102A) = "Keysight"
model(ins::InsDigitizerM3102A) = ins.product_name

"How to display an instrument, e.g. in an error."
show(io::IO, dig::InsDigitizerM3102A) = print(io, make(dig), " ", model(dig), " Slot ", dig.slot_num)

#InstrumentException type defined in src/Definitions.jl in InstrumentControl
InstrumentException(ins::InsDigitizerM3102A, error_code::Integer) =
    InstrumentException(ins, error_code, keysight_error(error_code))


#Miscallenous
"""
    chs_to_mask(chs...)

Function that takes in integers which signify digitizer channels to start/stop/etc,
and outputs the integer mask that holds that information. This integer mask,
when converted to binary format, has 1's for the passed integers, and 0 otherwise.
"""
function chs_to_mask(chs...)
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
