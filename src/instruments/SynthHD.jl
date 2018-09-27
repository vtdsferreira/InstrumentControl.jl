module SynthHD
using SerialPorts
export SynthHD
import Base: getindex, setindex!
importall InstrumentControl     # All the stuff in InstrumentDefs, etc.

mutable struct InsSynthHD <: Instrument
    s::SerialPort
end

make(::InsSynthHD) = "Windfreak"
model(::InsSynthHD) = "SynthHD"

setindex!(ins::InsSynthHD, v::Real, ::Type{Frequency}) =
    write(ins.s, @sprintf "f%0.7f" v/1e6)

setindex!(ins::InsSynthHD, v::Real, ::Type{PowerLevel}) =
    write(ins.s, @sprintf "W%0.3f" v)

function getindex(ins::InsSynthHD, ::Type{Frequency})
    write(ins.s, "f?")
    sleep(0.1)
    float(strip(readavailable(ins.s)))*1e6
end

function getindex(ins::InsSynthHD, ::Type{PowerLevel})
    write(ins.s, "W?")
    sleep(0.1)
    float(strip(readavailable(ins.s)))
end

end
