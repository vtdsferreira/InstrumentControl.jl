# API-INDEX


## MODULE: PainterQB

---

## Methods [Exported]

[aborttrigger(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__aborttrigger.1)  Abort triggering with ABOR.

[ask(ins::PainterQB.InstrumentVISA,  msg::ASCIIString)](PainterQB.md#method__ask.1)  Idiomatic "write and read available" function with optional delay.

[ask(ins::PainterQB.InstrumentVISA,  msg::ASCIIString,  delay::Real)](PainterQB.md#method__ask.2)  Idiomatic "write and read available" function with optional delay.

[binblockreadavailable(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__binblockreadavailable.1)  Read an entire block of bytes with properly formatted IEEE header.

[binblockwrite(ins::PainterQB.InstrumentVISA,  message::Union{ASCIIString, Array{UInt8, 1}},  data::Array{UInt8, 1})](PainterQB.md#method__binblockwrite.1)  Write an IEEE header block followed by an arbitary sequency of bytes and the terminator.

[clearregisters(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__clearregisters.1)  Clear registers with *CLS.

[findresources()](PainterQB.md#method__findresources.1)  Finds VISA resources to which we can connect. Doesn't seem to find ethernet instruments.

[findresources(expr::AbstractString)](PainterQB.md#method__findresources.2)  Finds VISA resources to which we can connect. Doesn't seem to find ethernet instruments.

[gpib(board,  primary)](PainterQB.md#method__gpib.1)  Returns a `viSession` for the given GPIB board and primary address.

[gpib(board,  primary,  secondary)](PainterQB.md#method__gpib.2)  Returns a `viSession` for the given GPIB board, primary, and secondary address.

[gpib(primary)](PainterQB.md#method__gpib.3)  Returns a `viSession` for the given GPIB primary address using board 0.

[identify(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__identify.1)  Ask the *IDN? command.

[inspect(ins::PainterQB.Instrument,  args::Tuple{Vararg{DataType}})](PainterQB.md#method__inspect.1)  Allow inspecting mulitple properties at once.

[measure(ch::PainterQB.RandomResponse)](PainterQB.md#method__measure.1)  Returns a random number in the unit interval.

[measure(ch::PainterQB.TimeAResponse)](PainterQB.md#method__measure.2)  Returns how many seconds it takes to measure the response field `ch` holds.

[measure{T}(ch::PainterQB.AveragingResponse{T})](PainterQB.md#method__measure.3)  Measures the response held by `ch` `n_avg` times, and returns the average.

[measure{T}(ch::PainterQB.TimerResponse{T})](PainterQB.md#method__measure.4)  Returns how many seconds have elapsed since the timer was initialized or reset.

[quoted(str::ASCIIString)](PainterQB.md#method__quoted.1)  Surround a string in quotation marks.

[read(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__read.1)  Read from an instrument. Strips trailing carriage returns and new lines.

[readavailable(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__readavailable.1)  Keep reading from an instrument until the instrument says we are done.

[reset(d::PainterQB.DelayStimulus)](PainterQB.md#method__reset.1)  Reset the DelayStimulus reference time to now.

[reset(d::PainterQB.TimerResponse{T<:AbstractFloat})](PainterQB.md#method__reset.2)  Reset the TimerResponse reference time to now.

[reset(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__reset.3)  Reset with the *RST command.

[source(ch::PainterQB.DelayStimulus,  val::Real)](PainterQB.md#method__source.1)  Wait until `val` seconds have elapsed since `ch` was initialized or reset.

[source(ch::PainterQB.PropertyStimulus{T<:PainterQB.InstrumentProperty{Number}},  val::Real)](PainterQB.md#method__source.2)  Sourcing a PropertyStimulus configures an InstrumentProperty.

[source(ch::PainterQB.ThreadStimulus,  nw::Int64)](PainterQB.md#method__source.3)  Adds or removes threads to reach the desired number of worker threads.

[source{T}(ch::PainterQB.ResponseStimulus{T},  val)](PainterQB.md#method__source.4)  Sets the field named `:name` in the `Response` held by `ch` to `val`.

[tcpip_instr(ip)](PainterQB.md#method__tcpip_instr.1)  Returns a INSTR `viSession` for the given IPv4 address string.

[tcpip_socket(ip,  port)](PainterQB.md#method__tcpip_socket.1)  Returns a raw socket `viSession` for the given IPv4 address string.

[test(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__test.1)  Test with the *TST? command.

[trigger(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__trigger.1)  Bus trigger with *TRG.

[unquoted(str::ASCIIString)](PainterQB.md#method__unquoted.1)  Strip a string of enclosing quotation marks.

[write(ins::PainterQB.InstrumentVISA,  msg::ASCIIString)](PainterQB.md#method__write.1)  Write to an instrument. Appends the instrument's write terminator.

---

## Types [Exported]

[PainterQB.All](PainterQB.md#type__all.1)  The All type is meant to be dispatched upon and not instantiated.

[PainterQB.AveragingResponse{T}](PainterQB.md#type__averagingresponse.1)  Response that averages other responses. Not clear if this is a good idea yet.

[PainterQB.ClockSlope](PainterQB.md#type__clockslope.1)  Clock may tick on a rising or falling slope.

[PainterQB.ClockSource](PainterQB.md#type__clocksource.1)  Clock source can be internal or external.

[PainterQB.Coupling](PainterQB.md#type__coupling.1)  Signals may be AC or DC coupled.

[PainterQB.DelayStimulus](PainterQB.md#type__delaystimulus.1)  A stimulus for delaying until time has passed since a reference time t0.

[PainterQB.Frequency](PainterQB.md#type__frequency.1)  Fixed frequency of a sourced signal.

[PainterQB.FrequencyStart](PainterQB.md#type__frequencystart.1)  Start frequency of a fixed range.

[PainterQB.FrequencyStop](PainterQB.md#type__frequencystop.1)  Stop frequency of a fixed range.

[PainterQB.Instrument](PainterQB.md#type__instrument.1)  Abstract supertype representing an instrument.

[PainterQB.InstrumentException](PainterQB.md#type__instrumentexception.1)  Exception to be thrown by an instrument. Fields include the instrument in error

[PainterQB.InstrumentProperty{T}](PainterQB.md#type__instrumentproperty.1)  Abstract parametric supertype representing communications with an instrument.

[PainterQB.InstrumentVISA](PainterQB.md#type__instrumentvisa.1)  Abstract supertype of all Instruments addressable using a VISA library.

[PainterQB.NoArgs](PainterQB.md#type__noargs.1)  Used internally to indicate that a property takes no argument.

[PainterQB.OscillatorSource](PainterQB.md#type__oscillatorsource.1)  Oscillator source can be internal or external.

[PainterQB.Output](PainterQB.md#type__output.1)  Boolean output state of an instrument.

[PainterQB.Power](PainterQB.md#type__power.1)  Output power level.

[PainterQB.PropertyStimulus{T<:PainterQB.InstrumentProperty{Number}}](PainterQB.md#type__propertystimulus.1)  Wraps any Number-valued `InstrumentProperty` into a `Stimulus`. Essentially,

[PainterQB.RandomResponse](PainterQB.md#type__randomresponse.1)  Random number response suitable for testing the measurement code without having

[PainterQB.ResponseStimulus{T}](PainterQB.md#type__responsestimulus.1)  Esoteric stimulus to consider changing the fields of a `Response` as a stimulus.

[PainterQB.SParameter](PainterQB.md#type__sparameter.1)  Scattering parameter, e.g. S11, S12, etc.

[PainterQB.SampleRate](PainterQB.md#type__samplerate.1)  The sample rate for digitizing, synthesizing, etc.

[PainterQB.ThreadStimulus](PainterQB.md#type__threadstimulus.1)  Changes the number of Julia worker threads. An Expr object is used to

[PainterQB.TimeAResponse](PainterQB.md#type__timearesponse.1)  A response for timing other responses.

[PainterQB.TimerResponse{T<:AbstractFloat}](PainterQB.md#type__timerresponse.1)  A response for measuring how much time has passed since a reference time t0.

[PainterQB.TriggerImpedance](PainterQB.md#type__triggerimpedance.1)  Trigger input impedance may be 50 Ohm or 1 kOhm.

[PainterQB.TriggerLevel](PainterQB.md#type__triggerlevel.1)  Trigger level.

[PainterQB.TriggerSlope](PainterQB.md#type__triggerslope.1)  Trigger engine can fire on a rising or falling slope.

[PainterQB.TriggerSource](PainterQB.md#type__triggersource.1)  Trigger may be sourced from: internal, external, bus, etc.

---

## Globals [Exported]

[resourcemanager](PainterQB.md#global__resourcemanager.1)  The default resource manager.

---

## Methods [Internal]

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](PainterQB.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](PainterQB.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](PainterQB.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](PainterQB.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

## MODULE: PainterQB.E5071CModule

---

## Types [Exported]

[PainterQB.E5071CModule.ElectricalMedium](E5071C.md#type__electricalmedium.1)  Signals may propagate on coax or waveguide media.

---

## Methods [Internal]

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](E5071C.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](E5071C.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](E5071C.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](E5071C.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

## MODULE: PainterQB.E8257DModule

---

## Methods [Internal]

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](E8257D.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](E8257D.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](E8257D.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](E8257D.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

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

## Types [Exported]

[PainterQB.AWG5014CModule.EventImpedance](AWG5014C.md#type__eventimpedance.1)  Event input impedance may be 50 Ohm or 1 kOhm.

[PainterQB.AWG5014CModule.EventSlope](AWG5014C.md#type__eventslope.1)  Event may fire on a rising or falling slope.

[PainterQB.AWG5014CModule.EventTiming](AWG5014C.md#type__eventtiming.1)  Events may occur synchronously or asynchronously.

[PainterQB.AWG5014CModule.TriggerMode](AWG5014C.md#type__triggermode.1)  Trigger engine may be triggered, continuously firing, gated, or sequenced.

---

## Macros [Exported]

[@allch(x::Expr)](AWG5014C.md#macro___allch.1)  Macro for performing an operation on every channel,

---

## Methods [Internal]

[configure(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.Phase},  phase::Real,  ch::Integer)](AWG5014C.md#method__configure.1)  Set the output phase in degrees for a given channel.

[configure(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.SampleRate},  rate::Real)](AWG5014C.md#method__configure.2)  Set the sample rate in Hz between 10 MHz and 10 GHz. Output rate = sample rate / number of points.

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](AWG5014C.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](AWG5014C.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](AWG5014C.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](AWG5014C.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.AWG5014CModule.SequencerType})](AWG5014C.md#method__inspect.1)  Returns current sequencer type.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.Phase},  ch::Integer)](AWG5014C.md#method__inspect.2)  Get the output phase in degrees for a given channel.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.SampleRate})](AWG5014C.md#method__inspect.3)  Get the sample rate in Hz. Output rate = sample rate / number of points.

[pulllowlevel{T<:PainterQB.AWG5014CModule.RealWaveform}(ins::PainterQB.AWG5014CModule.AWG5014C,  name::ASCIIString,  ::Type{T<:PainterQB.AWG5014CModule.RealWaveform})](AWG5014C.md#method__pulllowlevel.1)  Takes care of the dirty work in pulling data from the AWG.

[pushlowlevel{T<:PainterQB.AWG5014CModule.RealWaveform}(ins::PainterQB.AWG5014CModule.AWG5014C,  name::ASCIIString,  awgData::PainterQB.AWG5014CModule.AWG5014CData,  wvType::Type{T<:PainterQB.AWG5014CModule.RealWaveform})](AWG5014C.md#method__pushlowlevel.1)  Takes care of the dirty work in pushing the data to the AWG.

## MODULE: PainterQB.AlazarModule

---

## Functions [Exported]

[PainterQB.AlazarModule.abort](AlazarTech.md#function__abort.1)  Aborts an acquisition. Must be called in the case of a DSP acquisition; somehow

[PainterQB.AlazarModule.before_async_read](AlazarTech.md#function__before_async_read.1)  Performs setup for asynchronous acquisitions. Should be called after

[PainterQB.AlazarModule.bufferarray](AlazarTech.md#function__bufferarray.1)  Given and `InstrumentAlazar` and `AlazarMode`, returns a `DMABufferArray`

[PainterQB.AlazarModule.buffersizing](AlazarTech.md#function__buffersizing.1)  Given an `InstrumentAlazar` and an `AlazarMode`, this will tweak parameters

[PainterQB.AlazarModule.dsp_generatewindowfunction](AlazarTech.md#function__dsp_generatewindowfunction.1)  Given a `DSPWindow`, `Re` or `Im` type, and `FFTRecordMode`, this will prepare

[PainterQB.AlazarModule.recordsizing](AlazarTech.md#function__recordsizing.1)  Calls C function `AlazarSetRecordSize` if necessary, given an `InstrumentAlazar`

[PainterQB.AlazarModule.wait_buffer](AlazarTech.md#function__wait_buffer.1)  Waits for a buffer to be processed (or a timeout to elapse).

[PainterQB.AlazarModule.windowing](AlazarTech.md#function__windowing.1)  Set up DSP windowing if necessary, given an `InstrumentAlazar` and `AlazarMode`.

---

## Methods [Exported]

[busy(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__busy.1)  Returns whether or not the `InstrumentAlazar` is busy (Bool).

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AuxSoftwareTriggerEnable},  b::Bool)](AlazarTech.md#method__configure.1)  If an AUX IO output mode has been configured, then this will configure

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.LED},  ledState::Bool)](AlazarTech.md#method__configure.2)  Configures the LED on the digitizer card chassis.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.RecordCount},  count)](AlazarTech.md#method__configure.3)  Wrapper for C function `AlazarSetRecordCount`. See the Alazar API.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.Sleep},  sleepState)](AlazarTech.md#method__configure.4)  Configures the sleep state of the digitizer card.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.TriggerDelaySamples},  delay_samples)](AlazarTech.md#method__configure.5)  Configure how many samples to wait after receiving a trigger event before capturing

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.TriggerTimeoutS},  timeout_s)](AlazarTech.md#method__configure.6)  Wrapper for C function `AlazarSetTriggerTimeOut`, except we take seconds here

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.TriggerTimeoutTicks},  ticks)](AlazarTech.md#method__configure.7)  Wrapper for C function `AlazarSetTriggerTimeOut`.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.TriggerLevel},  levelJ,  levelK)](AlazarTech.md#method__configure.8)  Configure the trigger level for trigger engine J and K. This should be an

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxDigitalInput})](AlazarTech.md#method__configure.9)  Configure a digitizer's AUX IO to act as a digital input.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxDigitalOutput},  level::Integer)](AlazarTech.md#method__configure.10)  Configure a digitizer's AUX IO port to act as a general purpose digital output.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxOutputPacer},  divider::Integer)](AlazarTech.md#method__configure.11)  Configure a digitizer's AUX IO port to output the sample clock, divided by an integer.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxOutputTrigger})](AlazarTech.md#method__configure.12)  Configure a digitizer's AUX IO to output a trigger signal synced to the sample clock.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ch::Type{PainterQB.AlazarModule.BothChannels})](AlazarTech.md#method__configure.13)  Configures acquisition from both channels, simultaneously.

[configure{S<:PainterQB.AlazarModule.AlazarDataPacking}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  pack::Type{S<:PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{PainterQB.AlazarModule.BothChannels})](AlazarTech.md#method__configure.14)  Configures the data packing mode for both channels.

[configure{S<:PainterQB.AlazarModule.AlazarDataPacking}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  pack::Type{S<:PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{PainterQB.AlazarModule.ChannelA})](AlazarTech.md#method__configure.15)  Configures the data packing mode for channel A.

[configure{S<:PainterQB.AlazarModule.AlazarDataPacking}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  pack::Type{S<:PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{PainterQB.AlazarModule.ChannelB})](AlazarTech.md#method__configure.16)  Configures the data packing mode for channel B.

[configure{S<:PainterQB.TriggerSlope, T<:PainterQB.TriggerSlope}(a::PainterQB.AlazarModule.InstrumentAlazar,  slopeJ::Type{S<:PainterQB.TriggerSlope},  slopeK::Type{T<:PainterQB.TriggerSlope})](AlazarTech.md#method__configure.17)  Configures whether to trigger on a rising or falling slope, for engine J and K.

[configure{S<:PainterQB.TriggerSource, T<:PainterQB.TriggerSource}(a::PainterQB.AlazarModule.InstrumentAlazar,  sourceJ::Type{S<:PainterQB.TriggerSource},  sourceK::Type{T<:PainterQB.TriggerSource})](AlazarTech.md#method__configure.18)  Configure the trigger source for trigger engine J and K.

[configure{T<:PainterQB.AlazarModule.AlazarChannel}(a::PainterQB.AlazarModule.InstrumentAlazar,  ch::Type{T<:PainterQB.AlazarModule.AlazarChannel})](AlazarTech.md#method__configure.19)  Configures the acquisition channel.

[configure{T<:PainterQB.AlazarModule.AlazarTimestampReset}(a::PainterQB.AlazarModule.InstrumentAlazar,  t::Type{T<:PainterQB.AlazarModule.AlazarTimestampReset})](AlazarTech.md#method__configure.20)  Configures timestamp reset. From the Alazar API, the choices are

[configure{T<:PainterQB.AlazarModule.AlazarTriggerEngine}(a::PainterQB.AlazarModule.InstrumentAlazar,  engine::Type{T<:PainterQB.AlazarModule.AlazarTriggerEngine})](AlazarTech.md#method__configure.21)  Configures the trigger engines, e.g. TriggerOnJ, TriggerOnJAndNotK, etc.

[configure{T<:PainterQB.AlazarModule.AlazarTriggerRange}(a::PainterQB.AlazarModule.InstrumentAlazar,  range::Type{T<:PainterQB.AlazarModule.AlazarTriggerRange})](AlazarTech.md#method__configure.22)  Configure the external trigger range.

[configure{T<:PainterQB.ClockSlope}(a::PainterQB.AlazarModule.InstrumentAlazar,  slope::Type{T<:PainterQB.ClockSlope})](AlazarTech.md#method__configure.23)  Configures whether the clock ticks on a rising or falling slope.

[configure{T<:PainterQB.Coupling}(a::PainterQB.AlazarModule.InstrumentAlazar,  coupling::Type{T<:PainterQB.Coupling})](AlazarTech.md#method__configure.24)  Configure the external trigger coupling.

[configure{T<:PainterQB.SampleRate}(a::PainterQB.AlazarModule.InstrumentAlazar,  rate::Type{T<:PainterQB.SampleRate})](AlazarTech.md#method__configure.25)  Configures one of the preset sample rates derived from the internal clock.

[configure{T<:PainterQB.TriggerSlope}(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxInputTriggerEnable},  trigSlope::Type{T<:PainterQB.TriggerSlope})](AlazarTech.md#method__configure.26)  Configure a digitizer's AUX IO port to use the edge of a pulse as an AutoDMA

[dsp_getinfo(dspModule::PainterQB.AlazarModule.DSPModule)](AlazarTech.md#method__dsp_getinfo.1)  Returns a DSPModuleInfo object that describes a DSPModule.

[dsp_getmodulehandles(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__dsp_getmodulehandles.1)  Returns an Array of `dsp_module_handle`.

[dsp_modules(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__dsp_modules.1)  Returns an array of `DSPModule`.

[dsp_num_modules(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__dsp_num_modules.1)  Returns the number of `DSPModule`.

[fft_setup(a::PainterQB.AlazarModule.InstrumentAlazar,  m::PainterQB.AlazarModule.FFTRecordMode)](AlazarTech.md#method__fft_setup.1)  Performs `AlazarFFTSetup`, which should be called before `AlazarBeforeAsyncRead`.

[fft_setwindowfunction(dspModule::PainterQB.AlazarModule.DSPModule,  samplesPerRecord,  reArray,  imArray)](AlazarTech.md#method__fft_setwindowfunction.1)  A wrapper for the C function `AlazarFFTSetWindowFunction`, but taking a

[forcetrigger(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__forcetrigger.1)  Force a software trigger.

[forcetriggerenable(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__forcetriggerenable.1)  Force a software "trigger enable." This involves the AUX I/O connector (see

[inputcontrol(a::PainterQB.AlazarModule.InstrumentAlazar,  channel,  coupling,  inputRange,  impedance)](AlazarTech.md#method__inputcontrol.1)  Controls coupling, input range, and impedance for applicable digitizer cards.

[post_async_buffer(a::PainterQB.AlazarModule.InstrumentAlazar,  buffer,  bufferLength)](AlazarTech.md#method__post_async_buffer.1)  Post an asynchronous buffer to the digitizer for use in an acquisition.

[set_parameter(a::PainterQB.AlazarModule.InstrumentAlazar,  channelId,  parameterId,  value)](AlazarTech.md#method__set_parameter.1)  Julia wrapper for C function AlazarSetParameter, with error checking.

[set_parameter_ul(a::PainterQB.AlazarModule.InstrumentAlazar,  channelId,  parameterId,  value)](AlazarTech.md#method__set_parameter_ul.1)  Julia wrapper for C function AlazarSetParameterUL, with error checking.

[set_triggeroperation(a::PainterQB.AlazarModule.InstrumentAlazar,  args...)](AlazarTech.md#method__set_triggeroperation.1)  Configure the trigger operation. Usually not called directly.

[startcapture(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__startcapture.1)  Should be called after `before_async_read` has been called and buffers are posted.

[triggered(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__triggered.1)  Reports whether or not the digitizer has been triggered.

---

## Types [Exported]

[PainterQB.AlazarModule.AlazarATS9360](AlazarTech.md#type__alazarats9360.1)  Concrete InstrumentAlazar subtype.

[PainterQB.AlazarModule.AlazarWindow](AlazarTech.md#type__alazarwindow.1)  Abstract type representing a windowing function for DSP, built into the

[PainterQB.AlazarModule.DSPModule](AlazarTech.md#type__dspmodule.1)  Represents a DSP module of an AlazarTech digitizer.

[PainterQB.AlazarModule.DSPModuleInfo](AlazarTech.md#type__dspmoduleinfo.1)  Encapsulates DSP module information: type, version, and max record length.

[PainterQB.AlazarModule.DSPWindow](AlazarTech.md#type__dspwindow.1)  Abstract type representing a windowing function for DSP.

[PainterQB.AlazarModule.InstrumentAlazar](AlazarTech.md#type__instrumentalazar.1)  An AlazarTech device. It can be used to control configuration parameters, to

[PainterQB.AlazarModule.WindowBartlett](AlazarTech.md#type__windowbartlett.1)  Bartlett window.

[PainterQB.AlazarModule.WindowBlackman](AlazarTech.md#type__windowblackman.1)  Blackman window.

[PainterQB.AlazarModule.WindowBlackmanHarris](AlazarTech.md#type__windowblackmanharris.1)  Blackman-Harris window.

[PainterQB.AlazarModule.WindowHamming](AlazarTech.md#type__windowhamming.1)  Hamming window.

[PainterQB.AlazarModule.WindowHanning](AlazarTech.md#type__windowhanning.1)  Hanning window.

[PainterQB.AlazarModule.WindowNone](AlazarTech.md#type__windownone.1)  Flat window (ones).

[PainterQB.AlazarModule.WindowZeroes](AlazarTech.md#type__windowzeroes.1)  Flat window (zeroes!).

---

## Typealiass [Exported]

[WindowOnes](AlazarTech.md#typealias__windowones.1)  Type alias for `WindowNone`.

---

## Globals [Exported]

[inf_records](AlazarTech.md#global__inf_records.1)  Alazar API representation of an infinite number of records.

---

## Functions [Internal]

[PainterQB.AlazarModule.adma](AlazarTech.md#function__adma.1)  Returns the asynchronous DMA flags for a given `AlazarMode`. These are

[PainterQB.AlazarModule.dsp](AlazarTech.md#function__dsp.1)  Given a DSPWindow type, this returns the constant needed to use the AlazarDSP

[PainterQB.AlazarModule.pretriggersamples](AlazarTech.md#function__pretriggersamples.1)  Given an `AlazarMode`, returns the number of pre-trigger samples.

[PainterQB.AlazarModule.rec_acq_param](AlazarTech.md#function__rec_acq_param.1)  Returns the value to pass as the recordsPerAcquisition parameter in the C

[PainterQB.AlazarModule.records_per_acquisition](AlazarTech.md#function__records_per_acquisition.1)  Given an `InstrumentAlazar` and `AlazarMode`, return the records per acquisition.

[PainterQB.AlazarModule.records_per_buffer](AlazarTech.md#function__records_per_buffer.1)  Given an `InstrumentAlazar` and `AlazarMode`, return the records per buffer.

[PainterQB.AlazarModule.samples_per_buffer_measured](AlazarTech.md#function__samples_per_buffer_measured.1)  Given an `InstrumentAlazar` and `AlazarMode`, return the samples per buffer

[PainterQB.AlazarModule.samples_per_buffer_returned](AlazarTech.md#function__samples_per_buffer_returned.1)  Given an `InstrumentAlazar` and `AlazarMode`, return the samples per buffer

[PainterQB.AlazarModule.samples_per_record_measured](AlazarTech.md#function__samples_per_record_measured.1)  Given an `InstrumentAlazar` and `AlazarMode`, return the samples per record

[PainterQB.AlazarModule.samples_per_record_returned](AlazarTech.md#function__samples_per_record_returned.1)  Given an `InstrumentAlazar` and `AlazarMode`, return the samples per record

---

## Methods [Internal]

[auxmode(m::UInt32,  b::Bool)](AlazarTech.md#method__auxmode.1)  Masks an AUX IO mode parameter to specify AUX IO software trigger enable.

[bits_per_sample(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__bits_per_sample.1)  Returns the number of bits per sample. Queries the digitizer directly via

[boardhandle(sysid::Integer,  boardid::Integer)](AlazarTech.md#method__boardhandle.1)  Return a handle to an Alazar digitizer given a system ID and board ID.

[boardkind(handle::UInt32)](AlazarTech.md#method__boardkind.1)  Returns the kind of digitizer; corresponds to a constant in AlazarConstants.jl

[bytes_per_sample(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__bytes_per_sample.1)  Returns the number of bytes per sample. Calls `bitspersample` and does ceiling

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](AlazarTech.md#method__generate_configure.1)  ```

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](AlazarTech.md#method__generate_handlers.1)  ### generate_handlers

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](AlazarTech.md#method__generate_inspect.1)  ```

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](AlazarTech.md#method__generate_properties.1)  Makes parametric subtypes and gives constructors. Also defines a code method.

[setwindow(window,  ::Type{PainterQB.AlazarModule.Im},  m::PainterQB.AlazarModule.FFTRecordMode)](AlazarTech.md#method__setwindow.1)  Set the window for the imag part of the FFT. Must be followed by calling `windowing`.

[setwindow(window,  ::Type{PainterQB.AlazarModule.Re},  m::PainterQB.AlazarModule.FFTRecordMode)](AlazarTech.md#method__setwindow.2)  Set the window for the real part of the FFT. Must be followed by calling `windowing`.

---

## Types [Internal]

[PainterQB.AlazarModule.AlazarATS9440](AlazarTech.md#type__alazarats9440.1)  Abstract type; not implemented.

---

## Macros [Internal]

[@eh2(expr)](AlazarTech.md#macro___eh2.1)  Takes an Alazar API call and brackets it with some error checking.

---

## Globals [Internal]

[lib_opened](AlazarTech.md#global__lib_opened.1)  Flag indicating whether the AlazarTech shared library has been opened.

