module AWGM310XA

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
importall KeysightInstruments.SD_Module
importall KeysightInstruments.SD_AIN

export InsAWGM320XA
"""
```
mutable struct InsAWGM320XA
  serial_num::String
  product_name::String
  index::Int
  chassis_num::Int
  slot_num::Int
  channels::Dict{Int, Dict{Any, Any}}
  #the methods that change this channels[int] will only allow InstrumentProperty keys
  waveforms::Dict{Int, Waveform}
  clock_mode::Symbol
  clock_frequency::Float64
end
```
Object representing an AWGM320XA instrument. It holds, as fields, instrument
information such as AWG instrument index, slot number, chassis number, serial number,
product name, etc. We take this object to represent both M3202A AWGs and M3201A AWGs,
since they have the exact same functionality, they only have different specs. The
`product_name` field can be used to distinguish wether an object of type `InsAWGM320XA`
correponds to an M3202A or M3101A AWG via its "name". Also, the instrument property
`ClockMode` (which is a subtype of `InstrumentProperty`) is made an explicit field of the
InsAWGM320XA type because there is no native function to query which clock mode
the AWG is configured to, thus we record this information as a type field
in order to "query the AWG" which clock mode it is configured to.

In addition, the AWG object holds all the waveforms stored in its RAM in a dictionary,
named `waveforms`,  where the waveforms are indexed by their identifier number,
which the user specifies when he/she loads an waveform into the RAM of the AWG.

This object also holds individual channel properties in a dictionary named `channels`,
where in the type's implementation, the values of the dictionaries are themselves
dictionaries that hold all configuration information for a particular channel.For
example, for an object `ins::InsAWGM320XA`, `ins.channels[1]` will return a dictionary
that holds all configuration information for channel 1; its keys will be subtypes
of the `InstrumentProperty` abstract type, and its values will be the values which
the instrument property associated that subtype are configured to in that channel
in the digitizer.

Two inner constructors are provided: one which initializes the object with a given
slot number and chassis number, and one which initializes the object with a given
serial number and name. When the object is initialized, it obtains all other instrument
information described above with the passed arguments, initializes the clock mode
as "Low Jitter" and records it in the `clock_mode` field, initializes the `waveforms`
dictionary, and finnaly, initializes all the channels properties to some standard
values and records them in the `channels` dictionary through the `configure_channels!`
function
"""
mutable struct InsAWGM320XA
  serial_num::String
  product_name::String
  index::Int
  chassis_num::Int
  slot_num::Int
  channels::Dict{Int, Dict{Any, Any}}
  #the methods that change this channels[int] will only allow InstrumentProperty keys
  waveforms::Dict{Int, Waveform}
  clock_mode::Symbol

  InsAWGM320XA(serial::AbstractString, name::AbstractString) = begin
    ins = new()
    ins.serial_num = serial
    ins.product_name = name
    #below we simultaneously "open" the device and get its index
    ins.index = SD_Module_openWithSerialNumber(ins.product_name, ins.serial_num)
    ins.chassis_num  = SD_Module_getChassis(ins.index)
    ins.slot_num = SD_Module_getSlot(ins.index)
    ins.clock_mode = :LowJitter
    SD_AIN_clockSetFrequency(ins.index, SD_AIN_clockGetFrequency(ins.index),
                            symbol_to_keysight(ins.clock_mode))
    ins.waveforms = Dict{Int, Waveform}()
    ins.channels = Dict{Int, Dict{Any, Any}}()
    configure_channels!(ins)
    return ins
  end

  InsAWGM320XA(chassis::Integer,slot::Integer) = begin
    ins = new()
    ins.chassis_num = chassis
    ins.slot_num = slot
    ins.index = SD_Module_openWithSlot(ins.product_name, ins.chassis_num,ins.slot_num)
    ins.product_name = SD_Module_getProductNameByIndex(ins.index)
    ins.serial_num = SD_Module_getSerialNumberByIndex(ins.index)
    ins.clock_mode = :LowJitter
    SD_AIN_clockSetFrequency(ins.index, SD_AIN_clockGetFrequency(ins.index),
                            symbol_to_keysight(ins.clock_mode))
    ins.waveforms = Dict{Int, Waveform}()
    ins.channels = Dict{Int, Dict{Any, Any}}()
    configure_channels!(ins)
    return ins
  end
end

include("Properties.jl")
include("Configure.jl")
include("Inspect.jl")
include("Waveform.jl")

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
