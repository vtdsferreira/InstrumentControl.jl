# PainterQB


## Methods [Exported]

---

<a id="method__ask.1" class="lexicon_definition"></a>
#### ask(ins::PainterQB.InstrumentVISA,  msg::ASCIIString) [¶](#method__ask.1)
Idiomatic "write and read available" function with optional delay.

*source:*
[PainterQB\src\VISA.jl:63](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L63)

---

<a id="method__ask.2" class="lexicon_definition"></a>
#### ask(ins::PainterQB.InstrumentVISA,  msg::ASCIIString,  delay::Real) [¶](#method__ask.2)
Idiomatic "write and read available" function with optional delay.

*source:*
[PainterQB\src\VISA.jl:63](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L63)

---

<a id="method__binblockreadavailable.1" class="lexicon_definition"></a>
#### binblockreadavailable(ins::PainterQB.InstrumentVISA) [¶](#method__binblockreadavailable.1)
Read an entire block of bytes with properly formatted IEEE header.

*source:*
[PainterQB\src\VISA.jl:92](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L92)

---

<a id="method__binblockwrite.1" class="lexicon_definition"></a>
#### binblockwrite(ins::PainterQB.InstrumentVISA,  message::Union{ASCIIString, Array{UInt8, 1}},  data::Array{UInt8, 1}) [¶](#method__binblockwrite.1)
Write an IEEE header block followed by an arbitary sequency of bytes and the terminator.


*source:*
[PainterQB\src\VISA.jl:87](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L87)

---

<a id="method__findresources.1" class="lexicon_definition"></a>
#### findresources() [¶](#method__findresources.1)
Finds VISA resources to which we can connect. Doesn't find ethernet instruments.

*source:*
[PainterQB\src\VISA.jl:42](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L42)

---

<a id="method__findresources.2" class="lexicon_definition"></a>
#### findresources(expr::AbstractString) [¶](#method__findresources.2)
Finds VISA resources to which we can connect. Doesn't find ethernet instruments.

*source:*
[PainterQB\src\VISA.jl:42](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L42)

---

<a id="method__gpib.1" class="lexicon_definition"></a>
#### gpib(primary) [¶](#method__gpib.1)
Returns a viSession for the given GPIB address.

*source:*
[PainterQB\src\VISA.jl:45](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L45)

---

<a id="method__read.1" class="lexicon_definition"></a>
#### read(ins::PainterQB.InstrumentVISA) [¶](#method__read.1)
Read from an instrument. Strips trailing carriage returns and new lines.
Note that this function will only read so many characters (buffered).


*source:*
[PainterQB\src\VISA.jl:73](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L73)

---

<a id="method__readavailable.1" class="lexicon_definition"></a>
#### readavailable(ins::PainterQB.InstrumentVISA) [¶](#method__readavailable.1)
Keep reading from an instrument until the instrument says we are done.

*source:*
[PainterQB\src\VISA.jl:81](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L81)

---

<a id="method__tcpip_instr.1" class="lexicon_definition"></a>
#### tcpip_instr(ip) [¶](#method__tcpip_instr.1)
Returns a INSTR viSession for the given IPv4 address.

*source:*
[PainterQB\src\VISA.jl:54](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L54)

---

<a id="method__tcpip_socket.1" class="lexicon_definition"></a>
#### tcpip_socket(ip,  port) [¶](#method__tcpip_socket.1)
Returns a raw socket viSession for the given IPv4 address.

*source:*
[PainterQB\src\VISA.jl:57](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L57)

---

<a id="method__write.1" class="lexicon_definition"></a>
#### write(ins::PainterQB.InstrumentVISA,  msg::ASCIIString) [¶](#method__write.1)
Write to an instrument. Appends the instrument's write terminator.

*source:*
[PainterQB\src\VISA.jl:77](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L77)

## Types [Exported]

---

<a id="type__all.1" class="lexicon_definition"></a>
#### PainterQB.All [¶](#type__all.1)
The All type is meant to be dispatched upon and not instantiated.

*source:*
[PainterQB\src\Definitions.jl:229](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\Definitions.jl#L229)

---

<a id="type__delaystimulus.1" class="lexicon_definition"></a>
#### PainterQB.DelayStimulus [¶](#type__delaystimulus.1)
`DelayStimulus`

When sourced with a value in seconds, will wait until that many
seconds have elapsed since the DelayStimulus was initialized.


*source:*
[PainterQB\src\sourcemeasure\Time.jl:9](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\sourcemeasure\Time.jl#L9)

---

<a id="type__instrumentproperty.1" class="lexicon_definition"></a>
#### PainterQB.InstrumentProperty [¶](#type__instrumentproperty.1)
### InstrumentProperty
`abstract InstrumentProperty <: Any`

Abstract supertype representing communications with an instrument.

Each *abstract* subtype one level down should represent a logical state of the
instrument configuration, e.g. `TriggerSource` may be have concrete
subtypes `ExternalTrigger` or `InternalTrigger`.

Each *concrete* subtype two levels down is an immutable type:
`InternalTrigger(ins::AWG5014C, "INT")` encodes everything one needs to know
for how the AWG5014C represents an internal trigger.

To retrieve what one has to send the AWG from the type signature, we have
defined a function `code`.


*source:*
[PainterQB\src\Definitions.jl:62](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\Definitions.jl#L62)

---

<a id="type__instrumentvisa.1" class="lexicon_definition"></a>
#### PainterQB.InstrumentVISA [¶](#type__instrumentvisa.1)
### InstrumentVISA
`abstract InstrumentVISA <: Instrument`

Abstract supertype of all Instruments addressable using a VISA library.
Concrete types are expected to have fields:

`vi::ViSession`
`writeTerminator::ASCIIString`


*source:*
[PainterQB\src\VISA.jl:37](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\VISA.jl#L37)

---

<a id="type__timearesponse.1" class="lexicon_definition"></a>
#### PainterQB.TimeAResponse [¶](#type__timearesponse.1)
`TimeAResponse`

When measured, will return how many seconds it takes to measure
the response field it holds. So meta.


*source:*
[PainterQB\src\sourcemeasure\Time.jl:42](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\sourcemeasure\Time.jl#L42)

---

<a id="type__timerresponse.1" class="lexicon_definition"></a>
#### PainterQB.TimerResponse{T<:AbstractFloat} [¶](#type__timerresponse.1)
`TimerResponse`

When measured, will return how many seconds have elapsed since
the timer was initialized.


*source:*
[PainterQB\src\sourcemeasure\Time.jl:30](https://github.com/ajkeller34/PainterQB.jl/tree/c95a05838a4e95130c5ed4e923b395c3343d3178/src\sourcemeasure\Time.jl#L30)


## Methods [Internal]

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

