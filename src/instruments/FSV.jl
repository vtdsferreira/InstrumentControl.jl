module FSV

export InsFSV
export Spectrum
export autolevel

import Base: getindex, setindex!
import VISA
importall InstrumentControl
import FileIO
using ICCommon
using AxisArrays
import Base: search
import ICCommon: measure
import InstrumentControl: getdata

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Any, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)


mutable struct InsFSV <: Instrument
    vi::(VISA.ViSession)
    writeTerminator::AbstractString
    model::AbstractString
    tbo::Symbol #TransferByteOrder: I put it here because the instrument has no query for that.

    InsFSV(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        ins[WriteTermCharEnable] = true
        write(ins, "*RST") #resets the instrument
        write(ins, "INIT:CONT OFF")
        write(ins, "DISP:TRAC1 ON") #displays trace 1 on the instrument. "Format" instrument propety changes units of display
        write(ins, "FORM:DATA REAL,32") #setting the transfer format to FLoat32
        write(ins, "FORM:BORD SWAP")
        ins.tbo = :LittleEndian
        return ins
    end
end

@generate_all(InstrumentControl.meta["FSV"])

function setindex!(ins::InsFSV, tbo::Symbol, ::Type{TransferByteOrder})
    if tbo == :LittleEndian
        write(ins, "FORM:BORD SWAP")
        ins.tbo = tbo
    elseif tbo == :BigEndian
        write(ins, "FORM:BORD NORM")
        ins.tbo = tbo
    else
        error("Unexpected input.")
    end
end

function getindex(ins::InsFSV, ::Type{TransferByteOrder})
    return ins.tbo
end

function autolevel(ins::InsFSV)
    write(ins, "ADJ:LEV")
end


mutable struct Spectrum <: Response
    ins::InsFSV
end

function measure(s::Spectrum)
    write(s.ins, "INIT:CONT OFF") #turn off continuous sweep
    write(s.ins, "INIT:DISP ON")
    write(s.ins, "INIT; *WAI") #initiate single sweep
    npts = s.ins[NumPoints]
    freqs = linspace(s.ins[FrequencyStart], s.ins[FrequencyStop], npts)
    array = getdata(s.ins, s.ins[TransferFormat], "TRAC? TRACE1") #get data from instrument
    result = AxisArray(array, Axis{:Frequency}(freqs))
    return result
end

end
