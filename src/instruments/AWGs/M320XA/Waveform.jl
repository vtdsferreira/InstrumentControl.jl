import DataFrames

export Waveform
export WaveChProperty

export WavTrigMode
export WavDelay
export WavRepetitions
export QueuePosition
export WavPrescaler

export load_waveform
export queue_waveform
export queue_sequence
export queue_flush
export waveforms_flush

"""
'''
mutable struct Waveform
    waveformValues::Array{Float64}
    name::String
    ch_properties::Dict{Int, Dict{Any, Any}}
end
'''

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
        for i = 1:CHANNELS
            wav.ch_properties[ch] = Dict{Any, Any}()
        end
        return wav
    end
end

abstract type WaveChProperty end

abstract type WavTrigMode <: WaveChProperty end
abstract type WavDelay <: WaveChProperty end
abstract type WavRepetitions <: WaveChProperty end
abstract type QueuePosition <: WaveChProperty end
abstract type WavPrescaler <: WaveChProperty end

"""
    load_waveform(ins::InsAWGM320XA, waveformValues::Array{Float64}, id::Integer,
                       name::AbstractString; waveform_type::Symbol = :Digital)

    load_waveform(ins::InsAWGM320XA, waveformFile::String, id::Integer,
                       name::AbstractString = string(id))

Loads a waveform into the the RAM of the AWG corresponding to object `ins`.
When loading a waveform, the user picks an id to be the identifier and handle for
the loaded waveform. Thus, the function takes as arguments the waveform digital
values, the user-specified id, a name for the waveform (meant to be a more descriptive
identifier than an integer), and the type of waveform (digital, phase or amplitude
modulated, IQ modulated, etc). The waveform digital values can be passed as an
array of values, or as a path to a file containing the values.

The function returns a handle to the new `Waveform` object created and stored
in `ins.waveforms`, indexed by it's user-specified id.
"""
function load_waveform end

function load_waveform(ins::InsAWGM320XA, waveformValues::Array{Float64}, id::Integer,
                       name::AbstractString = string(id); waveform_type::Symbol = :Analog32)
    length = size(waveformPoints)
    temp_id = SD_Wave_newFromArrayDouble(symbol_to_Keysight(waveform_type), length,
      waveformValues) #when loading the waveform to the AWG RAM, this id is overwritten
    if haskey(ins.waveforms, id)
        SD_AOU_waveformReLoad(ins.index, temp_id, id, 0)
    else
        SD_AOU_waveformLoad(ins.index, temp_id, id, 0)
    end
    new_waveform = Waveform(waveformValues, name)
    ins.waveforms[id] = new_waveform
    return ins.waveforms[id]
end

function load_waveform(ins::InsAWGM320XA, waveformFile::String, id::Integer,
                       name::AbstractString = string(id))
    temp_id = SD_Wave_newFromFile(waveformFile)
    if haskey(ins.waveforms, id)
        SD_AOU_waveformReLoad(ins.index, temp_id, id, 0)
    else
        SD_AOU_waveformLoad(ins.index, temp_id, id, 0)
    end
    #read csv file and extract waveformValues; NEEDS WORK
    temp_data = DataFrames.readtable(waveformFile) #how you read CSV files
    waveformValues = convert(Array, temp_data)
    new_waveform = Waveform(waveformValues, name)

    ins.waveforms[id] = new_waveform
    return ins.waveforms[id]
end

"""
    queue_waveform(ins::InsAWGM320XA, id::Integer, ch::Integer, trigger_mode::Symbol;
                  repetitions::Integer = 1, delay::Integer = 0, prescaler::Integer = 0 )
    queue_waveform(ins::InsAWGM320XA, id::Integer, ch::Integer, trigger_mode::Symbol;
                   repetitions::Integer = 1, delay::Integer = 0, prescaler::Integer = 0 )

Queues a waveform in a channel of the AWG either by a passed `Waveform` object
or the waveform id. It also takes values for configuration settings pertaining
to when and how the waveform will be generated and outputted, such as trigger mode,
number of repititions, delay between the trigger and generation, and the prescaler
value for the outputted waveform. While the channel and trigger_mode must be specified,
the other settings are used as keyword arguments with standard values (chosen by me).
"""
function queue_waveform end

function queue_waveform(ins::InsAWGM320XA, id::Integer, ch::Integer,
                        trigger_mode::Symbol; repetitions::Integer = 1,
                        delay::Integer = 0, prescaler::Integer = 0 )
    SD_AOU_AWGqueueWaveform(ins.index, ch, id,
                            symbol_to_keysight(trigger_mode), delay,
                            repetitions, prescaler)
    waveform = ins.waveforms[id]
    waveform.ch_properties[ch][WavTrigMode] = trigger_mode
    waveform.ch_properties[ch][WavDelay] = delay
    waveform.ch_properties[ch][WavRepetitions] = repetitions
    waveform.ch_properties[ch][WavPrescaler] = prescaler
    next_queue_position = sort(collect(keys(ins.channels[Queue])))[end] + 1
    ins.channels[ch][Queue][next_queue_position] = id
    nothing
end

function queue_waveform(ins::InsAWGM320XA, wav::Waveform, ch::Integer,
                        trigger_mode::Symbol; repetitions::Integer = 1,
                        delay::Integer = 0, prescaler::Integer = 0)
    #finding the id of the waveform object with which the waveform was loaded to RAM
    for key in keys(ins.waveforms)
        if ins.waveforms[key] == wav
            id = key
            break
        end
    end
    queue_waveform(ins, id, ch, trigger_mode; repetitions = repititions,
                    delay = delay, prescaler = prescaler)
    nothing
end

"""
    queue_sequence(ins::InsAWGM320XA ,ch::Interger, wavsForQueue::Vector{Waveform},
                            trigger_mode::Symbol = :Software_HVI)
    queue_sequence(ins::InsAWGM320XA ,ch::Interger, wavsForQueue::Vector{Waveform},
                            trigger_mode::Symbol = :Software_HVI)
    queue_sequence(ins::InsAWGM320XA ,ch::Interger, wavsForQueue::Vector{Waveform},
                            trigger_mode::Symbol = :Software_HVI)
    queue_sequence(ins::InsAWGM320XA ,ch::Interger, wavsForQueue::Vector{Waveform},
                            trigger_mode::Symbol = :Software_HVI)

Queues a sequence of waveforms into the queue of channel `ch`. The sequence of
waveforms can either be a tuple or vector, of either waveform id's or waveform
objects. The waveforms are queued in the order that they are stored in the passed
collection object. `trigger_mode` only refers to the `WavTrigMode` of the first
waveform of the sequence; the subsequent waveforms have `WavTrigMode` equal to `:Auto`;
that is, once the first waveform is triggered, the subsequent waveforms are generated
automatically one after another without delay.
"""
function queue_sequence end

# I flesh out the method with wavsForQueue::Vector{Waveform}, rather than the other
# ones, because it is easier/convenient to convert other wavsForQueue types to this type
function queue_sequence(ins::InsAWGM320XA ,ch::Interger, wavsForQueue::Vector{Waveform},
                        trigger_mode::Symbol = :Software_HVI)
    queue_waveform(ins, wavsForQueue[1], ch::Integer, trigger_mode)
    for i=2::size(wavsForQueue)[1]
        queue_waveform(ins, wavsForQueue[i], ch::Integer, :Auto)
    end
    nothing
end

function queue_sequence(ins::InsAWGM320XA ,ch::Interger, wavsForQueue::Vararg{Waveform},
                        trigger_mode::Symbol = :Software_HVI)
    wavsForQueue = collect(wavsForQueue) #turn tuple of waveforms into vector of waveforms
    #calling upon wavsForQueue::Vector{Waveform} method
    queue_sequence(ins, ch, wavsForQueue, trigger_mode)
    nothing
end

function queue_sequence(ins::InsAWGM320XA ,ch::Interger, wavsForQueue::Vector{Integer},
                        trigger_mode::Symbol = :Software_HVI)
    wavsForQueue = map(x-->ins.waveforms[x], wavsForQueue)
    #calling upon wavsForQueue::Vector{Waveform} method
    queue_sequence(ins, ch, wavsForQueue, trigger_mode)
    nothing
end

function queue_sequence(ins::InsAWGM320XA ,ch::Interger, wavsForQueue::Vararg{Integer},
                        trigger_mode::Symbol = :Software_HVI)
    wavsForQueue = collect(wavsForQueue) #turn tuple of integers into vector of integers
    #calling upon wavsForQueue::Vector{Integer} method
    queue_sequence(ins, ch, wavsForQueue, trigger_mode)
    nothing
end

"""
    queue_flush(ins::InsAWGM320XA, ch::Integer)

Empties the queue of an AWG channel. This function both: uses the native C
`SD_AOU_AWGflush` function to empty the queue in the instrument, and it re-initializes
`ins.channels[ch][Queue]` dictionary as a blank dictionary, erasing the record of the
queue in the object as well.
"""
function queue_flush(ins::InsAWGM320XA, ch::Integer)
    SD_AOU_AWGflush(ins.index, ch)
    ins.channels[ch][Queue] = Dict{Int, Int}()
    for waveform in ins.waveforms
        ch_properties[ch] = Dict{Any, Any}()
    end
    nothing
end

"""
    waveforms_flush(ins::InsAWGM320XA)

Erases all waveforms stored in the RAM of the AWG, and empties the queue of
all the channels. This function both: uses the native C `SD_AOU_waveformFlush`
function to empty the erase the RAM and empty the queues in the instrument,
it re-initializes `ins.channels[ch][Queue]` dictionary as a blank dictionary for
all channels, erasing the record of the queue in the `InsAWGM30XA` object as well,
and re-initializes `ins.waveforms` as a blank dictionary
"""
function waveforms_flush(ins::InsAWGM320XA)
    SD_AOU_waveformFlush(ins.index)
    ins.waveforms = Dict{Int, Waveform}()
    for ch in keys(ins.channels)
        ins.channels[ch][Queue] = Dict{Int,Int}()
    end
    nothing
end