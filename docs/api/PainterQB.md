# PainterQB


## Methods [Exported]

---

<a id="method__aborttrigger.1" class="lexicon_definition"></a>
#### aborttrigger(ins::PainterQB.InstrumentVISA) [¶](#method__aborttrigger.1)
Abort triggering with ABOR.

*source:*
[PainterQB\src\VISA.jl:122](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L122)

---

<a id="method__ask.1" class="lexicon_definition"></a>
#### ask(ins::PainterQB.InstrumentVISA,  msg::ASCIIString) [¶](#method__ask.1)
Idiomatic "write and read available" function with optional delay.

*source:*
[PainterQB\src\VISA.jl:73](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L73)

---

<a id="method__ask.2" class="lexicon_definition"></a>
#### ask(ins::PainterQB.InstrumentVISA,  msg::ASCIIString,  delay::Real) [¶](#method__ask.2)
Idiomatic "write and read available" function with optional delay.

*source:*
[PainterQB\src\VISA.jl:73](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L73)

---

<a id="method__binblockreadavailable.1" class="lexicon_definition"></a>
#### binblockreadavailable(ins::PainterQB.InstrumentVISA) [¶](#method__binblockreadavailable.1)
Read an entire block of bytes with properly formatted IEEE header.

*source:*
[PainterQB\src\VISA.jl:102](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L102)

---

<a id="method__binblockwrite.1" class="lexicon_definition"></a>
#### binblockwrite(ins::PainterQB.InstrumentVISA,  message::Union{ASCIIString, Array{UInt8, 1}},  data::Array{UInt8, 1}) [¶](#method__binblockwrite.1)
Write an IEEE header block followed by an arbitary sequency of bytes and the terminator.


*source:*
[PainterQB\src\VISA.jl:97](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L97)

---

<a id="method__clearregisters.1" class="lexicon_definition"></a>
#### clearregisters(ins::PainterQB.InstrumentVISA) [¶](#method__clearregisters.1)
Clear registers with *CLS.

*source:*
[PainterQB\src\VISA.jl:116](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L116)

---

<a id="method__findresources.1" class="lexicon_definition"></a>
#### findresources() [¶](#method__findresources.1)
Finds VISA resources to which we can connect. Doesn't seem to find ethernet instruments.

*source:*
[PainterQB\src\VISA.jl:41](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L41)

---

<a id="method__findresources.2" class="lexicon_definition"></a>
#### findresources(expr::AbstractString) [¶](#method__findresources.2)
Finds VISA resources to which we can connect. Doesn't seem to find ethernet instruments.

*source:*
[PainterQB\src\VISA.jl:41](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L41)

---

<a id="method__gpib.1" class="lexicon_definition"></a>
#### gpib(board,  primary) [¶](#method__gpib.1)
Returns a `viSession` for the given GPIB board and primary address.
See VISA spec for details on what a `viSession` is.


*source:*
[PainterQB\src\VISA.jl:53](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L53)

---

<a id="method__gpib.2" class="lexicon_definition"></a>
#### gpib(board,  primary,  secondary) [¶](#method__gpib.2)
Returns a `viSession` for the given GPIB board, primary, and secondary address.
See VISA spec for details on what a `viSession` is.


*source:*
[PainterQB\src\VISA.jl:60](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L60)

---

<a id="method__gpib.3" class="lexicon_definition"></a>
#### gpib(primary) [¶](#method__gpib.3)
Returns a `viSession` for the given GPIB primary address using board 0.
See VISA spec for details on what a `viSession` is.


*source:*
[PainterQB\src\VISA.jl:47](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L47)

---

<a id="method__identify.1" class="lexicon_definition"></a>
#### identify(ins::PainterQB.InstrumentVISA) [¶](#method__identify.1)
Ask the *IDN? command.

*source:*
[PainterQB\src\VISA.jl:113](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L113)

---

<a id="method__inspect.1" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.Instrument,  args::Tuple{Vararg{DataType}}) [¶](#method__inspect.1)
Allow inspecting mulitple properties at once.

*source:*
[PainterQB\src\Definitions.jl:204](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L204)

---

<a id="method__measure.1" class="lexicon_definition"></a>
#### measure(ch::PainterQB.RandomResponse) [¶](#method__measure.1)
Returns a random number in the unit interval.

*source:*
[PainterQB\src\sourcemeasure\Random.jl:8](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Random.jl#L8)

---

<a id="method__measure.2" class="lexicon_definition"></a>
#### measure(ch::PainterQB.TimeAResponse) [¶](#method__measure.2)
Returns how many seconds it takes to measure the response field `ch` holds.

*source:*
[PainterQB\src\sourcemeasure\Time.jl:46](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Time.jl#L46)

---

<a id="method__measure.3" class="lexicon_definition"></a>
#### measure{T}(ch::PainterQB.AveragingResponse{T}) [¶](#method__measure.3)
Measures the response held by `ch` `n_avg` times, and returns the average.

*source:*
[PainterQB\src\sourcemeasure\Averaging.jl:11](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Averaging.jl#L11)

---

<a id="method__measure.4" class="lexicon_definition"></a>
#### measure{T}(ch::PainterQB.TimerResponse{T}) [¶](#method__measure.4)
Returns how many seconds have elapsed since the timer was initialized or reset.

*source:*
[PainterQB\src\sourcemeasure\Time.jl:38](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Time.jl#L38)

---

<a id="method__quoted.1" class="lexicon_definition"></a>
#### quoted(str::ASCIIString) [¶](#method__quoted.1)
Surround a string in quotation marks.

*source:*
[PainterQB\src\VISA.jl:127](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L127)

---

<a id="method__read.1" class="lexicon_definition"></a>
#### read(ins::PainterQB.InstrumentVISA) [¶](#method__read.1)
Read from an instrument. Strips trailing carriage returns and new lines.
Note that this function will only read so many characters (buffered).


*source:*
[PainterQB\src\VISA.jl:83](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L83)

---

<a id="method__readavailable.1" class="lexicon_definition"></a>
#### readavailable(ins::PainterQB.InstrumentVISA) [¶](#method__readavailable.1)
Keep reading from an instrument until the instrument says we are done.

*source:*
[PainterQB\src\VISA.jl:91](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L91)

---

<a id="method__reset.1" class="lexicon_definition"></a>
#### reset(d::PainterQB.DelayStimulus) [¶](#method__reset.1)
Reset the DelayStimulus reference time to now.

*source:*
[PainterQB\src\sourcemeasure\Time.jl:11](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Time.jl#L11)

---

<a id="method__reset.2" class="lexicon_definition"></a>
#### reset(d::PainterQB.TimerResponse{T<:AbstractFloat}) [¶](#method__reset.2)
Reset the TimerResponse reference time to now.

*source:*
[PainterQB\src\sourcemeasure\Time.jl:33](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Time.jl#L33)

---

<a id="method__reset.3" class="lexicon_definition"></a>
#### reset(ins::PainterQB.InstrumentVISA) [¶](#method__reset.3)
Reset with the *RST command.

*source:*
[PainterQB\src\VISA.jl:110](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L110)

---

<a id="method__source.1" class="lexicon_definition"></a>
#### source(ch::PainterQB.DelayStimulus,  val::Real) [¶](#method__source.1)
Wait until `val` seconds have elapsed since `ch` was initialized or reset.

*source:*
[PainterQB\src\sourcemeasure\Time.jl:16](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Time.jl#L16)

---

<a id="method__source.2" class="lexicon_definition"></a>
#### source(ch::PainterQB.PropertyStimulus{T<:PainterQB.InstrumentProperty{Number}},  val::Real) [¶](#method__source.2)
Sourcing a PropertyStimulus configures an InstrumentProperty.

*source:*
[PainterQB\src\sourcemeasure\Property.jl:30](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Property.jl#L30)

---

<a id="method__source.3" class="lexicon_definition"></a>
#### source(ch::PainterQB.ThreadStimulus,  nw::Int64) [¶](#method__source.3)
Adds or removes threads to reach the desired number of worker threads.

*source:*
[PainterQB\src\sourcemeasure\Thread.jl:32](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Thread.jl#L32)

---

<a id="method__source.4" class="lexicon_definition"></a>
#### source{T}(ch::PainterQB.ResponseStimulus{T},  val) [¶](#method__source.4)
Sets the field named `:name` in the `Response` held by `ch` to `val`.

*source:*
[PainterQB\src\sourcemeasure\ResponseStim.jl:22](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\ResponseStim.jl#L22)

---

<a id="method__tcpip_instr.1" class="lexicon_definition"></a>
#### tcpip_instr(ip) [¶](#method__tcpip_instr.1)
Returns a INSTR `viSession` for the given IPv4 address string.

*source:*
[PainterQB\src\VISA.jl:64](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L64)

---

<a id="method__tcpip_socket.1" class="lexicon_definition"></a>
#### tcpip_socket(ip,  port) [¶](#method__tcpip_socket.1)
Returns a raw socket `viSession` for the given IPv4 address string.

*source:*
[PainterQB\src\VISA.jl:67](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L67)

---

<a id="method__test.1" class="lexicon_definition"></a>
#### test(ins::PainterQB.InstrumentVISA) [¶](#method__test.1)
Test with the *TST? command.

*source:*
[PainterQB\src\VISA.jl:107](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L107)

---

<a id="method__trigger.1" class="lexicon_definition"></a>
#### trigger(ins::PainterQB.InstrumentVISA) [¶](#method__trigger.1)
Bus trigger with *TRG.

*source:*
[PainterQB\src\VISA.jl:119](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L119)

---

<a id="method__unquoted.1" class="lexicon_definition"></a>
#### unquoted(str::ASCIIString) [¶](#method__unquoted.1)
Strip a string of enclosing quotation marks.

*source:*
[PainterQB\src\VISA.jl:130](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L130)

---

<a id="method__write.1" class="lexicon_definition"></a>
#### write(ins::PainterQB.InstrumentVISA,  msg::ASCIIString) [¶](#method__write.1)
Write to an instrument. Appends the instrument's write terminator.

*source:*
[PainterQB\src\VISA.jl:87](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L87)

## Types [Exported]

---

<a id="type__all.1" class="lexicon_definition"></a>
#### PainterQB.All [¶](#type__all.1)
The All type is meant to be dispatched upon and not instantiated.

*source:*
[PainterQB\src\Definitions.jl:200](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L200)

---

<a id="type__averagingresponse.1" class="lexicon_definition"></a>
#### PainterQB.AveragingResponse{T} [¶](#type__averagingresponse.1)
Response that averages other responses. Not clear if this is a good idea yet.

*source:*
[PainterQB\src\sourcemeasure\Averaging.jl:4](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Averaging.jl#L4)

---

<a id="type__clockslope.1" class="lexicon_definition"></a>
#### PainterQB.ClockSlope [¶](#type__clockslope.1)
Clock may tick on a rising or falling slope.

*source:*
[PainterQB\src\Definitions.jl:61](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L61)

---

<a id="type__clocksource.1" class="lexicon_definition"></a>
#### PainterQB.ClockSource [¶](#type__clocksource.1)
Clock source can be internal or external.

*source:*
[PainterQB\src\Definitions.jl:64](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L64)

---

<a id="type__coupling.1" class="lexicon_definition"></a>
#### PainterQB.Coupling [¶](#type__coupling.1)
Signals may be AC or DC coupled.

*source:*
[PainterQB\src\Definitions.jl:67](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L67)

---

<a id="type__delaystimulus.1" class="lexicon_definition"></a>
#### PainterQB.DelayStimulus [¶](#type__delaystimulus.1)
A stimulus for delaying until time has passed since a reference time t0.

*source:*
[PainterQB\src\sourcemeasure\Time.jl:5](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Time.jl#L5)

---

<a id="type__frequency.1" class="lexicon_definition"></a>
#### PainterQB.Frequency [¶](#type__frequency.1)
Fixed frequency of a sourced signal.

*source:*
[PainterQB\src\Definitions.jl:96](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L96)

---

<a id="type__frequencystart.1" class="lexicon_definition"></a>
#### PainterQB.FrequencyStart [¶](#type__frequencystart.1)
Start frequency of a fixed range.

*source:*
[PainterQB\src\Definitions.jl:99](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L99)

---

<a id="type__frequencystop.1" class="lexicon_definition"></a>
#### PainterQB.FrequencyStop [¶](#type__frequencystop.1)
Stop frequency of a fixed range.

*source:*
[PainterQB\src\Definitions.jl:102](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L102)

---

<a id="type__instrument.1" class="lexicon_definition"></a>
#### PainterQB.Instrument [¶](#type__instrument.1)
Abstract supertype representing an instrument.


*source:*
[PainterQB\src\Definitions.jl:43](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L43)

---

<a id="type__instrumentexception.1" class="lexicon_definition"></a>
#### PainterQB.InstrumentException [¶](#type__instrumentexception.1)
Exception to be thrown by an instrument. Fields include the instrument in error
`ins::Instrument`, the error code `val::Int64`, and a `humanReadable` Unicode
string.


*source:*
[PainterQB\src\Definitions.jl:118](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L118)

---

<a id="type__instrumentproperty.1" class="lexicon_definition"></a>
#### PainterQB.InstrumentProperty{T} [¶](#type__instrumentproperty.1)
Abstract parametric supertype representing communications with an instrument.

Each *abstract* subtype one level down should represent a logical state of the
instrument configuration, e.g. `TriggerSource` may be have concrete
subtypes `ExternalTrigger` or `InternalTrigger`.

To retrieve what one has to send the AWG from the type signature, we have
defined a function `code`.


*source:*
[PainterQB\src\Definitions.jl:55](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L55)

---

<a id="type__instrumentvisa.1" class="lexicon_definition"></a>
#### PainterQB.InstrumentVISA [¶](#type__instrumentvisa.1)
Abstract supertype of all Instruments addressable using a VISA library.
Concrete types are expected to have fields:

`vi::ViSession`

`writeTerminator::ASCIIString`


*source:*
[PainterQB\src\VISA.jl:36](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L36)

---

<a id="type__noargs.1" class="lexicon_definition"></a>
#### PainterQB.NoArgs [¶](#type__noargs.1)
Used internally to indicate that a property takes no argument.

*source:*
[PainterQB\src\Definitions.jl:58](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L58)

---

<a id="type__oscillatorsource.1" class="lexicon_definition"></a>
#### PainterQB.OscillatorSource [¶](#type__oscillatorsource.1)
Oscillator source can be internal or external.

*source:*
[PainterQB\src\Definitions.jl:72](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L72)

---

<a id="type__output.1" class="lexicon_definition"></a>
#### PainterQB.Output [¶](#type__output.1)
Boolean output state of an instrument.

*source:*
[PainterQB\src\Definitions.jl:105](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L105)

---

<a id="type__power.1" class="lexicon_definition"></a>
#### PainterQB.Power [¶](#type__power.1)
Output power level.

*source:*
[PainterQB\src\Definitions.jl:108](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L108)

---

<a id="type__propertystimulus.1" class="lexicon_definition"></a>
#### PainterQB.PropertyStimulus{T<:PainterQB.InstrumentProperty{Number}} [¶](#type__propertystimulus.1)
Wraps any Number-valued `InstrumentProperty` into a `Stimulus`. Essentially,
sourcing a PropertyStimulus does nothing more than calling `configure` with
the associated property and value. Additional parameters to be passed to
`configure` may be specified at the time the `PropertyStimulus` is constructed.


*source:*
[PainterQB\src\sourcemeasure\Property.jl:9](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Property.jl#L9)

---

<a id="type__randomresponse.1" class="lexicon_definition"></a>
#### PainterQB.RandomResponse [¶](#type__randomresponse.1)
Random number response suitable for testing the measurement code without having
a physical instrument.

*source:*
[PainterQB\src\sourcemeasure\Random.jl:5](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Random.jl#L5)

---

<a id="type__responsestimulus.1" class="lexicon_definition"></a>
#### PainterQB.ResponseStimulus{T} [¶](#type__responsestimulus.1)
Esoteric stimulus to consider changing the fields of a `Response` as a stimulus.
Sounds absurd at first, but could be useful if the fields of a `Response` affect
how that `Response` is measured. For instance, this may be useful to change
`n_avg` in the `AveragingResponse` to see the effect of averaging.


*source:*
[PainterQB\src\sourcemeasure\ResponseStim.jl:9](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\ResponseStim.jl#L9)

---

<a id="type__sparameter.1" class="lexicon_definition"></a>
#### PainterQB.SParameter [¶](#type__sparameter.1)
Scattering parameter, e.g. S11, S12, etc.

*source:*
[PainterQB\src\Definitions.jl:80](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L80)

---

<a id="type__samplerate.1" class="lexicon_definition"></a>
#### PainterQB.SampleRate [¶](#type__samplerate.1)
The sample rate for digitizing, synthesizing, etc.

*source:*
[PainterQB\src\Definitions.jl:75](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L75)

---

<a id="type__threadstimulus.1" class="lexicon_definition"></a>
#### PainterQB.ThreadStimulus [¶](#type__threadstimulus.1)
Changes the number of Julia worker threads. An Expr object is used to
initialize new threads.

*source:*
[PainterQB\src\sourcemeasure\Thread.jl:5](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Thread.jl#L5)

---

<a id="type__timearesponse.1" class="lexicon_definition"></a>
#### PainterQB.TimeAResponse [¶](#type__timearesponse.1)
A response for timing other responses.

*source:*
[PainterQB\src\sourcemeasure\Time.jl:41](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Time.jl#L41)

---

<a id="type__timerresponse.1" class="lexicon_definition"></a>
#### PainterQB.TimerResponse{T<:AbstractFloat} [¶](#type__timerresponse.1)
A response for measuring how much time has passed since a reference time t0.

*source:*
[PainterQB\src\sourcemeasure\Time.jl:27](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\sourcemeasure\Time.jl#L27)

---

<a id="type__triggerimpedance.1" class="lexicon_definition"></a>
#### PainterQB.TriggerImpedance [¶](#type__triggerimpedance.1)
Trigger input impedance may be 50 Ohm or 1 kOhm.

*source:*
[PainterQB\src\Definitions.jl:87](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L87)

---

<a id="type__triggerlevel.1" class="lexicon_definition"></a>
#### PainterQB.TriggerLevel [¶](#type__triggerlevel.1)
Trigger level.

*source:*
[PainterQB\src\Definitions.jl:111](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L111)

---

<a id="type__triggerslope.1" class="lexicon_definition"></a>
#### PainterQB.TriggerSlope [¶](#type__triggerslope.1)
Trigger engine can fire on a rising or falling slope.

*source:*
[PainterQB\src\Definitions.jl:90](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L90)

---

<a id="type__triggersource.1" class="lexicon_definition"></a>
#### PainterQB.TriggerSource [¶](#type__triggersource.1)
Trigger may be sourced from: internal, external, bus, etc.

*source:*
[PainterQB\src\Definitions.jl:93](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Definitions.jl#L93)

## Globals [Exported]

---

<a id="global__resourcemanager.1" class="lexicon_definition"></a>
#### resourcemanager [¶](#global__resourcemanager.1)
The default resource manager.

*source:*
[PainterQB\src\VISA.jl:7](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\VISA.jl#L7)


## Methods [Internal]

---

<a id="method__generate_configure.1" class="lexicon_definition"></a>
#### generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}}) [¶](#method__generate_configure.1)
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
[PainterQB\src\Metaprogramming.jl:93](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Metaprogramming.jl#L93)

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
[PainterQB\src\Metaprogramming.jl:213](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Metaprogramming.jl#L213)

---

<a id="method__generate_inspect.1" class="lexicon_definition"></a>
#### generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs}) [¶](#method__generate_inspect.1)
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
[PainterQB\src\Metaprogramming.jl:32](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Metaprogramming.jl#L32)

---

<a id="method__generate_properties.1" class="lexicon_definition"></a>
#### generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}}) [¶](#method__generate_properties.1)
Makes parametric subtypes and gives constructors. Also defines a code method.

*source:*
[PainterQB\src\Metaprogramming.jl:176](https://github.com/ajkeller34/PainterQB.jl/tree/37bbc1037abc44019997b8f29b8ee739e88cfe04/src\Metaprogramming.jl#L176)

