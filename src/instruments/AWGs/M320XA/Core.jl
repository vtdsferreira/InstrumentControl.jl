"""
    @error_handler(expr)

Takes an KeysightInstruments API call and brackets it with some error checking.
Throws an InstrumentException if there is an error. This macro is compatible with
all SD_AOU functions, most but not all SD_Module functions, and it is NOT compatible
with SD_Wave functions
"""
macro error_handler(expr)
    quote
        SD_call_result = $(esc(expr))
        if typeof(SD_call_result) <: Integer
            SD_call_result < 0 &&
            #the expression will be a call to a KeysightInstruments SD function,
            #where the function signature will be SD_name(ins.index, args...);
            # expr.args[2] is ins.index; expr.args[2].args[1] is ins
            throw(InstrumentException($(esc(expr.args[2].args[1])), SD_call_result))
        end
        SD_call_result
    end
end

"""
```
mutable struct Waveform
    waveformValues::Array{Float64}
    name::String
    ch_properties::Dict{Int, Dict{Any, Any}}
end
```

Object representing a waveform; it holds as fields a waveform name, the actual
waveform digital values, and  individual channel properties in a dictionary named
`ch_properties`. When waveforms are queued in an AWG channel from the RAM, various
settings pertaining to when and how the waveform will be generated and outputted
must be specified, such as: what triggers the waveform to start, how many times it
should repeat in a cycle, what is the delay between the trigger and the generation
of the waveform, etc. These settings can also vary from channel to channel, and cannot
be queried directly from the instrument

Thus, we store this waveform channel configuration information in the dictionary
`ch_properties`. In this type's implementation, the values of the dictionaries are
themselves dictionaries that hold all configuration information particular to a
channel.For example, for an object `wav::Waveform`, `wav.ch_properties[1]`
will return a dictionary that holds all configuration information specific to
channel 1. Its keys will be subtypes of the `WaveChProperty` abstract type, and
its values will be the values which the channel property associated that subtype
are configured to for the waveform.

The inner constructor provided takes an array of points and a waveform name, and
initializes a blank `ch_properties` dictionary, with corresponding blank dictionaries
for each channel. It knows how many channels there will be from the module global
constant `CHANNELS` defined in the InsAWGM320XA constructor.
"""
mutable struct Waveform
    waveformValues::Array{Float64}
    name::String
    ch_properties::Dict{Int, Dict{Any, Any}}
    #the methods that change this ch_properties[int] will only allow WaveChProperty keys
    Waveform(waveformValues::Array{Float64}, name::String) = begin
        wav = new()
        wav.name = name
        wav.waveformValues = waveformValues
        wav.ch_properties = Dict{Int, Dict{Any, Any}}()
        for ch = 1:CHANNELS
            wav.ch_properties[ch] = Dict{Any, Any}()
        end
        return wav
    end
end

"""
```
mutable struct InsAWGM320XA <: Instrument
    serial_num::String
    product_name::String
    index::Int
    chassis_num::Int
    slot_num::Int
    channels::Dict{Int, Dict{Any, Any}}
    waveforms::Dict{Int, Waveform}
end
```
Object representing an AWGM320XA instrument. It holds, as fields, instrument
information such as AWG instrument index, slot number, chassis number, serial number,
product name, etc. We take this object to represent both M3202A AWGs and M3201A AWGs,
since they have the exact same functionality, they only have different specs. The
`product_name` field can be used to distinguish wether an object of type `InsAWGM320XA`
correponds to an M3202A or M3101A AWG via its "name".

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
information described above with the passed arguments, initializes the `waveforms`
dictionary, and initializes all the channels properties to some standard
values and records them in the `channels` dictionary through the `configure_channels!`
function
"""
mutable struct InsAWGM320XA <: Instrument
    serial_num::String
    product_name::String
    index::Int
    chassis_num::Int
    slot_num::Int
    channels::Dict{Int, Dict{Any, Any}}
    #the methods that change this channels[int] will only allow InstrumentProperty keys
    waveforms::Dict{Int, Waveform}

    InsAWGM320XA(serial::AbstractString, name::AbstractString) = begin
        ins = new()
        ins.serial_num = serial
        ins.product_name = name
        #below we simultaneously "open" the device and get its index
        SD_open_result = SD_Module_openWithSerialNumber(ins.product_name, ins.serial_num)
        SD_open_result < 0 && throw(InstrumentException(ins, SD_open_result))
        ins.index = SD_open_result
        ins.chassis_num  = @error_handler SD_Module_getChassis(ins.index)
        ins.slot_num = @error_handler SD_Module_getSlot(ins.index)
        ins.waveforms = Dict{Int, Waveform}()
        ins.channels = Dict{Int, Dict{Any, Any}}()
        configure_channels!(ins)
        return ins
    end

    InsAWGM320XA(slot::Integer,chassis::Integer = 1) = begin
        ins = new()
        ins.chassis_num = chassis
        ins.slot_num = slot
        ins.product_name = SD_Module_getProductNameBySlot(ins.chassis_num, ins.slot_num)
        SD_open_result = SD_Module_openWithSlot(ins.product_name, ins.chassis_num, ins.slot_num)
        SD_open_result < 0 && throw(InstrumentException(ins, SD_open_result))
        ins.index = SD_open_result
        ins.serial_num = @error_handler SD_Module_getSerialNumber(ins.index)
        ins.waveforms = Dict{Int, Waveform}()
        ins.channels = Dict{Int, Dict{Any, Any}}()
        configure_channels!(ins)
        return ins
    end
end
