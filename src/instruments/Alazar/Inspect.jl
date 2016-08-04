
## Auxiliary IO

"Inspect the AUX IO mode."
function getindex(a::InstrumentAlazar, ::Type{AlazarAux})
    AlazarAux(a,a.auxIOMode)
end

## Channels ########

"Returns which channel(s) will be acquired."
getindex(a::InstrumentAlazar, ::Type{AlazarChannel}) =
    AlazarChannel(a,a.acquisitionChannel)

"Returns the number of channels to acquire."
getindex(a::InstrumentAlazar, ::Type{ChannelCount}) = a.channelCount

## Data packing #####

"Inspect the data packing mode for a given channel."
function getindex{T<:AlazarChannel}(a::InstrumentAlazar,
        ::Type{AlazarDataPacking}, ch::Type{T})
    ch == AlazarChannel && error("Specify a particular channel.")

    arr = Array{Clong}(1)
    arr[1] = 0

    r = @eh2 AlazarGetParameter(a.handle, code(a,ch), Alazar.PACK_MODE, arr)
    AlazarDataPacking(a,arr[1])
end

"Inspect the sample rate. As currently programmed, does not distinguish
between the internal preset clock rates and otherwise."
function getindex(a::InstrumentAlazar, ::Type{SampleRate})
    a.sampleRate > 0x80 ? float(a.sampleRate) :
        float(samplerate(SampleRate(a,a.sampleRate)))
end

"Returns the memory per channel in units of samples."
function getindex(a::InstrumentAlazar, ::Type{SampleMemoryPerChannel})
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return memorysize_samples[1]
end
