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

[inspect(ins::PainterQB.Instrument,  args::Tuple{Vararg{T}})](PainterQB.md#method__inspect.2)  Splat tuples into new inspect commands.

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

[source(ch::PainterQB.DummyStimulus)](PainterQB.md#method__source.2)  Returns a random number in the unit interval.

[source(ch::PainterQB.PropertyStimulus{T<:PainterQB.InstrumentProperty{Number}},  val::Real)](PainterQB.md#method__source.3)  Sourcing a PropertyStimulus configures an InstrumentProperty.

[source(ch::PainterQB.ThreadStimulus,  nw::Int64)](PainterQB.md#method__source.4)  Adds or removes threads to reach the desired number of worker threads.

[source{T}(ch::PainterQB.ResponseStimulus{T},  val)](PainterQB.md#method__source.5)  Sets the field named `:name` in the `Response` held by `ch` to `val`.

[sweep{T<:Real, N}(dep::PainterQB.Response{T<:Real},  indep::NTuple{N, Tuple{PainterQB.Stimulus, AbstractArray{T, N}}})](PainterQB.md#method__sweep.1)  Measures a response as a function of an arbitrary number of stimuli.

[sweep{T}(dep::PainterQB.Response{T},  indep::Tuple{PainterQB.Stimulus, AbstractArray{T, N}}...)](PainterQB.md#method__sweep.2)  This method is slightly more convenient than the other sweep method

[tcpip_instr(ip)](PainterQB.md#method__tcpip_instr.1)  Returns a INSTR `viSession` for the given IPv4 address string.

[tcpip_socket(ip,  port)](PainterQB.md#method__tcpip_socket.1)  Returns a raw socket `viSession` for the given IPv4 address string.

[test(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__test.1)  Test with the *TST? command.

[trigger(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__trigger.1)  Bus trigger with *TRG.

[unquoted(str::ASCIIString)](PainterQB.md#method__unquoted.1)  Strip a string of enclosing quotation marks.

[wait(ins::PainterQB.InstrumentVISA)](PainterQB.md#method__wait.1)  Wait for completion of a sweep.

[write(ins::PainterQB.InstrumentVISA,  msg::ASCIIString)](PainterQB.md#method__write.1)  Write to an instrument. Appends the instrument's write terminator.

---

## Types [Exported]

[PainterQB.All](PainterQB.md#type__all.1)  The All type is meant to be dispatched upon and not instantiated.

[PainterQB.AveragingResponse{T}](PainterQB.md#type__averagingresponse.1)  Response that averages other responses. Not clear if this is a good idea yet.

[PainterQB.ClockSlope](PainterQB.md#type__clockslope.1)  Clock may tick on a rising or falling slope.

[PainterQB.ClockSource](PainterQB.md#type__clocksource.1)  Clock source can be internal or external.

[PainterQB.Coupling](PainterQB.md#type__coupling.1)  Signals may be AC or DC coupled.

[PainterQB.DelayStimulus](PainterQB.md#type__delaystimulus.1)  A stimulus for delaying until time has passed since a reference time t0.

[PainterQB.DummyStimulus](PainterQB.md#type__dummystimulus.1)  Random number response suitable for testing the measurement code without having

[PainterQB.Frequency](PainterQB.md#type__frequency.1)  Fixed frequency of a sourced signal.

[PainterQB.FrequencyStart](PainterQB.md#type__frequencystart.1)  Start frequency of a fixed range.

[PainterQB.FrequencyStop](PainterQB.md#type__frequencystop.1)  Stop frequency of a fixed range.

[PainterQB.Instrument](PainterQB.md#type__instrument.1)  Abstract supertype representing an instrument.

[PainterQB.InstrumentException](PainterQB.md#type__instrumentexception.1)  Exception to be thrown by an instrument. Fields include the instrument in error

[PainterQB.InstrumentProperty{T}](PainterQB.md#type__instrumentproperty.1)  Abstract parametric supertype representing communications with an instrument.

[PainterQB.InstrumentVISA](PainterQB.md#type__instrumentvisa.1)  Abstract supertype of all Instruments addressable using a VISA library.

[PainterQB.NoArgs](PainterQB.md#type__noargs.1)  Used internally to indicate that a property takes no argument.

[PainterQB.NumPoints](PainterQB.md#type__numpoints.1)  Number of points per sweep.

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

[resourcemanager](PainterQB.md#global__resourcemanager.1)  The default VISA resource manager.

---

## Methods [Internal]

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](PainterQB.md#method__generate_configure.1)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](PainterQB.md#method__generate_configure.2)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](PainterQB.md#method__generate_configure.3)  This method generates the following method in the module where

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](PainterQB.md#method__generate_handlers.1)  Each instrument can have a `responseDict`. For each setting of the instrument,

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](PainterQB.md#method__generate_inspect.1)  This method does/returns nothing.

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](PainterQB.md#method__generate_inspect.2)  This method will

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](PainterQB.md#method__generate_properties.1)  Creates and exports immutable singleton subtypes.

---

## Globals [Internal]

[LIVE_DATA](PainterQB.md#global__live_data.1)  Condition indicating more data for a live update.

[LIVE_DIE](PainterQB.md#global__live_die.1)  Condition indicating the end of a live update.

[LIVE_NEW_MEAS](PainterQB.md#global__live_new_meas.1)  Condition indicating the start of a live update.

## MODULE: PainterQB.E5071CModule

---

## Types [Exported]

[PainterQB.E5071CModule.ElectricalMedium](E5071C.md#type__electricalmedium.1)  Signals may propagate on coax or waveguide media.

---

## Methods [Internal]

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](E5071C.md#method__generate_configure.1)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](E5071C.md#method__generate_configure.2)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](E5071C.md#method__generate_configure.3)  This method generates the following method in the module where

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](E5071C.md#method__generate_handlers.1)  Each instrument can have a `responseDict`. For each setting of the instrument,

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](E5071C.md#method__generate_inspect.1)  This method does/returns nothing.

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](E5071C.md#method__generate_inspect.2)  This method will

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](E5071C.md#method__generate_properties.1)  Creates and exports immutable singleton subtypes.

## MODULE: PainterQB.ZNB20Module

---

## Methods [Exported]

[cd(ins::PainterQB.ZNB20Module.ZNB20,  dir::AbstractString)](ZNB20.md#method__cd.1)  [MMEMory:CDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87010.htm)

[cp(ins::PainterQB.ZNB20Module.ZNB20,  src::AbstractString,  dest::AbstractString)](ZNB20.md#method__cp.1)  [MMEMory:COPY](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87048.htm)

[hidetrace(ins::PainterQB.ZNB20Module.ZNB20,  win::Int64,  wtrace::Int64)](ZNB20.md#method__hidetrace.1)  [DISPLAY:WINDOW#:TRACE#:DELETE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/35e75331f5ce4fce.htm)

[lstrace(ins::PainterQB.ZNB20Module.ZNB20,  ch::Int64)](ZNB20.md#method__lstrace.1)  [CALCULATE#:PARAMETER:CATALOG?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/2ce049f1af684d21.htm)

[mkdir(ins::PainterQB.ZNB20Module.ZNB20,  dir::AbstractString)](ZNB20.md#method__mkdir.1)  [MMEMory:MDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e89416.htm)

[mktrace(ins::PainterQB.ZNB20Module.ZNB20,  name::AbstractString,  parameter,  ch::Int64)](ZNB20.md#method__mktrace.1)  [CALCulate#:PARameter:SDEFine](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/e75d49e2a14541c5.htm)

[pwd(ins::PainterQB.ZNB20Module.ZNB20)](ZNB20.md#method__pwd.1)  [MMEMory:CDIRectory?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87010.htm)

[readdir(ins::PainterQB.ZNB20Module.ZNB20)](ZNB20.md#method__readdir.1)  [MMEMory:CATalog?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/7f7650b75a604b3d.htm)

[readdir(ins::PainterQB.ZNB20Module.ZNB20,  dir::AbstractString)](ZNB20.md#method__readdir.2)  [MMEMory:CATalog?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/7f7650b75a604b3d.htm)

[rm(ins::PainterQB.ZNB20Module.ZNB20,  file::AbstractString)](ZNB20.md#method__rm.1)  [MMEMory:DELete](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87202.htm)

[rmtrace(ins::PainterQB.ZNB20Module.ZNB20)](ZNB20.md#method__rmtrace.1)  [CALCulate:PARameter:DELete:ALL](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e69977.htm)

[rmtrace(ins::PainterQB.ZNB20Module.ZNB20,  ch::Int64)](ZNB20.md#method__rmtrace.2)  [CALCulate#:PARameter:DELete:CALL](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8d937272d97244fb.htm)

[rmtrace(ins::PainterQB.ZNB20Module.ZNB20,  name::AbstractString,  ch::Int64)](ZNB20.md#method__rmtrace.3)  [CALCULATE#:PARAMETER:DELETE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/0763f74d0a2d4d61.htm)

[showtrace(ins::PainterQB.ZNB20Module.ZNB20,  name::AbstractString,  win::Int64,  wtrace::Int64)](ZNB20.md#method__showtrace.1)  [DISPLAY:WINDOW#:TRACE#:FEED](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/58dad852e7db48a0.htm)

---

## Types [Exported]

[PainterQB.ZNB20Module.AutoSweepTime](ZNB20.md#type__autosweeptime.1)  Configure or inspect. Does the instrument choose the minimum sweep time?

[PainterQB.ZNB20Module.DisplayUpdate](ZNB20.md#type__displayupdate.1)  Configure or inspect. Display updates during measurement.

[PainterQB.ZNB20Module.SweepTime](ZNB20.md#type__sweeptime.1)  Configure or inspect. Adjust time it takes to complete a sweep (all partial measurements).

[PainterQB.ZNB20Module.Window](ZNB20.md#type__window.1)  `InstrumentProperty`: Window.

---

## Methods [Internal]

[configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints},  n::Int64)](ZNB20.md#method__configure.1)  [SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

[configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints},  n::Int64,  ch::Int64)](ZNB20.md#method__configure.2)  [SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

[configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime},  b::Bool)](ZNB20.md#method__configure.3)  [SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

[configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime},  b::Bool,  ch::Int64)](ZNB20.md#method__configure.4)  [SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

[configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.DisplayUpdate},  b::Bool)](ZNB20.md#method__configure.5)  [SYSTEM:DISPLAY:UPDATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e114067.htm)

[configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime},  time::Real)](ZNB20.md#method__configure.6)  [SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

[configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime},  time::Real,  ch::Int64)](ZNB20.md#method__configure.7)  [SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

[configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Window},  b::Bool,  win::Int64)](ZNB20.md#method__configure.8)  [DISPLAY:WINDOW#:STATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/065c895d5a2c4230.htm)

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](ZNB20.md#method__generate_configure.1)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](ZNB20.md#method__generate_configure.2)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](ZNB20.md#method__generate_configure.3)  This method generates the following method in the module where

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](ZNB20.md#method__generate_handlers.1)  Each instrument can have a `responseDict`. For each setting of the instrument,

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](ZNB20.md#method__generate_inspect.1)  This method does/returns nothing.

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](ZNB20.md#method__generate_inspect.2)  This method will

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](ZNB20.md#method__generate_properties.1)  Creates and exports immutable singleton subtypes.

[inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints})](ZNB20.md#method__inspect.1)  [SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

[inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints},  ch::Int64)](ZNB20.md#method__inspect.2)  [SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

[inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime})](ZNB20.md#method__inspect.3)  [SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

[inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime},  ch::Int64)](ZNB20.md#method__inspect.4)  [SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

[inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.DisplayUpdate})](ZNB20.md#method__inspect.5)  [SYSTEM:DISPLAY:UPDATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e114067.htm)

[inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime})](ZNB20.md#method__inspect.6)  [SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

[inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime},  ch::Int64)](ZNB20.md#method__inspect.7)  [SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

[inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Window},  win::Int64)](ZNB20.md#method__inspect.8)  Determines if a window exists, by window number. See `lswindow`.

[inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Window},  wname::AbstractString)](ZNB20.md#method__inspect.9)  Determines if a window exists, by window name. See `lswindow`.

[lswindows(ins::PainterQB.ZNB20Module.ZNB20)](ZNB20.md#method__lswindows.1)  [DISPLAY:CATALOG?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/abdd1db5dc0c48ee.htm)

## MODULE: PainterQB.E8257DModule

---

## Functions [Exported]

[PainterQB.E8257DModule.cumulativeattenuatorswitches](E8257D.md#function__cumulativeattenuatorswitches.1)  Returns the number of attenuator switching events over the instrument lifetime.

[PainterQB.E8257DModule.cumulativeontime](E8257D.md#function__cumulativeontime.1)  Returns the cumulative on-time over the instrument lifetime.

[PainterQB.E8257DModule.cumulativepowerons](E8257D.md#function__cumulativepowerons.1)  Returns the number of power on events over the instrument lifetime.

[PainterQB.E8257DModule.revision](E8257D.md#function__revision.1)  Reports the revision of the E8257D.

[PainterQB.options](E8257D.md#function__options.1)  Reports the options available for the given E8257D.

---

## Types [Exported]

[PainterQB.E8257DModule.ALC](E8257D.md#type__alc.1)  Boolean state of the ALC.

[PainterQB.E8257DModule.ALCBandwidth](E8257D.md#type__alcbandwidth.1)  ALC bandwidth.

[PainterQB.E8257DModule.ALCBandwidthAuto](E8257D.md#type__alcbandwidthauto.1)  Boolean state for automatic selection of the ALC bandwidth.

[PainterQB.E8257DModule.ALCLevel](E8257D.md#type__alclevel.1)  Level of the ALC when the attenuator hold is active.

[PainterQB.E8257DModule.AttenuatorAuto](E8257D.md#type__attenuatorauto.1)  Boolean state for automatic operation of the attenuator.

[PainterQB.E8257DModule.E8257D](E8257D.md#type__e8257d.1)  Concrete type representing an E8257D.

[PainterQB.E8257DModule.FlatnessCorrection](E8257D.md#type__flatnesscorrection.1)  Boolean state for flatness correction.

[PainterQB.E8257DModule.FrequencyReference](E8257D.md#type__frequencyreference.1)  Boolean state of the frequency reference level.

[PainterQB.E8257DModule.FrequencyReferenceLevel](E8257D.md#type__frequencyreferencelevel.1)  Reference level for configuring/inspecting frequency.

[PainterQB.E8257DModule.FrequencyStep](E8257D.md#type__frequencystep.1)  Step size for a frequency sweep.

[PainterQB.E8257DModule.OutputBlanking](E8257D.md#type__outputblanking.1)  Boolean state for the output blanking.

[PainterQB.E8257DModule.OutputBlankingAuto](E8257D.md#type__outputblankingauto.1)  Boolean state for automatic blanking of the output.

[PainterQB.E8257DModule.OutputSettled](E8257D.md#type__outputsettled.1)  Has the output settled?

[PainterQB.E8257DModule.PowerLimit](E8257D.md#type__powerlimit.1)  RF output power limit.

[PainterQB.E8257DModule.PowerLimitAdjustable](E8257D.md#type__powerlimitadjustable.1)  Boolean for whether or not the RF output power limit can be adjusted.

[PainterQB.E8257DModule.PowerReference](E8257D.md#type__powerreference.1)  Boolean state of the power reference level.

[PainterQB.E8257DModule.PowerReferenceLevel](E8257D.md#type__powerreferencelevel.1)  Reference level for configuring/inspecting power.

[PainterQB.E8257DModule.PowerStart](E8257D.md#type__powerstart.1)  Start power in a sweep.

[PainterQB.E8257DModule.PowerStep](E8257D.md#type__powerstep.1)  Step size for a power sweep.

[PainterQB.E8257DModule.PowerStop](E8257D.md#type__powerstop.1)  Stop power in a sweep.

---

## Methods [Internal]

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](E8257D.md#method__generate_configure.1)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](E8257D.md#method__generate_configure.2)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](E8257D.md#method__generate_configure.3)  This method generates the following method in the module where

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](E8257D.md#method__generate_handlers.1)  Each instrument can have a `responseDict`. For each setting of the instrument,

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](E8257D.md#method__generate_inspect.1)  This method does/returns nothing.

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](E8257D.md#method__generate_inspect.2)  This method will

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](E8257D.md#method__generate_properties.1)  Creates and exports immutable singleton subtypes.

## MODULE: PainterQB.AWG5014CModule

---

## Functions [Exported]

[PainterQB.AWG5014CModule.applicationstate](AWG5014C.md#function__applicationstate.1)  Is an application running?

[PainterQB.AWG5014CModule.clearwaveforms](AWG5014C.md#function__clearwaveforms.1)  Clear waveforms from all channels.

[PainterQB.AWG5014CModule.deletewaveform](AWG5014C.md#function__deletewaveform.1)  Delete a waveform by name.

[PainterQB.AWG5014CModule.load_awg_settings](AWG5014C.md#function__load_awg_settings.1)  Load an AWG settings file.

[PainterQB.AWG5014CModule.newwaveform](AWG5014C.md#function__newwaveform.1)  Create a new waveform by name, number of points, and waveform type.

[PainterQB.AWG5014CModule.normalizewaveform](AWG5014C.md#function__normalizewaveform.1)  Normalize a waveform.

[PainterQB.AWG5014CModule.pullfrom_awg](AWG5014C.md#function__pullfrom_awg.1)  Pull data from the AWG, performing checks and generating errors as appropriate.

[PainterQB.AWG5014CModule.pushto_awg](AWG5014C.md#function__pushto_awg.1)  Push waveform data to the AWG, performing checks and generating errors as appropriate.

[PainterQB.AWG5014CModule.resamplewaveform](AWG5014C.md#function__resamplewaveform.1)  Resample a waveform.

[PainterQB.AWG5014CModule.runapplication](AWG5014C.md#function__runapplication.1)  Run an application, e.g. SerialXpress

[PainterQB.AWG5014CModule.save_awg_settings](AWG5014C.md#function__save_awg_settings.1)  Save an AWG settings file.

[PainterQB.AWG5014CModule.validate](AWG5014C.md#function__validate.1)  Validates data to be pushed to the AWG to check for internal consistency

[PainterQB.AWG5014CModule.waveform](AWG5014C.md#function__waveform.1)  Uses Julia style indexing (begins at 1) to retrieve the name of a waveform

[PainterQB.AWG5014CModule.waveformexists](AWG5014C.md#function__waveformexists.1)  Does a waveform identified by `name` exist?

[PainterQB.AWG5014CModule.waveformispredefined](AWG5014C.md#function__waveformispredefined.1)  Returns whether or not a waveform is predefined (comes with instrument).

[PainterQB.AWG5014CModule.waveformlength](AWG5014C.md#function__waveformlength.1)  Returns the length of a waveform.

[PainterQB.AWG5014CModule.waveformtimestamp](AWG5014C.md#function__waveformtimestamp.1)  Return the timestamp for when a waveform was last updated.

[PainterQB.AWG5014CModule.waveformtype](AWG5014C.md#function__waveformtype.1)  Returns the type of the waveform. The AWG hardware

---

## Types [Exported]

[PainterQB.AWG5014CModule.AWG5014C](AWG5014C.md#type__awg5014c.1)  Concrete type representing an AWG5014C.

[PainterQB.AWG5014CModule.AWG5014CData](AWG5014C.md#type__awg5014cdata.1)  Type for storing waveform data (including markers) in Float32 format.

[PainterQB.AWG5014CModule.Amplitude](AWG5014C.md#type__amplitude.1)  Amplitude for a given channel.

[PainterQB.AWG5014CModule.AnalogOutputDelay](AWG5014C.md#type__analogoutputdelay.1)  Analog output delay for a given channel.

[PainterQB.AWG5014CModule.ChannelOutput](AWG5014C.md#type__channeloutput.1)  Boolean state of the output for a given channel.

[PainterQB.AWG5014CModule.DCOutput](AWG5014C.md#type__dcoutput.1)  Boolean state of the DC output for a given channel (bottom-right of AWG).

[PainterQB.AWG5014CModule.DCOutputLevel](AWG5014C.md#type__dcoutputlevel.1)  DC output level for a given channel.

[PainterQB.AWG5014CModule.EventImpedance](AWG5014C.md#type__eventimpedance.1)  Event input impedance may be 50 Ohm or 1 kOhm.

[PainterQB.AWG5014CModule.EventSlope](AWG5014C.md#type__eventslope.1)  Event may fire on a rising or falling slope.

[PainterQB.AWG5014CModule.EventTiming](AWG5014C.md#type__eventtiming.1)  Events may occur synchronously or asynchronously.

[PainterQB.AWG5014CModule.ExtInputAddsToOutput](AWG5014C.md#type__extinputaddstooutput.1)  Add the signal from an external input to the given channel output.

[PainterQB.AWG5014CModule.ExtOscDividerRate](AWG5014C.md#type__extoscdividerrate.1)  Divider rate of the external oscillator; must be a power of 2 (1 ok).

[PainterQB.AWG5014CModule.MarkerDelay](AWG5014C.md#type__markerdelay.1)  Marker delay for a given channel and marker. Marker can be 1 or 2.

[PainterQB.AWG5014CModule.OutputFilterFrequency](AWG5014C.md#type__outputfilterfrequency.1)  Low-pass filter frequency for the output. INF = 9.9e37

[PainterQB.AWG5014CModule.RefOscFrequency](AWG5014C.md#type__refoscfrequency.1)  Reference oscillator frequency.

[PainterQB.AWG5014CModule.RefOscMultiplier](AWG5014C.md#type__refoscmultiplier.1)  Reference oscillator multiplier.

[PainterQB.AWG5014CModule.RepRate](AWG5014C.md#type__reprate.1)  Repetition rate (frequency of waveform). Changing this will change the

[PainterQB.AWG5014CModule.RepRateHeld](AWG5014C.md#type__reprateheld.1)  Boolean hold state of the repetition rate. If held, the repetition rate will

[PainterQB.AWG5014CModule.SCPIVersion](AWG5014C.md#type__scpiversion.1)  The SCPI version of the AWG.

[PainterQB.AWG5014CModule.SequencerEventJumpTarget](AWG5014C.md#type__sequencereventjumptarget.1)  Target index for the sequencer event jump operation.

[PainterQB.AWG5014CModule.SequencerGOTOState](AWG5014C.md#type__sequencergotostate.1)  Boolean GOTO state of the sequencer.

[PainterQB.AWG5014CModule.SequencerGOTOTarget](AWG5014C.md#type__sequencergototarget.1)  Target index for the GOTO command of the sequencer.

[PainterQB.AWG5014CModule.SequencerInfiniteLoop](AWG5014C.md#type__sequencerinfiniteloop.1)  Boolean state of infinite loop on a sequencer element.

[PainterQB.AWG5014CModule.SequencerLength](AWG5014C.md#type__sequencerlength.1)  Length of the sequence. Can be destructive to existing sequences.

[PainterQB.AWG5014CModule.SequencerLoopCount](AWG5014C.md#type__sequencerloopcount.1)  Loop count of the sequencer, from 1 to 65536. Ignored if infinite loop.

[PainterQB.AWG5014CModule.SequencerPosition](AWG5014C.md#type__sequencerposition.1)  Current sequencer position.

[PainterQB.AWG5014CModule.SequencerType](AWG5014C.md#type__sequencertype.1)  Sequencer may be hardware or software.

[PainterQB.AWG5014CModule.TriggerMode](AWG5014C.md#type__triggermode.1)  Trigger engine may be triggered, continuously firing, gated, or sequenced.

[PainterQB.AWG5014CModule.TriggerTimer](AWG5014C.md#type__triggertimer.1)  Internal trigger rate.

[PainterQB.AWG5014CModule.VoltageOffset](AWG5014C.md#type__voltageoffset.1)  Offset voltage for a given channel.

[PainterQB.AWG5014CModule.WaitingForTrigger](AWG5014C.md#type__waitingfortrigger.1)  When inspected, will report if the instrument is waiting for a trigger.

[PainterQB.AWG5014CModule.Waveform](AWG5014C.md#type__waveform.1)  Name of a waveform loaded into a given channel.

[PainterQB.AWG5014CModule.WaveformType](AWG5014C.md#type__waveformtype.1)  Waveform type may be integer or real.

[PainterQB.AWG5014CModule.WavelistLength](AWG5014C.md#type__wavelistlength.1)  The number of waveforms stored in the AWG.

---

## Macros [Exported]

[@allch(x::Expr)](AWG5014C.md#macro___allch.1)  Macro for performing an operation on every channel,

---

## Functions [Internal]

[PainterQB.AWG5014CModule.nbytes](AWG5014C.md#function__nbytes.1)  Returns the number of bytes per sample for a a given waveform type.

[PainterQB.AWG5014CModule.pulllowlevel](AWG5014C.md#function__pulllowlevel.1)  Takes care of the dirty work in pulling data from the AWG.

[PainterQB.AWG5014CModule.pushlowlevel](AWG5014C.md#function__pushlowlevel.1)  Takes care of the dirty work in pushing the data to the AWG.

---

## Methods [Internal]

[configure(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.AWG5014CModule.Amplitude},  ampl::Real,  ch::Integer)](AWG5014C.md#method__configure.1)  Configure Vpp for a given channel, between 0.05 V and 2 V.

[configure(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.AWG5014CModule.Waveform},  name::ASCIIString,  ch::Integer)](AWG5014C.md#method__configure.2)  Configure the waveform by name for a given channel.

[configure(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.Output},  on::Bool)](AWG5014C.md#method__configure.3)  Configure the global analog output state of the AWG.

[configure(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.Phase},  phase::Real,  ch::Integer)](AWG5014C.md#method__configure.4)  Set the output phase in degrees for a given channel.

[configure(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.SampleRate},  rate::Real)](AWG5014C.md#method__configure.5)  Configure the sample rate in Hz between 10 MHz and 10 GHz.

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](AWG5014C.md#method__generate_configure.1)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](AWG5014C.md#method__generate_configure.2)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](AWG5014C.md#method__generate_configure.3)  This method generates the following method in the module where

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](AWG5014C.md#method__generate_handlers.1)  Each instrument can have a `responseDict`. For each setting of the instrument,

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](AWG5014C.md#method__generate_inspect.1)  This method does/returns nothing.

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](AWG5014C.md#method__generate_inspect.2)  This method will

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](AWG5014C.md#method__generate_properties.1)  Creates and exports immutable singleton subtypes.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.AWG5014CModule.Amplitude},  ch::Integer)](AWG5014C.md#method__inspect.1)  Inspect Vpp for a given channel.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.AWG5014CModule.SequencerType})](AWG5014C.md#method__inspect.2)  Returns current sequencer type.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.AWG5014CModule.WaitingForTrigger})](AWG5014C.md#method__inspect.3)  Inspect whether or not the instrument is waiting for a trigger.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.AWG5014CModule.Waveform},  ch::Integer)](AWG5014C.md#method__inspect.4)  Inspect the waveform name for a given channel.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.Output})](AWG5014C.md#method__inspect.5)  Inspect the global analog output state of the AWG.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.Phase},  ch::Integer)](AWG5014C.md#method__inspect.6)  Get the output phase in degrees for a given channel.

[inspect(ins::PainterQB.AWG5014CModule.AWG5014C,  ::Type{PainterQB.SampleRate})](AWG5014C.md#method__inspect.7)  Get the sample rate in Hz. Output rate = sample rate / number of points.

---

## Globals [Internal]

[byteLimit](AWG5014C.md#global__bytelimit.1)  Maximum number of bytes that may be sent using the SCPI command WLIS:WAV:DATA.

[exceptions](AWG5014C.md#global__exceptions.1)  Exception dictionary mapping signed integers to error strings.

[maximumValue](AWG5014C.md#global__maximumvalue.1)  Constant used for synthesizing/interpreting waveforms of integer type.

[minimumValue](AWG5014C.md#global__minimumvalue.1)  Constant used for synthesizing/interpreting waveforms of integer type.

[noError](AWG5014C.md#global__noerror.1)  Internal AWG code meaning no errors.

[offsetPlusPPOver2](AWG5014C.md#global__offsetplusppover2.1)  Constant used for synthesizing/interpreting waveforms of integer type.

[offsetValue](AWG5014C.md#global__offsetvalue.1)  Constant used for synthesizing/interpreting waveforms of integer type.

## MODULE: PainterQB.AlazarModule

---

## Functions [Exported]

[PainterQB.AlazarModule.abort](AlazarTech.md#function__abort.1)  Aborts an acquisition. Must be called in the case of a DSP acquisition; somehow

[PainterQB.AlazarModule.before_async_read](AlazarTech.md#function__before_async_read.1)  Performs setup for asynchronous acquisitions. Should be called after

[PainterQB.AlazarModule.bufferarray](AlazarTech.md#function__bufferarray.1)  Given and `InstrumentAlazar` and `AlazarMode`, returns a `DMABufferArray`

[PainterQB.AlazarModule.buffersizing](AlazarTech.md#function__buffersizing.1)  Given an `InstrumentAlazar` and an `AlazarMode`, this will tweak parameters

[PainterQB.AlazarModule.fft_fpga_setup](AlazarTech.md#function__fft_fpga_setup.1)  If necessary, performs `AlazarFFTSetup`, which should be called before

[PainterQB.AlazarModule.recordsizing](AlazarTech.md#function__recordsizing.1)  Calls C function `AlazarSetRecordSize` if necessary, given an `InstrumentAlazar`

[PainterQB.AlazarModule.wait_buffer](AlazarTech.md#function__wait_buffer.1)  Waits for a buffer to be processed (or a timeout to elapse).

---

## Methods [Exported]

[busy(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__busy.1)  Returns whether or not the `InstrumentAlazar` is busy (Bool).

[configure(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.SampleRate},  rate::Real)](AlazarTech.md#method__configure.1)  Configure the sample rate to any multiple of 1 MHz (within 300 MHz and 1.8 GHz)

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AuxSoftwareTriggerEnable},  b::Bool)](AlazarTech.md#method__configure.2)  If an AUX IO output mode has been configured, then this will configure

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.LED},  ledState::Bool)](AlazarTech.md#method__configure.3)  Configures the LED on the digitizer card chassis.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.RecordCount},  count)](AlazarTech.md#method__configure.4)  Wrapper for C function `AlazarSetRecordCount`. See the Alazar API.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.Sleep},  sleepState)](AlazarTech.md#method__configure.5)  Configures the sleep state of the digitizer card.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.TriggerDelaySamples},  delay_samples)](AlazarTech.md#method__configure.6)  Configure how many samples to wait after receiving a trigger event before capturing

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.TriggerTimeoutS},  timeout_s)](AlazarTech.md#method__configure.7)  Wrapper for C function `AlazarSetTriggerTimeOut`, except we take seconds here

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.TriggerTimeoutTicks},  ticks)](AlazarTech.md#method__configure.8)  Wrapper for C function `AlazarSetTriggerTimeOut`.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.TriggerLevel},  levelJ,  levelK)](AlazarTech.md#method__configure.9)  Configure the trigger level for trigger engine J and K. This should be an

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxDigitalInput})](AlazarTech.md#method__configure.10)  Configure a digitizer's AUX IO to act as a digital input.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxDigitalOutput},  level::Integer)](AlazarTech.md#method__configure.11)  Configure a digitizer's AUX IO port to act as a general purpose digital output.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxOutputPacer},  divider::Integer)](AlazarTech.md#method__configure.12)  Configure a digitizer's AUX IO port to output the sample clock, divided by an integer.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxOutputTrigger})](AlazarTech.md#method__configure.13)  Configure a digitizer's AUX IO to output a trigger signal synced to the sample clock.

[configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ch::Type{PainterQB.AlazarModule.BothChannels})](AlazarTech.md#method__configure.14)  Configures acquisition from both channels, simultaneously.

[configure{S<:PainterQB.AlazarModule.AlazarDataPacking}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  pack::Type{S<:PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{PainterQB.AlazarModule.BothChannels})](AlazarTech.md#method__configure.15)  Configures the data packing mode for both channels.

[configure{S<:PainterQB.AlazarModule.AlazarDataPacking}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  pack::Type{S<:PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{PainterQB.AlazarModule.ChannelA})](AlazarTech.md#method__configure.16)  Configures the data packing mode for channel A.

[configure{S<:PainterQB.AlazarModule.AlazarDataPacking}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  pack::Type{S<:PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{PainterQB.AlazarModule.ChannelB})](AlazarTech.md#method__configure.17)  Configures the data packing mode for channel B.

[configure{S<:PainterQB.AlazarModule.DSPWindow{T}, T<:PainterQB.AlazarModule.DSPWindow{T}}(a::PainterQB.AlazarModule.AlazarATS9360,  re::Type{S<:PainterQB.AlazarModule.DSPWindow{T}},  im::Type{T<:PainterQB.AlazarModule.DSPWindow{T}})](AlazarTech.md#method__configure.18)  Configures the DSP windows. `AlazarFFTSetWindowFunction` is called towards

[configure{S<:PainterQB.TriggerSlope, T<:PainterQB.TriggerSlope}(a::PainterQB.AlazarModule.InstrumentAlazar,  slopeJ::Type{S<:PainterQB.TriggerSlope},  slopeK::Type{T<:PainterQB.TriggerSlope})](AlazarTech.md#method__configure.19)  Configures whether to trigger on a rising or falling slope, for engine J and K.

[configure{S<:PainterQB.TriggerSource, T<:PainterQB.TriggerSource}(a::PainterQB.AlazarModule.InstrumentAlazar,  sourceJ::Type{S<:PainterQB.TriggerSource},  sourceK::Type{T<:PainterQB.TriggerSource})](AlazarTech.md#method__configure.20)  Configure the trigger source for trigger engine J and K.

[configure{T<:PainterQB.AlazarModule.AlazarChannel}(a::PainterQB.AlazarModule.InstrumentAlazar,  ch::Type{T<:PainterQB.AlazarModule.AlazarChannel})](AlazarTech.md#method__configure.21)  Configures the acquisition channel.

[configure{T<:PainterQB.AlazarModule.AlazarTimestampReset}(a::PainterQB.AlazarModule.InstrumentAlazar,  t::Type{T<:PainterQB.AlazarModule.AlazarTimestampReset})](AlazarTech.md#method__configure.22)  Configures timestamp reset. From the Alazar API, the choices are

[configure{T<:PainterQB.AlazarModule.AlazarTriggerEngine}(a::PainterQB.AlazarModule.InstrumentAlazar,  engine::Type{T<:PainterQB.AlazarModule.AlazarTriggerEngine})](AlazarTech.md#method__configure.23)  Configures the trigger engines, e.g. TriggerOnJ, TriggerOnJAndNotK, etc.

[configure{T<:PainterQB.AlazarModule.AlazarTriggerRange}(a::PainterQB.AlazarModule.AlazarATS9360,  range::Type{T<:PainterQB.AlazarModule.AlazarTriggerRange})](AlazarTech.md#method__configure.24)  Does nothing but display info telling you that this parameter cannot be changed

[configure{T<:PainterQB.AlazarModule.AlazarTriggerRange}(a::PainterQB.AlazarModule.InstrumentAlazar,  range::Type{T<:PainterQB.AlazarModule.AlazarTriggerRange})](AlazarTech.md#method__configure.25)  Configure the external trigger range.

[configure{T<:PainterQB.ClockSlope}(a::PainterQB.AlazarModule.InstrumentAlazar,  slope::Type{T<:PainterQB.ClockSlope})](AlazarTech.md#method__configure.26)  Configures whether the clock ticks on a rising or falling slope.

[configure{T<:PainterQB.Coupling}(a::PainterQB.AlazarModule.AlazarATS9360,  coupling::Type{T<:PainterQB.Coupling})](AlazarTech.md#method__configure.27)  Does nothing but display info telling you that this parameter cannot be changed

[configure{T<:PainterQB.Coupling}(a::PainterQB.AlazarModule.InstrumentAlazar,  coupling::Type{T<:PainterQB.Coupling})](AlazarTech.md#method__configure.28)  Configure the external trigger coupling.

[configure{T<:PainterQB.SampleRate}(a::PainterQB.AlazarModule.InstrumentAlazar,  rate::Type{T<:PainterQB.SampleRate})](AlazarTech.md#method__configure.29)  Configures one of the preset sample rates derived from the internal clock.

[configure{T<:PainterQB.TriggerSlope}(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxInputTriggerEnable},  trigSlope::Type{T<:PainterQB.TriggerSlope})](AlazarTech.md#method__configure.30)  Configure a digitizer's AUX IO port to use the edge of a pulse as an AutoDMA

[dsp_getinfo(dspModule::PainterQB.AlazarModule.DSPModule)](AlazarTech.md#method__dsp_getinfo.1)  Returns a DSPModuleInfo object that describes a DSPModule.

[dsp_getmodulehandles(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__dsp_getmodulehandles.1)  Returns an Array of `dsp_module_handle`.

[dsp_modules(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__dsp_modules.1)  Returns an array of `DSPModule`.

[dsp_num_modules(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__dsp_num_modules.1)  Returns the number of `DSPModule`.

[forcetrigger(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__forcetrigger.1)  Force a software trigger.

[forcetriggerenable(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__forcetriggerenable.1)  Force a software "trigger enable." This involves the AUX I/O connector (see

[inputcontrol(a::PainterQB.AlazarModule.InstrumentAlazar,  channel,  coupling,  inputRange,  impedance)](AlazarTech.md#method__inputcontrol.1)  Controls coupling, input range, and impedance for applicable digitizer cards.

[inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.BufferAlignment})](AlazarTech.md#method__inspect.1)  Returns the buffer alignment requirement (samples / record / channel).

[inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.MaxBufferBytes})](AlazarTech.md#method__inspect.2)  Maximum number of bytes for a given DMA buffer.

[inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.MaxFFTSamples})](AlazarTech.md#method__inspect.3)  Maximum number of samples in an FPGA-based FFT. Can be obtained from `dsp_getinfo`

[inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.MinFFTSamples})](AlazarTech.md#method__inspect.4)  Minimum number of samples in an FPGA-based FFT. Set by the minimum record size.

[inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.MinSamplesPerRecord})](AlazarTech.md#method__inspect.5)  Minimum samples per record. Observed behavior deviates from Table 8 of the

[inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.PretriggerAlignment})](AlazarTech.md#method__inspect.6)  Returns the pretrigger alignment requirement (samples / record / channel).

[inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarAux})](AlazarTech.md#method__inspect.7)  Inspect the AUX IO mode.

[inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarChannel})](AlazarTech.md#method__inspect.8)  Returns which channel(s) will be acquired.

[inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.ChannelCount})](AlazarTech.md#method__inspect.9)  Returns the number of channels to acquire.

[inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.SampleMemoryPerChannel})](AlazarTech.md#method__inspect.10)  Returns the memory per channel in units of samples.

[inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.SampleRate})](AlazarTech.md#method__inspect.11)  Inspect the sample rate. As currently programmed, does not distinguish

[inspect{T<:PainterQB.AlazarModule.AlazarChannel}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{T<:PainterQB.AlazarModule.AlazarChannel})](AlazarTech.md#method__inspect.12)  Inspect the data packing mode for a given channel.

[measure(ch::PainterQB.AlazarModule.AlazarResponse{T})](AlazarTech.md#method__measure.1)  Largely generic method for measuring `AlazarResponse`. Can be considered a

[measure(ch::PainterQB.AlazarModule.IQSoftwareResponse{T})](AlazarTech.md#method__measure.2)  Assume two-channel IQ FFT acquisition.

[post_async_buffer(a::PainterQB.AlazarModule.InstrumentAlazar,  buffer,  bufferLength)](AlazarTech.md#method__post_async_buffer.1)  Post an asynchronous buffer to the digitizer for use in an acquisition.

[set_parameter(a::PainterQB.AlazarModule.InstrumentAlazar,  channelId,  parameterId,  value)](AlazarTech.md#method__set_parameter.1)  Julia wrapper for C function AlazarSetParameter, with error checking.

[set_parameter_ul(a::PainterQB.AlazarModule.InstrumentAlazar,  channelId,  parameterId,  value)](AlazarTech.md#method__set_parameter_ul.1)  Julia wrapper for C function AlazarSetParameterUL, with error checking.

[set_triggeroperation(a::PainterQB.AlazarModule.InstrumentAlazar,  args...)](AlazarTech.md#method__set_triggeroperation.1)  Configure the trigger operation. Usually not called directly.

[startcapture(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__startcapture.1)  Should be called after `before_async_read` has been called and buffers are posted.

[triggered(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__triggered.1)  Reports whether or not the digitizer has been triggered.

---

## Types [Exported]

[PainterQB.AlazarModule.AlazarATS9360](AlazarTech.md#type__alazarats9360.1)  Concrete InstrumentAlazar subtype representing an ATS9360 digitizer.

[PainterQB.AlazarModule.DSPModule](AlazarTech.md#type__dspmodule.1)  Represents a DSP module of an AlazarTech digitizer.

[PainterQB.AlazarModule.DSPModuleInfo](AlazarTech.md#type__dspmoduleinfo.1)  Encapsulates DSP module information: type, version, and max record length.

[PainterQB.AlazarModule.DSPWindow{T}](AlazarTech.md#type__dspwindow.1)  Abstract parametric type representing a windowing function for DSP.

[PainterQB.AlazarModule.InstrumentAlazar](AlazarTech.md#type__instrumentalazar.1)  Abstract type representing an AlazarTech digitizer.

[PainterQB.AlazarModule.WindowBartlett{T}](AlazarTech.md#type__windowbartlett.1)  Bartlett window. Implemented in AlazarDSP.

[PainterQB.AlazarModule.WindowBlackmanHarris{T}](AlazarTech.md#type__windowblackmanharris.1)  Blackman-Harris window. Implemented in AlazarDSP.

[PainterQB.AlazarModule.WindowBlackman{T}](AlazarTech.md#type__windowblackman.1)  Blackman window. Implemented in AlazarDSP.

[PainterQB.AlazarModule.WindowHamming{T}](AlazarTech.md#type__windowhamming.1)  Hamming window. Implemented in AlazarDSP.

[PainterQB.AlazarModule.WindowHanning{T}](AlazarTech.md#type__windowhanning.1)  Hanning window. Implemented in AlazarDSP.

[PainterQB.AlazarModule.WindowNone{T}](AlazarTech.md#type__windownone.1)  Flat window (ones). Implemented in AlazarDSP.

[PainterQB.AlazarModule.WindowZeroes{T}](AlazarTech.md#type__windowzeroes.1)  Flat window (zeroes!).

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

[PainterQB.AlazarModule.generatewindowfunction](AlazarTech.md#function__generatewindowfunction.1)  Given a `DSPWindow`, samples per record, and padding samples, this will prepare

[PainterQB.AlazarModule.initmodes](AlazarTech.md#function__initmodes.1)  Should be called at the beginning of a measure method to initialize the

[PainterQB.AlazarModule.postprocess](AlazarTech.md#function__postprocess.1)  Arrange for reinterpretation or conversion of the data stored in the

[PainterQB.AlazarModule.pretriggersamples](AlazarTech.md#function__pretriggersamples.1)  Given an `AlazarMode`, returns the number of pre-trigger samples.

[PainterQB.AlazarModule.processing](AlazarTech.md#function__processing.1)  Specifies what to do with the buffers during measurement based on the response type.

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

[bits_per_sample(a::PainterQB.AlazarModule.AlazarATS9360)](AlazarTech.md#method__bits_per_sample.1)  Hard coded to return 0x0c. May need to change if we want to play with data packing.

[bits_per_sample(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__bits_per_sample.2)  Returns the number of bits per sample. Queries the digitizer directly via

[boardhandle(sysid::Integer,  boardid::Integer)](AlazarTech.md#method__boardhandle.1)  Return a handle to an Alazar digitizer given a system ID and board ID.

[boardkind(handle::UInt32)](AlazarTech.md#method__boardkind.1)  Returns the kind of digitizer; corresponds to a constant in AlazarConstants.jl

[bytes_per_sample(a::PainterQB.AlazarModule.AlazarATS9360)](AlazarTech.md#method__bytes_per_sample.1)  Hard coded to return 2. May need to change if we want to play with data packing.

[bytes_per_sample(a::PainterQB.AlazarModule.InstrumentAlazar)](AlazarTech.md#method__bytes_per_sample.2)  Returns the number of bytes per sample. Calls `bitspersample` and does ceiling

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}})](AlazarTech.md#method__generate_configure.1)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](AlazarTech.md#method__generate_configure.2)  This method generates the following method in the module where

[generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](AlazarTech.md#method__generate_configure.3)  This method generates the following method in the module where

[generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V})](AlazarTech.md#method__generate_handlers.1)  Each instrument can have a `responseDict`. For each setting of the instrument,

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs})](AlazarTech.md#method__generate_inspect.1)  This method does/returns nothing.

[generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...)](AlazarTech.md#method__generate_inspect.2)  This method will

[generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}})](AlazarTech.md#method__generate_properties.1)  Creates and exports immutable singleton subtypes.

[iqfft(sam_per_buf::Int64,  buf_completed::Int64,  rec_per_buf::Int64,  backing::SharedArray{T, N},  fft_array::SharedArray{T, N})](AlazarTech.md#method__iqfft.1)  Convert and copy

[scaling{T<:AbstractArray{T, N}}(resp::PainterQB.AlazarModule.FFTResponse{T<:AbstractArray{T, N}})](AlazarTech.md#method__scaling.1)  Returns the axis scaling for an FFT response.

[scaling{T<:AbstractArray{T, N}}(resp::PainterQB.AlazarModule.FFTResponse{T<:AbstractArray{T, N}},  whichaxis::Integer)](AlazarTech.md#method__scaling.2)  Returns the axis scaling for an FFT response.

[tofloat!(sam_per_buf::Int64,  buf_completed::Int64,  backing::SharedArray{T, N})](AlazarTech.md#method__tofloat.1)  Arrange multithreaded conversion of the Alazar 12-bit integer format to 16-bit

[triglevel(a::PainterQB.AlazarModule.AlazarATS9360,  x)](AlazarTech.md#method__triglevel.1)  Returns a UInt32 in the range 0--255 given a desired trigger level in Volts.

---

## Types [Internal]

[PainterQB.AlazarModule.AlazarATS9440](AlazarTech.md#type__alazarats9440.1)  Abstract type; not implemented.

---

## Macros [Internal]

[@eh2(expr)](AlazarTech.md#macro___eh2.1)  Takes an Alazar API call and brackets it with some error checking.

---

## Globals [Internal]

[lib_opened](AlazarTech.md#global__lib_opened.1)  Flag indicating whether the AlazarTech shared library has been opened.

