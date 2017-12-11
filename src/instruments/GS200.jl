module GS200
import Base: getindex, setindex!
import VISA
importall InstrumentControl

export RampStim

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Float64, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

@generate_all(InstrumentControl.meta["GS200"])

function ramp(yoko::InsGS200, target_V::Real, stepsize::Real = 0.001) #defining function to change DC voltage in mV steps, instead of all at once
    present = yoko[SourceLevel]
    if target_V != present
        rampvals = present:sign(target_V - present)*stepsize:target_V
        for i in 1:length(rampvals)
            yoko[SourceLevel] = rampvals[i]
        end
    end
end

"""
Stimulus for sourcing voltage in Yokogawa DC source
"""
type RampStim <: Stimulus #defining stimulus object to change output voltage on DC source
    ins::InsGS200
    axisname::Symbol
    axislabel::String
end

RampStim(ins::InsGS200; axisname = :ramp, axislabel="Voltage bias") = RampStim(ins, axisname, axislabel)
source(stim::RampStim, voltage) = ramp(stim.ins,voltage) #source function for RampStim, basically just calls ramp function

end
