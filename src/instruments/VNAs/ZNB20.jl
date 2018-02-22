module ZNB20

export InsZNB20
export SParamSweep

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

mutable struct InsZNB20 <: Instrument
    vi::(VISA.ViSession)
    writeTerminator::AbstractString
    model::AbstractString

    InsZNB20(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        ins[WriteTermCharEnable] = true
        write(ins, "*RST") #reset the instrument; this makes a default channel 1 with a default trace
        write(ins, "CONF:CHAN1:TRAC:REN "*quoted("MyTrace")) #renames the default trace
        write(ins, "INIT1:CONT OFF") #turn off continuous sweep in channel 1
        write(ins, "SYST:DISP:UPD ON") #displays the trace on the Instrument. "Format" instrument propety changes units of display
        write(ins, "FORM:DATA REAL,64") #setting the transfer format to FLoat64
        return ins
    end
end

@generate_all(InstrumentControl.meta["ZNB20"])

mutable struct SParamSweep <: Response
    ins::InsZNB20
    Sparam::String
end

function measure(s::SParamSweep)
    write(s.ins, "CALC1:PAR:MEAS " *quoted("MyTrace")*", "*quoted(s.Sparam)) #assign a measurement to a trace
    write(s.ins, "INIT1:CONT OFF") #turn off continuous sweep in channel 1
    write(s.ins, "DISP:WIND1:TRAC:EFE "*quoted("MyTrace"))
    write(s.ins, "INIT1") #initiate single sweep
    sleep(s.ins[SweepTime]) #wait for sweep to be over before getting data
    npts = s.ins[NumPoints]
    freqs = linspace(s.ins[FrequencyStart], s.ins[FrequencyStop], npts)
    array = getdata(s.ins, s.ins[TransferFormat], "CALC1:DATA? SDAT") #get data from instrument
    data = [Complex{Float64}(array[i],array[i+1]) for i in 1:2:length(array)] #reformatting
    result = AxisArray(data, Axis{:Frequency}(freqs))
    write(s.ins, "DISP:TRAC:SHOW "*quoted("MyTrace")*", ON; *WAI") #display new trace
    write(s.ins, "DISP:WIND:TRAC:Y:AUTO ONCE") #autoscale
    write(s.ins, "DISP:TRAC:SHOW "*quoted("MyTrace")*", ON; *WAI") #display new trace (need twice to actually display?)
    return result
end

## Other commands

"""
[MMEMory:CDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/d36e87010.htm)

Change directories. Pass "~" for default.
"""
function cd(ins::InsZNB20, dir::AbstractString)
    if dir == "~"
        write(ins, "MMEMory:CDIRectory DEFault")
    else
        write(ins, "MMEMory:CDIRectory "*quoted(dir))
    end
end


"""
[MMEMory:CDIRectory?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/d36e87010.htm)

Print the working directory.
"""
function pwd(ins::InsZNB20)
    unquoted(ask(ins, "MMEMory:CDIRectory?"))
end

end
