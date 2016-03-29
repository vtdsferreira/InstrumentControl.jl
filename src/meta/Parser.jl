import JSON

export insjson

"""
`insjson{T<:Instrument}(::Type{T})`

Simple wrapper to call `insjson` on the appropriate file path for a given
instrument type.
"""
function insjson{T<:Instrument}(::Type{T})
    # Get the name of the instrument by taking the type name (without module prefixes!)
    insname = split(string(T.name),".")[end]
    insjson(insname*".json")
end

"""
`insjson(file::AbstractString)`

Parses a JSON file with a standardized schema to describe how to control
an instrument.

Here is an example of a valid JSON file with valid schema for parsing:

```json
{
    "properties":[
        {
            "cmd":":CALCch:TRACtr:CORR:EDEL:TIME",
            "type":"VNA.ElectricalDelay",
            "values":[
                "v::Real"
            ],
            "infixes":[
                "ch::Integer=1",
                "tr::Integer=1"
            ],
            "doc": "My documentation"
        }
    ]
}
```

- `cmd`: Specifies what must be sent to the instrument (it should be
terminated with "?" for query-only). The lower-case characters are replaced
by infix arguments.
- `type`: Specifies the `InstrumentProperty` subtype to use this command. Will be
parsed and evaluated.
- `values`: Specifies the required arguments for `setindex!` which will
appear after `cmd` in the string sent to the instrument.
- `infixes`: Specifies the infix arguments in `cmd`. Symbol names must match
infix arguments.
- `doc`: Specifies documentation for the generated Julia functions.
"""
function insjson(file::AbstractString)
    j = JSON.parsefile(file)

    # Prefer symbols as keys instead of strings
    j = convert(Dict{Symbol,Any}, j)

    !haskey(j, :properties) && error("Unexpected format in JSON file.")

    # Tidy up (and validate?) the properties dictionary
    for i in eachindex(j[:properties])
        # Prefer symbols instead of strings
        j[:properties][i] = convert(Dict{Symbol,Any}, j[:properties][i])
        p = j[:properties][i]
        p[:type] = parse(p[:type])

        p[:values] = convert(Array{Expr,1}, map(parse, p[:values]))

        !haskey(p, :infixes) && (p[:infixes] = [])
        !haskey(p, :doc) && (p[:doc] = "Undocumented.")
        p[:infixes] = convert(Array{Expr,1}, map(parse, p[:infixes]))
        for k in p[:infixes]
            # `parse` doesn't recognize we want the equal sign to indicate
            # an optional argument, denoted by the :kw symbol.
            k.head = :kw
        end
    end

    j
end
