# API-INDEX


## MODULE: PainterQB

---

## Methods [Exported]

[ask(ins::PainterQB.InstrumentVISA,  msg::ASCIIString)](PainterQB.md#method__ask.1)  Idiomatic "write and read available" function with optional delay.

[ask(ins::PainterQB.InstrumentVISA,  msg::ASCIIString,  delay::Real)](PainterQB.md#method__ask.2)  Idiomatic "write and read available" function with optional delay.

[binblockreadavailable(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__binblockreadavailable.1)  Read an entire block of bytes with properly formatted IEEE header.

[binblockwrite(ins::PainterQB.InstrumentVISA,  message::Union{ASCIIString, Array{UInt8, 1}},  data::Array{UInt8, 1})](PainterQB.md#method__binblockwrite.1)  Write an IEEE header block followed by an arbitary sequency of bytes and the terminator.

[findresources()](PainterQB.md#method__findresources.1)  Finds VISA resources to which we can connect. Doesn't find ethernet instruments.

[findresources(expr::AbstractString)](PainterQB.md#method__findresources.2)  Finds VISA resources to which we can connect. Doesn't find ethernet instruments.

[gpib(primary)](PainterQB.md#method__gpib.1)  Returns a viSession for the given GPIB address.

[read(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__read.1)  Read from an instrument. Strips trailing carriage returns and new lines.

[readavailable(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__readavailable.1)  Keep reading from an instrument until the instrument says we are done.

[tcpip_instr(ip)](PainterQB.md#method__tcpip_instr.1)  Returns a INSTR viSession for the given IPv4 address.

[tcpip_socket(ip,  port)](PainterQB.md#method__tcpip_socket.1)  Returns a raw socket viSession for the given IPv4 address.

[write(ins::PainterQB.InstrumentVISA,  msg::ASCIIString)](PainterQB.md#method__write.1)  Write to an instrument. Appends the instrument's write terminator.

---

## Types [Exported]

[PainterQB.All](PainterQB.md#type__all.1)  The All type is meant to be dispatched upon and not instantiated.

[PainterQB.DelayStimulus](PainterQB.md#type__delaystimulus.1)  `DelayStimulus`

[PainterQB.InstrumentProperty](PainterQB.md#type__instrumentproperty.1)  ### InstrumentProperty

[PainterQB.InstrumentVISA](PainterQB.md#type__instrumentvisa.1)  ### InstrumentVISA

[PainterQB.TimeAResponse](PainterQB.md#type__timearesponse.1)  `TimeAResponse`

[PainterQB.TimerResponse{T<:AbstractFloat}](PainterQB.md#type__timerresponse.1)  `TimerResponse`

---

## Methods [Internal]

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty})](PainterQB.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](PainterQB.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty},  ::Type{PainterQB.NoArgs})](PainterQB.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty})](PainterQB.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

## MODULE: PainterQB.E5071CModule

---

## Methods [Internal]

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty})](E5071C.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](E5071C.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty},  ::Type{PainterQB.NoArgs})](E5071C.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty})](E5071C.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

## MODULE: PainterQB.E8257DModule

---

## Methods [Internal]

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty})](E8257D.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](E8257D.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty},  ::Type{PainterQB.NoArgs})](E8257D.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty})](E8257D.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

## MODULE: PainterQB.AWG5014CModule

---

## Methods [Exported]

[pullfrom_awg(ins::PainterQB.AWG5014CModule.AWG5014C,  name::ASCIIString)](AWG5014C.md#method__pullfrom_awg.1)  Pull data from the AWG, performing checks and generating errors as appropriate.

[pushto_awg{T<:PainterQB.AWG5014CModule.WaveformType}(ins::PainterQB.AWG5014CModule.AWG5014C,  name::ASCIIString,  awgData::PainterQB.AWG5014CModule.AWG5014CData,  wvType::Type{T<:PainterQB.AWG5014CModule.WaveformType})](AWG5014C.md#method__pushto_awg.1)  Push data to the AWG, performing checks and generating errors as appropriate.

[pushto_awg{T<:PainterQB.AWG5014CModule.WaveformType}(ins::PainterQB.AWG5014CModule.AWG5014C,  name::ASCIIString,  awgData::PainterQB.AWG5014CModule.AWG5014CData,  wvType::Type{T<:PainterQB.AWG5014CModule.WaveformType},  resampleOk::Bool)](AWG5014C.md#method__pushto_awg.2)  Push data to the AWG, performing checks and generating errors as appropriate.

[runapplication(ins::PainterQB.AWG5014CModule.AWG5014C,  app::ASCIIString)](AWG5014C.md#method__runapplication.1)  Run an application, e.g. SerialXpress

[validate(awgData::PainterQB.AWG5014CModule.AWG5014CData,  wvType::Type{PainterQB.AWG5014CModule.WaveformType})](AWG5014C.md#method__validate.1)  Validates data to be pushed to the AWG to check for internal consistency and appropriate range.

[waveformname(ins::PainterQB.AWG5014CModule.AWG5014C,  num::Integer)](AWG5014C.md#method__waveformname.1)  Uses Julia style indexing (begins at 1) to retrieve the name of a waveform.

[waveformtype(ins::PainterQB.AWG5014CModule.AWG5014C,  name::ASCIIString)](AWG5014C.md#method__waveformtype.1)  Returns the type of the waveform. The AWG hardware ultimately uses an `IntWaveform` but `RealWaveform` is more convenient.

---

## Macros [Exported]

[@allch(x::Expr)](AWG5014C.md#macro___allch.1)  Macro for performing an operation on every channel,

---

## Methods [Internal]

[configure(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.Phase},  phase::Real,  ch::Integer)](AWG5014C.md#method__configure.1)  Set the output phase in degrees for a given channel.

[configure(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.SampleRate},  rate::Real)](AWG5014C.md#method__configure.2)  Set the sample rate in Hz between 10 MHz and 10 GHz. Output rate = sample rate / number of points.

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty})](AWG5014C.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](AWG5014C.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty},  ::Type{PainterQB.NoArgs})](AWG5014C.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty})](AWG5014C.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.AWG5014CModule.SequencerType})](AWG5014C.md#method__inspect.1)  Current sequencer type

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.Phase},  ch::Integer)](AWG5014C.md#method__inspect.2)  Get the output phase in degrees for a given channel.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.SampleRate})](AWG5014C.md#method__inspect.3)  Get the sample rate in Hz. Output rate = sample rate / number of points.

[pulllowlevel{T<:PainterQB.AWG5014CModule.RealWaveform}(ins::PainterQB.AWG5014CModule.AWG5014C,  name::ASCIIString,  ::Type{T<:PainterQB.AWG5014CModule.RealWaveform})](AWG5014C.md#method__pulllowlevel.1)  Takes care of the dirty work in pulling data from the AWG.

[pushlowlevel{T<:PainterQB.AWG5014CModule.RealWaveform}(ins::PainterQB.AWG5014CModule.AWG5014C,  name::ASCIIString,  awgData::PainterQB.AWG5014CModule.AWG5014CData,  wvType::Type{T<:PainterQB.AWG5014CModule.RealWaveform})](AWG5014C.md#method__pushlowlevel.1)  Takes care of the dirty work in pushing the data to the AWG.

## MODULE: PainterQB.AlazarModule

---

## Types [Exported]

[PainterQB.AlazarModule.AlazarATS9360](AlazarTech.md#type__alazarats9360.1)  ATS9360 is a concrete subtype of InstrumentAlazar.

[PainterQB.AlazarModule.InstrumentAlazar](AlazarTech.md#type__instrumentalazar.1)  The InstrumentAlazar types represent an AlazarTech device on the local

---

## Methods [Internal]

[call(::Type{PainterQB.InstrumentException},  ins::PainterQB.AlazarModule.InstrumentAlazar,  r)](AlazarTech.md#method__call.1)  Create descriptive exceptions.

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty})](AlazarTech.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](AlazarTech.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty},  ::Type{PainterQB.NoArgs})](AlazarTech.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty})](AlazarTech.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

---

## Macros [Internal]

[@eh2(expr)](AlazarTech.md#macro___eh2.1)  Takes an Alazar API call and brackets it with some checking.

