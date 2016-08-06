
## Auxiliary IO

"""
```
getindex(a::InstrumentAlazar, ::Type{AlazarAux})
```

Inspect the AUX IO mode.
"""
getindex(a::InstrumentAlazar, ::Type{AlazarAux}) = a.auxIOMode

## Channels ########

"""
```
getindex(a::InstrumentAlazar, ::Type{AlazarChannel})
```

Returns which channel(s) will be acquired.
"""
getindex(a::InstrumentAlazar, ::Type{AlazarChannel}) = a.acquisitionChannel

"""
```
getindex(a::InstrumentAlazar, ::Type{ChannelCount})
```

Returns the number of channels to acquire.
"""
getindex(a::InstrumentAlazar, ::Type{ChannelCount}) = a.channelCount

## Data packing #####

# "Inspect the data packing mode for a given channel."
# Needs to be rewritten.
function getindex{T<:AlazarChannel}(a::InstrumentAlazar,
        ::Type{AlazarDataPacking}, ch::Type{T})
    ch == AlazarChannel && error("Specify a particular channel.")

    arr = Array{Clong}(1)
    arr[1] = 0

    r = @eh2 AlazarGetParameter(a.handle, code(a,ch), Alazar.PACK_MODE, arr)
    AlazarDataPacking(a,arr[1])
end

"""
```
getindex(a::InstrumentAlazar, ::Type{SampleRate})
```

Inspect the sample rate. As currently programmed, does not distinguish
between the internal preset clock rates and otherwise.
"""
function getindex(a::InstrumentAlazar, ::Type{SampleRate})
    a.sampleRate > 0x80 ? float(a.sampleRate) :
        float(clock_code_to_rate(a.sampleRate))
end

"""
```
getindex(a::InstrumentAlazar, ::Type{SampleMemoryPerChannel})
```

Returns the memory per channel in units of samples.
"""
function getindex(a::InstrumentAlazar, ::Type{SampleMemoryPerChannel})
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return memorysize_samples[1]
end


"""
```
getindex(a::InstrumentAlazar, ::Type{TriggerEngine})
```

Returns which trigger engines cause a trigger event.
"""
getindex(a::InstrumentAlazar, ::Type{TriggerEngine}) = a.engine

"""
```
getindex(a::InstrumentAlazar, ::Type{TriggerSource})
```

Returns the trigger source for engines J and K.
"""
getindex(a::InstrumentAlazar, ::Type{TriggerSource}) = a.sourceJ, a.sourceK

"""
```
getindex(a::InstrumentAlazar, ::Type{TriggerSlope})
```

Returns the trigger slope for engines J and K
"""
getindex(a::InstrumentAlazar, ::Type{TriggerSlope}) = a.slopeJ, a.slopeK

"""
```
getindex(a::InstrumentAlazar, ::Type{TriggerLevel})
```

Returns the trigger levels for engines J and K.
"""
getindex(a::InstrumentAlazar, ::Type{TriggerLevel}) = a.levelJ, a.levelK
