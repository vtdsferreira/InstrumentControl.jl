
<a id='Implementation-overview-1'></a>

# Implementation overview


<a id='Code-organization-1'></a>

## Code organization


  * Each instrument is defined within its own module, a submodule of `PainterQB`. Each instrument is a subtype of `InstrumentVISA <: Instrument`. By convention, instrument model numbers are used for module definitions (e.g. `AWG5014C`), so type names have "Ins" prepended (e.g. `InsAWG5014`).
  * `InstrumentVISA` and associated functions are defined in `src/VISA.jl`.
  * Low-level wrappers for shared libraries are kept in their own packages (e.g. `VISA` and `Alazar` calls). This way, at least some code can be reused if someone else does not want to use our codebase.
  * Early instrument definitions and functions like `Instrument` and `InstrumentException` are defined in `src/Definitions.jl`. If there is ever trouble with `InstrumentProperty` subtypes not being defined by the time they are used in a function, they can be defined and exported manually here.
  * `export` statements from an instrument submodule are not currently exported from `PainterQB`. Therefore you may want to type `using PainterQB.AWG5014C` when using the AWG, for instance.


<a id='Metaprogramming-for-VISA-instruments-1'></a>

## Metaprogramming for VISA instruments


Many commercial instruments support a common communications protocol and command syntax (VISA and SCPI respectively). For such instruments, methods for `setindex!` and `getindex` can be generated with metaprogramming, rather than typing them out explicitly.


The file `src/Metaprogramming.jl` is used heavily for code generation based on JSON template files. Since much of the logic for talking to instruments is the same between VISA instruments, in some cases no code needs to be written to control a new instrument provided an appropriate template file is prepared. The metaprogramming functions are described below although they are not intended to be used interactively.

<a id='PainterQB.insjson' href='#PainterQB.insjson'>#</a>
**`PainterQB.insjson`** &mdash; *Function*.

---


`insjson(file::AbstractString)`

Parses a JSON file with a standardized schema to describe how to control an instrument.

Here is an example of a valid JSON file with valid schema for parsing:

```json
{
    "instrument":{
            "module":"E5071C",
            "type":"InsE5071C",
            "make":"Keysight",
            "model":"E5071C",
            "writeterminator":"\n"
    },
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

After loading with `JSON.parse`, all dictionary keys are converted to symbols. The `instrument` dictionary is described in the [`generate_instruments`](implementation.md#PainterQB.generate_instruments) documentation. The `properties` array contains one or more dictionaries, each with keys:

  * `cmd`: Specifies what must be sent to the instrument (it should be terminated with "?" for query-only). The lower-case characters are replaced by infix arguments.
  * `type`: Specifies the `InstrumentProperty` subtype to use this command. Will be parsed and evaluated.
  * `values`: Specifies the required arguments for `setindex!` which will appear after `cmd` in the string sent to the instrument.
  * `infixes`: Specifies the infix arguments in `cmd`. Symbol names must match infix arguments. This key is not required if there are no infixes.
  * `doc`: Specifies documentation for the generated Julia functions. This key is not required if there is no documentation. This is used not only for interactive help but also in generating the documentation you are reading.

The value of the `properties.type` field and entries in the `properties.values` and `properties.infixes` arrays are parsed by Julia into expressions or symbols for further manipulation.

`insjson{T<:Instrument}(::Type{T})`

Simple wrapper to call `insjson` on the appropriate file path for a given instrument type.

<a id='PainterQB.generate_all' href='#PainterQB.generate_all'>#</a>
**`PainterQB.generate_all`** &mdash; *Function*.

---


`generate_all(metadata)`

This function takes a dictionary of instrument metadata, typically obtained from a call to [`insjson`](implementation.md#PainterQB.insjson). It will go through the following steps:

1. [`generate_instruments`](implementation.md#PainterQB.generate_instruments) part 1: If the module for this instrument does not already exist, generate it and import required modules and symbols.
2. [`generate_instruments`](implementation.md#PainterQB.generate_instruments) part 2: Define the `Instrument` subtype and the `make` and `model` methods (`make` and `model` are defined in `src/Definitions.jl`). Export the subtype.
3. [`generate_properties`](implementation.md#PainterQB.generate_properties): Generate instrument properties if they do not exist already, and do any necessary importing and exporting.
4. [`generate_handlers`](implementation.md#PainterQB.generate_handlers): Generate "handler" methods to convert between symbols and SCPI string args.
5. [`generate_inspect`](implementation.md#PainterQB.generate_inspect): Generate `getindex` methods for instrument properties.
6. [`generate_configure`](implementation.md#PainterQB.generate_configure): Generate `setindex!` methods for instrument properties.

`generate_all` should be called near the start of an instrument's .jl file, if one exists. It is not required to have a source file for each instrument if the automatically generated code is sufficient.

<a id='PainterQB.generate_instruments' href='#PainterQB.generate_instruments'>#</a>
**`PainterQB.generate_instruments`** &mdash; *Function*.

---


`generate_instruments(metadata)`

This function takes a dictionary of metadata, typically obtained from a call to [`insjson`](implementation.md#PainterQB.insjson). It operates on the `:instrument` field of the dictionary which is expected to have the following structure:

  * `module`: The module name. Can already exist but is created if it does not. This field is converted from a string to a `Symbol` by [`insjson`](implementation.md#PainterQB.insjson).
  * `type`: The name of the type to create for the new instrument. This field is converted from a string to a `Symbol` by [`insjson`](implementation.md#PainterQB.insjson).
  * `super`: This field is optional. If provided it will be the supertype of the new instrument type, otherwise the supertype will be `InstrumentVISA`. This field is converted from a string to a `Symbol` by [`insjson`](implementation.md#PainterQB.insjson).
  * `make`: The make of the instrument, e.g. Keysight, Tektronix, etc.
  * `model`: The model of the instrument, e.g. E5071C, AWG5014C, etc.
  * `writeterminator`: Write termination string for sending SCPI commands.

By convention we typically have the module name be the same as the model name, and the type is just the model prefixed by "Ins", e.g. `InsE5071C`. This is not required.

<a id='PainterQB.generate_properties' href='#PainterQB.generate_properties'>#</a>
**`PainterQB.generate_properties`** &mdash; *Function*.

---


`generate_properties{S<:Instrument}(instype::Type{S}, p)`

This function takes an `Instrument` subtype `instype`, and a property dictionary `p`. The property dictionary is built out of an auxiliary JSON file described above.

This function is responsible for generating the `InstrumentProperty` subtypes to use with `getindex` and `setindex!` if they have not been defined already. Ordinarily these types are defined in the PainterQB module but if a really generic name is desired that makes sense for a class of instruments (e.g. `VNA.Format`) then the `Format` subtype is defined in the `PainterQB.VNA` module. The defined subtype is then imported into the module where the `instype` is defined.

If you an encounter an error where it appears like the subtypes were not defined, it may be that they are being referenced from a module that did an `import` statement too soon, before all relevant `InstrumentProperty` subtypes were defined and exported. Ordinarily this is not a problem.

<a id='PainterQB.generate_handlers' href='#PainterQB.generate_handlers'>#</a>
**`PainterQB.generate_handlers`** &mdash; *Function*.

---


`generate_handlers{S<:Instrument}(instype::Type{S}, p)`

This function takes an `Instrument` subtype `instype`, and a property dictionary `p`. The property dictionary is built out of an auxiliary JSON file described above.

In some cases, an instrument command does not except numerical arguments but rather a small set of options. Here is an example of the property dictionary (prior to parsing) for such a command, which sets/gets the format for a given channel and trace on the E5071C vector network analyzer:

```json
{
    "cmd":":CALCch:TRACtr:FORM",
    "type":"VNA.Format",
    "values":[
        "v::Symbol in symbols"
    ],
    "symbols":{
        "LogMagnitude":"MLOG",
        "Phase":"PHAS",
        "GroupDelay":"GDEL",
        "SmithLinear":"SLIN",
        "SmithLog":"SLOG",
        "SmithComplex":"SCOM",
        "Smith":"SMIT",
        "SmithAdmittance":"SADM",
        "PolarLinear":"PLIN",
        "PolarLog":"PLOG",
        "PolarComplex":"POL",
        "LinearMagnitude":"MLIN",
        "SWR":"SWR",
        "RealPart":"REAL",
        "ImagPart":"IMAG",
        "ExpandedPhase":"UPH",
        "PositivePhase":"PPH"
    },
    "infixes":[
        "ch::Integer=1",
        "tr::Integer=1"
    ],
    "doc":"Hey"
}
```

We see here that the `values` key is saying that we are only going to accept `Symbol` type for our `setindex!` method and the symbol has to come out of `symbols`, a dictionary that is defined on the next line. The keys of this dictionary are going to be interpreted as symbols (e.g. `:LogMagnitude`) and the values are just ASCII strings to be sent to the instrument.

`generate_handlers` makes a bidirectional mapping between the symbols and the strings. In this example, this is accomplished as follows:

```jl
symbols(ins::E5071C, ::Type{VNA.Format}, v::Symbol) = symbols(ins, VNA.Format, Val{v})
symbols(ins::E5071C, ::Type{VNA.Format}, ::Type{Val{:LogMagnitude}}) = "MLOG" # ... etc. for each symbol.

VNA.Format(ins::E5071C, s::AbstractString) = VNA.Format(ins, Val{symbol(s)})
VNA.Format(ins::E5071C, ::Type{Val{symbol("MLOG")}}) = :LogMagnitude # ... etc. for each symbol.
```

The above methods will be defined in the E5071C module. Note that the function `symbols` has its name chosen based on the dictionary name in the JSON file. Since this function is not exported from the instrument's module there should be few namespace worries and we maintain future flexibliity.

<a id='PainterQB.generate_configure' href='#PainterQB.generate_configure'>#</a>
**`PainterQB.generate_configure`** &mdash; *Function*.

---


`generate_configure{S<:Instrument}(instype::Type{S}, p)`

This function takes an `Instrument` subtype `instype`, and a property dictionary `p`. The property dictionary is built out of an auxiliary JSON file described above.

This function generates and documents a method for `getindex`. The method is defined in the module where the instrument type was defined.

<a id='PainterQB.generate_inspect' href='#PainterQB.generate_inspect'>#</a>
**`PainterQB.generate_inspect`** &mdash; *Function*.

---


`generate_inspect{S<:Instrument}(instype::Type{S}, p)`

This function takes an `Instrument` subtype `instype`, and a property dictionary `p`. The property dictionary is built out of an auxiliary JSON file described above.

This function generates and documents a method for `getindex`. The method is defined in the module where the instrument type was defined.

