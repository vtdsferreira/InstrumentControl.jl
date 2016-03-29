import Base: show, showerror

export Instrument
export InstrumentProperty

export SampleRate
export InstrumentException

# Miscellaneous stuff
export VNA
export make, model
export stimdata

"""
Abstract supertype representing an instrument.
"""
abstract Instrument

"How to display an instrument, e.g. in an error."
show(io::IO, x::Instrument) = print(io, make(x), " ", model(x))

"Returns the instrument's manufacturer."
function make end

"Returns the instrument's model."
function model end

"""
Abstract type representing communications with an instrument.
Subtypes of `InstrumentProperty` can be configured or inspect using
`setindex!` or `getindex`.
"""
abstract InstrumentProperty

"The sample rate for digitizing, synthesizing, etc."
abstract SampleRate <: InstrumentProperty

"""
Exception to be thrown by an instrument. Fields include the instrument in error
`ins::Instrument`, the error code `val::Int64`, and a `humanReadable` Unicode
string.
"""
immutable InstrumentException <: Exception
    ins::Instrument
    val::Array{Int,1}
    humanReadable::Array{UTF8String,1}
end

"Simple method for when there is just one error."
InstrumentException(ins::Instrument, val::Integer, hr::AbstractString) =
    InstrumentException(ins, Int[val], UTF8String[hr])

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

"Read the stimulus values."
function stimdata end
