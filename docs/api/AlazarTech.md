# PainterQB.AlazarModule


## Types [Exported]

---

<a id="type__alazarats9360.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.AlazarATS9360 [¶](#type__alazarats9360.1)
ATS9360 is a concrete subtype of InstrumentAlazar.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:6](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\instruments\Alazar\models\ATS9360.jl#L6)

---

<a id="type__instrumentalazar.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.InstrumentAlazar [¶](#type__instrumentalazar.1)
The InstrumentAlazar types represent an AlazarTech device on the local
system. It can be used to control configuration parameters, to
start acquisitions and to retrieve the acquired data.

Args:

  systemId (int): The board system identifier of the target
  board. Defaults to 1, which is suitable when there is only one
  board in the system.

  boardId (int): The target's board identifier in it's
  system. Defaults to 1, which is suitable when there is only one
  board in the system.



*source:*
[PainterQB\src\instruments\Alazar\Alazar.jl:53](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\instruments\Alazar\Alazar.jl#L53)


## Methods [Internal]

---

<a id="method__call.1" class="lexicon_definition"></a>
#### call(::Type{PainterQB.InstrumentException},  ins::PainterQB.AlazarModule.InstrumentAlazar,  r) [¶](#method__call.1)
Create descriptive exceptions.

*source:*
[PainterQB\src\instruments\Alazar\Errors.jl:2](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\instruments\Alazar\Errors.jl#L2)

---

<a id="method__generate_configure.1" class="lexicon_definition"></a>
#### generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty}) [¶](#method__generate_configure.1)
```
generate_configure{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, returntype...)
```

This command takes an `Instrument` subtype `InsType`, a VISA command, an
`InstrumentProperty` type, and possibly an argument. It will generate one of the
following methods in the module where `generate_inspect` is defined:

```
configure(ins::InsType, PropertySubtype)
configure(ins::InsType, Property, values..., infixes...)
```


*source:*
[PainterQB\src\Metaprogramming.jl:93](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\Metaprogramming.jl#L93)

---

<a id="method__generate_handlers.1" class="lexicon_definition"></a>
#### generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V}) [¶](#method__generate_handlers.1)
### generate_handlers

`generate_handlers{T<:Instrument}(insType::Type{T}, responseDict::Dict)`

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

This function makes a lot of other functions. Given some response from an instrument,
we require a function to map that response back on to the appropiate logical state.

`ClockSource(ins::AWG5014C, res::AbstractString)`
returns an `InternalClock` or `ExternalClock` type as appropriate,
based on the logical meaning of the response.

We also want a function to generate logical states without having to know the way
they are encoded by the instrument.

`code(ins::AWG5014C, ::Type{InternalClock})` returns "INT",
with "INT" encoding how to pass this logical state to the instrument `ins`.


*source:*
[PainterQB\src\Metaprogramming.jl:213](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\Metaprogramming.jl#L213)

---

<a id="method__generate_inspect.1" class="lexicon_definition"></a>
#### generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty},  ::Type{PainterQB.NoArgs}) [¶](#method__generate_inspect.1)
```
generate_inspect{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, returntype...)
```

This command takes an `Instrument` subtype `instype`, a VISA command, an
`InstrumentProperty` subtype `proptype`, and possibly an argument. It will
generate the following method in the module where `generate_inspect` is defined:

`inspect(ins::instype, ::Type{proptype}, infixes::Int...)`

The `infixes` variable argument allows for numbers to be inserted within the
commands, for instance in `OUTP#:FILT:FREQ`, where the `#` sign should be
replaced by an integer. The replacements are done in the order of the arguments.
Error checking is done on the number of arguments.

For a given property, `inspect` will return either an InstrumentProperty subtype,
a number, a boolean, or a string as appropriate.


*source:*
[PainterQB\src\Metaprogramming.jl:32](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\Metaprogramming.jl#L32)

---

<a id="method__generate_properties.1" class="lexicon_definition"></a>
#### generate_properties{S<:PainterQB.InstrumentProperty}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty}) [¶](#method__generate_properties.1)
Makes parametric subtypes and gives constructors. Also defines a code method.

*source:*
[PainterQB\src\Metaprogramming.jl:176](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\Metaprogramming.jl#L176)

## Macros [Internal]

---

<a id="macro___eh2.1" class="lexicon_definition"></a>
#### @eh2(expr) [¶](#macro___eh2.1)
Takes an Alazar API call and brackets it with some checking.

*source:*
[PainterQB\src\instruments\Alazar\Errors.jl:6](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\instruments\Alazar\Errors.jl#L6)

