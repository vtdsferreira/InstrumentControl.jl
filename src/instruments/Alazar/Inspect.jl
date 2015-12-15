## Auxiliary IO

function inspect(a::InstrumentAlazar, ::Type{AlazarAux})
    AlazarAux(a,a.auxIOMode)
end

## Channels ########

inspect(a::InstrumentAlazar, ::Type{AlazarChannel}) =
    AlazarChannel(a,a.acquisitionChannel)

inspect(a::InstrumentAlazar, ::Type{ChannelCount}) = a.channelCount

## Data packing #####

function inspect{T<:AlazarChannel}(a::InstrumentAlazar,
        ::Type{AlazarDataPacking}, ch::Type{T})
    ch == AlazarChannel && error("Specify a particular channel.")

    arr = Array{Clong}(1)
    arr[1] = 0

    r = @eh2 AlazarGetParameter(a.handle, code(a,ch), Alazar.PACK_MODE, arr)
    AlazarDataPacking(a,arr[1])
end

function inspect(a::InstrumentAlazar, ::Type{SampleRate})
    a.sampleRate > 0x80 ? float(a.sampleRate) :
        float(samplerate(SampleRate(a,a.sampleRate)))
end

function inspect(a::InstrumentAlazar, ::Type{SampleMemoryPerChannel})
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return memorysize_samples[1]
end
