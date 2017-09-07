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
export memory_size

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

function load_waveform(ins::InsAWGM320XA, waveform::Waveform, id::Integer,
                       name::AbstractString = waveform.name; waveform_type::Symbol = :Analog32)
    waveformValues = waveform.waveformValues
    length = size(waveformValues)
    temp_id = SD_Wave_newFromArrayDouble(symbol_to_Keysight(waveform_type), length,
              waveformValues) #when loading the waveform to the AWG RAM, this id is overwritten
    temp_id < 0 && throw(InstrumentException(ins, temp_id))
    if haskey(ins.waveforms, id)
        @error_handler SD_AOU_waveformReLoad(ins.index, temp_id, id)
    else
        @error_handler SD_AOU_waveformLoad(ins.index, temp_id, id)
    end
    ins.waveforms[id] = waveform
    return ins.waveforms[id]
end

function load_waveform(ins::InsAWGM320XA, waveformValues::Array{Float64}, id::Integer,
                       name::AbstractString = string(id); waveform_type::Symbol = :Analog32)
    waveform = Waveform(waveformValues, name)
    load_waveform(ins, waveform, id, name, waveform_type = waveform_type)
end

function load_waveform(ins::InsAWGM320XA, waveformFile::String, id::Integer,
                       name::AbstractString = string(id))
    temp_id = SD_Wave_newFromFile(waveformFile)
    temp_id < 0 && throw(InstrumentException(ins, temp_id))
    if haskey(ins.waveforms, id)
        @error_handler SD_AOU_waveformReLoad(ins.index, temp_id, id)
    else
        @error_handler SD_AOU_waveformLoad(ins.index, temp_id, id)
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
    @error_handler SD_AOU_AWGqueueWaveform(ins.index, ch, id,
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
    queue_sequence(ins::InsAWGM320XA ,ch::Integer, trigger_mode::Symbol,
                    wavsForQueue::Vector{Waveform})

    queue_sequence(ins::InsAWGM320XA ,ch::Integer, trigger_mode::Symbol,
                    wavsForQueue::Vector{Waveform})

    queue_sequence(ins::InsAWGM320XA ,ch::Integer, trigger_mode::Symbol,
                    wavsForQueue::Vector{Waveform})

    queue_sequence(ins::InsAWGM320XA ,ch::Integer, trigger_mode::Symbol,
                    wavsForQueue::Vector{Waveform})

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
function queue_sequence(ins::InsAWGM320XA ,ch::Integer, trigger_mode::Symbol,
                        wavsForQueue::Vector{Waveform})
    queue_waveform(ins, wavsForQueue[1], ch::Integer, trigger_mode)
    for i=2::size(wavsForQueue)[1]
        queue_waveform(ins, wavsForQueue[i], ch::Integer, :Auto)
    end
    nothing
end

function queue_sequence(ins::InsAWGM320XA ,ch::Integer, trigger_mode::Symbol,
                        wavsForQueue::Vararg{Waveform})
    wavsForQueue = collect(wavsForQueue) #turn tuple of waveforms into vector of waveforms
    #calling upon wavsForQueue::Vector{Waveform} method
    queue_sequence(ins, ch, trigger_mode, wavsForQueue)
    nothing
end

function queue_sequence(ins::InsAWGM320XA ,ch::Integer, trigger_mode::Symbol,
                        wavsForQueue::Vector{Integer})
    wavsForQueue = map(x->ins.waveforms[x], wavsForQueue)
    #calling upon wavsForQueue::Vector{Waveform} method
    queue_sequence(ins, ch, trigger_mode, wavsForQueue)
    nothing
end

function queue_sequence(ins::InsAWGM320XA ,ch::Integer, trigger_mode::Symbol,
                        wavsForQueue::Vararg{Integer})
    wavsForQueue = collect(wavsForQueue) #turn tuple of integers into vector of integers
    #calling upon wavsForQueue::Vector{Integer} method
    queue_sequence(ins, ch, trigger_mode, wavsForQueue)
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
    @error_handler SD_AOU_AWGflush(ins.index, ch)
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
    @error_handler SD_AOU_waveformFlush(ins.index)
    ins.waveforms = Dict{Int, Waveform}()
    for ch in keys(ins.channels)
        ins.channels[ch][Queue] = Dict{Int,Int}()
    end
    nothing
end

"""
    memory_size(ins::InsAWGM320XA, wav::Waveform)
    memory_size(ins::InsAWGM320XA, id::Integer)
Obtain size of waveform in memory
"""
function memory_size end

memory_size(ins::InsAWGM320XA, id::Integer) = @error_handler SD_AOU_waveformGetMemorySize(ins.index, id)

function memory_size(ins::InsAWGM320XA, wav::Waveform)
    #finding the id of the waveform object with which the waveform was loaded to RAM
    for key in keys(ins.waveforms)
        if ins.waveforms[key] == wav
            id = key
            break
        end
    end
    return memory_size(ins, id)
end

#function that returns properties of queued waveform
function getindex(wav::Waveform, ::Type{T},
                  ch::Integer) where {T<:WaveChProperty}
    return wav.ch_properties[ch][T]
end
