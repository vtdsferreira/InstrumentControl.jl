module FSV

import Base: getindex, setindex!
import VISA
importall InstrumentControl
import FileIO
import InstrumentControl: getdata

@generate_all(InstrumentControl.meta["FSV"])

export InsFSV
export Spectrum


mutable struct InsZNB20 <: Instrument
    vi::(VISA.ViSession)
    writeTerminator::AbstractString
    model::AbstractString

    InsFSV(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        ins[WriteTermCharEnable] = true
        write(ins, "*RST") #resets the instrument
        write(ins, "DISP:TRAC1 ON") #displays trace 1 on the instrument. "Format" instrument propety changes units of display
        return ins
    end
end

mutable struct Spectrum <: Response
    ins::InsFSV
end

function measure(s::Spectrum)
    write(s.ins, "INIT:CONT OFF") #turn off continuous sweep
    write(s.ins, "INIT:DISP ON")
    write(s.ins, "INIT") #initiate single sweep
    sleep(s.ins[SweepTime]) #wait for sweep to be over before getting data
    npts = x.ins[NumPoints]
    freqs = linspace(s.ins[FrequencyStart], s.ins[FrequencyStop], npts)
    result = AxisArray(Array{Complex{Float64}}(npts, 1),
        Axis{:f}(freqs), Axis{:power}(:Power))
    array = getdata(s.ins, s.ins[TransferFormat], "TRAC? TRACE1") #get data from instrument
    result[Axis{:power}(:Power)] = array
    result = transpose(result)
    return result
end
