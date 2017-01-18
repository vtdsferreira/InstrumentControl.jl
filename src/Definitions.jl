import Base: show, showerror

export Averaging
export AveragingFactor
export AveragingTrigger
export FrequencyStart, FrequencyStop
export SampleRate, SweepTime
export Timeout
export InstrumentException

# Miscellaneous stuff
export VNA
export make, model

"How to display an instrument, e.g. in an error."
show(io::IO, x::Instrument) = print(io, make(x), " ", model(x))

"Returns the instrument's manufacturer."
function make end

"Returns the instrument's model."
function model end

abstract Averaging <: InstrumentProperty
abstract AveragingFactor <: InstrumentProperty
abstract AveragingTrigger <: InstrumentProperty

abstract FrequencyStart <: InstrumentProperty
abstract FrequencyStop <: InstrumentProperty

"The sample rate for digitizing, synthesizing, etc."
abstract SampleRate <: InstrumentProperty

abstract SweepTime <: InstrumentProperty

"Time to wait for an instrument to reply before bailing out."
abstract Timeout <: InstrumentProperty

"""
Exception to be thrown by an instrument. Fields include the instrument in error
`ins::Instrument`, the error code `val::Int64`, and a `humanReadable` Unicode
string.
"""
immutable InstrumentException <: Exception
    ins::Instrument
    val::Array{Int,1}
    humanReadable::Array{AbstractString,1}
end

"Simple method for when there is just one error."
InstrumentException(ins::Instrument, val::Integer, hr::AbstractString) =
    InstrumentException(ins, Int[val], AbstractString[hr])

function showerror(io::IO, e::InstrumentException)
    if length(e.val) != length(e.humanReadable)
        print(io, "Error in determining the errors of $(e.ins).")
    else
        println(io,"Instrument $(e.ins) had errors:")
        for i in 1:length(e.val)
            println(io,"    $((e.val)[i]): $((e.humanReadable)[i])")
        end
    end
end
