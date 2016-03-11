"""
Each instrument can have a `responseDict`. For each setting of the instrument,
for instance the `ClockSource`, we need to know the correspondence between a
logical state `ExternalClock` and how the instrument encodes that logical state
(e.g. "EXT").

The `responseDict` is actually a dictionary of dictionaries. The first level keys
are like `ClockSource` and the second level keys are like "EXT", with the value
being `:ExternalClock`. Undoubtedly
this nested dictionary is "nasty" (in the technical parlance) but the dictionary
is only used for code
creation and is not used at run-time (if the code works as intended).

This method makes a lot of other functions. Given some response from an instrument,
we require a function to map that response back on to the appropiate logical state.

`ClockSource(ins::AWG5014C, res::AbstractString)`
returns an `InternalClock` or `ExternalClock` type as appropriate,
based on the logical meaning of the response.

We also want a function to generate logical states without having to know the way
they are encoded by the instrument.

`code(ins::AWG5014C, ::Type{InternalClock})` returns "INT",
with "INT" encoding how to pass this logical state to the instrument `ins`.
"""
function generate_handlers{T<:Instrument}(insType::Type{T}, responseDict::Dict)

    for (supertypeSymb in keys(responseDict))

        # e.g. code(ins::AWG5014C, InternalClock) = "INT"
        d = responseDict[supertypeSymb]
        for response in keys(d)
            fnSymb = d[response]
            @eval (code)(ins::$insType, ::Type{$fnSymb}) = $response
        end

        # e.g. ClockSource(ins::AWG5014C, "INT") = InternalClock
        @eval ($supertypeSymb)(ins::$insType, res::AbstractString) =
            (typeof(parse(res)) <: Number ?
            ($d)[parse(res)] : ($d)[res]) |> eval

        @eval ($supertypeSymb)(ins::$insType, res::Number) =
            ($d)[res] |> eval
    end

    nothing
end
