import Base: getindex

# overloaded getindex method for each channel-specific instrument property:
# acesses ins.channels for current configuration information
function getindex(ins::InsDigitizerM3102A, ::Type{T},
                  ch::Integer) where {T<:InstrumentProperty}
    return ins.channels[ch][T]
end

# overloaded getindex method for either non-channel specific properties, or a
# query for the channel specific properties of ALL channels, returned as an array,
# depending on the passed type T
function getindex(ins::InsDigitizerM3102A,
                  ::Type{T}) where {T<:InstrumentProperty}
    if T == SampleRate
        return 500e6   #@KSerror_handler SD_AIN_clockGetFrequency(ins.ID)  this function not working though
    else
        channels_list=[]
        for ch in sort(collect(keys(ins.channels)))
            push!(channels_list, ins[T, ch])
        end
        return channels_list
    end
end
