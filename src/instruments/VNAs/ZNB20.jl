module ZNB20

import Base: getindex, setindex!
import VISA
importall InstrumentControl
import FileIO
import InstrumentControl: getdata

@generate_all(InstrumentControl.meta["ZNB20"])

export ZNB20
export SParamSweep


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
        write(ins, "SYST:DISP:UPD ON") #displays the trace on the Instrument. "Format" instrument propety changes units of display
        return ins
    end
end

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
    npts = x.ins[NumPoints]
    freqs = linspace(s.ins[FrequencyStart], s.ins[FrequencyStop], npts)
    result = AxisArray(Array{Complex{Float64}}(npts, 1),
        Axis{:f}(freqs), Axis{:sparam}(Symbol(s.Sparam)))
    array = getdata(s.ins, s.ins[TransferFormat], "CALC1:DATA? SDAT") #get data from instrument
    data = [Complex{T}(array[i],array[i+1]) for i in 1:2:length(array)] #reformatting
    data = reinterpret(Complex{Float64}, data)
    result[Axis{:sparam}(Symbol(s.Sparam))] = data
    result = transpose(result)
    return result
end

## Other commands

"""
[MMEMory:CDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/d36e87010.htm)

Change directories. Pass "~" for default.
"""
function cd(ins::ZNB20, dir::AbstractString)
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
function pwd(ins::ZNB20)
    unquoted(ask(ins, "MMEMory:CDIRectory?"))
end

end
