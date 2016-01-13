# PainterQB.ZNB20Module


## Methods [Exported]

---

<a id="method__cd.1" class="lexicon_definition"></a>
#### cd(ins::PainterQB.ZNB20Module.ZNB20,  dir::AbstractString) [¶](#method__cd.1)
[MMEMory:CDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87010.htm)

Change directories. Pass "~" for default.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:184](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L184)

---

<a id="method__cp.1" class="lexicon_definition"></a>
#### cp(ins::PainterQB.ZNB20Module.ZNB20,  src::AbstractString,  dest::AbstractString) [¶](#method__cp.1)
[MMEMory:COPY](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87048.htm)

Copy a file.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:197](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L197)

---

<a id="method__hidetrace.1" class="lexicon_definition"></a>
#### hidetrace(ins::PainterQB.ZNB20Module.ZNB20,  win::Int64,  wtrace::Int64) [¶](#method__hidetrace.1)
[DISPLAY:WINDOW#:TRACE#:DELETE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/35e75331f5ce4fce.htm)

Releases the assignment of window trace `wtrace` to window `win`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:206](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L206)

---

<a id="method__lstrace.1" class="lexicon_definition"></a>
#### lstrace(ins::PainterQB.ZNB20Module.ZNB20,  ch::Int64) [¶](#method__lstrace.1)
[CALCULATE#:PARAMETER:CATALOG?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/2ce049f1af684d21.htm)

Report the traces assigned to a given channel.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:215](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L215)

---

<a id="method__mkdir.1" class="lexicon_definition"></a>
#### mkdir(ins::PainterQB.ZNB20Module.ZNB20,  dir::AbstractString) [¶](#method__mkdir.1)
[MMEMory:MDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e89416.htm)

Make a directory.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:240](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L240)

---

<a id="method__mktrace.1" class="lexicon_definition"></a>
#### mktrace(ins::PainterQB.ZNB20Module.ZNB20,  name::AbstractString,  parameter,  ch::Int64) [¶](#method__mktrace.1)
[CALCulate#:PARameter:SDEFine](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/e75d49e2a14541c5.htm)

Create a new trace with `name` and measurement `parameter` on channel `ch`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:249](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L249)

---

<a id="method__pwd.1" class="lexicon_definition"></a>
#### pwd(ins::PainterQB.ZNB20Module.ZNB20) [¶](#method__pwd.1)
[MMEMory:CDIRectory?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87010.htm)

Print the working directory.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:260](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L260)

---

<a id="method__readdir.1" class="lexicon_definition"></a>
#### readdir(ins::PainterQB.ZNB20Module.ZNB20) [¶](#method__readdir.1)
[MMEMory:CATalog?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/7f7650b75a604b3d.htm)

Read the directory contents.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:269](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L269)

---

<a id="method__readdir.2" class="lexicon_definition"></a>
#### readdir(ins::PainterQB.ZNB20Module.ZNB20,  dir::AbstractString) [¶](#method__readdir.2)
[MMEMory:CATalog?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/7f7650b75a604b3d.htm)

Read the directory contents.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:269](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L269)

---

<a id="method__rm.1" class="lexicon_definition"></a>
#### rm(ins::PainterQB.ZNB20Module.ZNB20,  file::AbstractString) [¶](#method__rm.1)
[MMEMory:DELete](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87202.htm)

Remove a file.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:282](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L282)

---

<a id="method__rmtrace.1" class="lexicon_definition"></a>
#### rmtrace(ins::PainterQB.ZNB20Module.ZNB20) [¶](#method__rmtrace.1)
[CALCulate:PARameter:DELete:ALL](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e69977.htm)

Deletes all traces in all channels.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:310](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L310)

---

<a id="method__rmtrace.2" class="lexicon_definition"></a>
#### rmtrace(ins::PainterQB.ZNB20Module.ZNB20,  ch::Int64) [¶](#method__rmtrace.2)
[CALCulate#:PARameter:DELete:CALL](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8d937272d97244fb.htm)

Deletes all traces in the given channel.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:301](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L301)

---

<a id="method__rmtrace.3" class="lexicon_definition"></a>
#### rmtrace(ins::PainterQB.ZNB20Module.ZNB20,  name::AbstractString,  ch::Int64) [¶](#method__rmtrace.3)
[CALCULATE#:PARAMETER:DELETE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/0763f74d0a2d4d61.htm)

Remove trace with name `name` from channel `ch`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:292](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L292)

---

<a id="method__showtrace.1" class="lexicon_definition"></a>
#### showtrace(ins::PainterQB.ZNB20Module.ZNB20,  name::AbstractString,  win::Int64,  wtrace::Int64) [¶](#method__showtrace.1)
[DISPLAY:WINDOW#:TRACE#:FEED](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/58dad852e7db48a0.htm)

Show a trace named `name` in window `win::Int` as
window trace number `wtrace::Int`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:321](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L321)

## Types [Exported]

---

<a id="type__autosweeptime.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.AutoSweepTime [¶](#type__autosweeptime.1)
Configure or inspect. Does the instrument choose the minimum sweep time?

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:62](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L62)

---

<a id="type__displayupdate.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.DisplayUpdate [¶](#type__displayupdate.1)
Configure or inspect. Display updates during measurement.

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:65](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L65)

---

<a id="type__sweeptime.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.SweepTime [¶](#type__sweeptime.1)
Configure or inspect. Adjust time it takes to complete a sweep (all partial measurements).

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:68](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L68)

---

<a id="type__window.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.Window [¶](#type__window.1)
`InstrumentProperty`: Window.

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:71](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L71)


## Methods [Internal]

---

<a id="method__configure.1" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints},  n::Int64) [¶](#method__configure.1)
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

Define measurement points per sweep. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:100](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L100)

---

<a id="method__configure.2" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints},  n::Int64,  ch::Int64) [¶](#method__configure.2)
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

Define measurement points per sweep. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:100](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L100)

---

<a id="method__configure.3" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime},  b::Bool) [¶](#method__configure.3)
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Determines whether or not the instrument chooses the minimum sweep time,
including all partial measurements. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:83](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L83)

---

<a id="method__configure.4" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime},  b::Bool,  ch::Int64) [¶](#method__configure.4)
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Determines whether or not the instrument chooses the minimum sweep time,
including all partial measurements. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:83](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L83)

---

<a id="method__configure.5" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.DisplayUpdate},  b::Bool) [¶](#method__configure.5)
[SYSTEM:DISPLAY:UPDATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e114067.htm)

Switches display update on / off.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:91](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L91)

---

<a id="method__configure.6" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime},  time::Real) [¶](#method__configure.6)
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:111](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L111)

---

<a id="method__configure.7" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime},  time::Real,  ch::Int64) [¶](#method__configure.7)
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:111](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L111)

---

<a id="method__configure.8" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Window},  b::Bool,  win::Int64) [¶](#method__configure.8)
[DISPLAY:WINDOW#:STATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/065c895d5a2c4230.htm)

Turn a window on or off.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:119](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L119)

---

<a id="method__generate_configure.1" class="lexicon_definition"></a>
#### generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}}) [¶](#method__generate_configure.1)
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, ::Type{PropertySubtype}, infixes...)
```


*source:*
[PainterQB\src\Metaprogramming.jl:82](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\Metaprogramming.jl#L82)

---

<a id="method__generate_configure.2" class="lexicon_definition"></a>
#### generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs}) [¶](#method__generate_configure.2)
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, ::Type{PropertySubtype}, infixes...)
```

This particular method will be deprecated soon.


*source:*
[PainterQB\src\Metaprogramming.jl:122](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\Metaprogramming.jl#L122)

---

<a id="method__generate_configure.3" class="lexicon_definition"></a>
#### generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...) [¶](#method__generate_configure.3)
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, Property, values..., infixes...)
```


*source:*
[PainterQB\src\Metaprogramming.jl:151](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\Metaprogramming.jl#L151)

---

<a id="method__generate_handlers.1" class="lexicon_definition"></a>
#### generate_handlers{T<:PainterQB.Instrument}(insType::Type{T<:PainterQB.Instrument},  responseDict::Dict{K, V}) [¶](#method__generate_handlers.1)
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


*source:*
[PainterQB\src\Metaprogramming.jl:218](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\Metaprogramming.jl#L218)

---

<a id="method__generate_inspect.1" class="lexicon_definition"></a>
#### generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs}) [¶](#method__generate_inspect.1)
This method does/returns nothing.

*source:*
[PainterQB\src\Metaprogramming.jl:14](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\Metaprogramming.jl#L14)

---

<a id="method__generate_inspect.2" class="lexicon_definition"></a>
#### generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...) [¶](#method__generate_inspect.2)
This method will
generate the following method in the module where `generate_inspect` is defined:

`inspect(ins::instype, ::Type{proptype}, infixes::Int...)`

The `infixes` variable argument allows for numbers to be inserted within the
commands, for instance in `OUTP#:FILT:FREQ`, where the `#` sign should be
replaced by an integer. The replacements are done in the order of the arguments.
Error checking is done on the number of arguments.

For a given property, `inspect` will return either an InstrumentProperty subtype,
a number, a boolean, or a string as appropriate.


*source:*
[PainterQB\src\Metaprogramming.jl:33](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\Metaprogramming.jl#L33)

---

<a id="method__generate_properties.1" class="lexicon_definition"></a>
#### generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}}) [¶](#method__generate_properties.1)
Creates and exports immutable singleton subtypes.

*source:*
[PainterQB\src\Metaprogramming.jl:183](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\Metaprogramming.jl#L183)

---

<a id="method__inspect.1" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints}) [¶](#method__inspect.1)
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

How many measurement points per sweep? Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:147](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L147)

---

<a id="method__inspect.2" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints},  ch::Int64) [¶](#method__inspect.2)
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

How many measurement points per sweep? Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:147](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L147)

---

<a id="method__inspect.3" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime}) [¶](#method__inspect.3)
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Does the instrument choose the minimum sweep time,
including all partial measurements? Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:130](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L130)

---

<a id="method__inspect.4" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime},  ch::Int64) [¶](#method__inspect.4)
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Does the instrument choose the minimum sweep time,
including all partial measurements? Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:130](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L130)

---

<a id="method__inspect.5" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.DisplayUpdate}) [¶](#method__inspect.5)
[SYSTEM:DISPLAY:UPDATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e114067.htm)

Is the display updating?


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:138](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L138)

---

<a id="method__inspect.6" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime}) [¶](#method__inspect.6)
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:158](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L158)

---

<a id="method__inspect.7" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime},  ch::Int64) [¶](#method__inspect.7)
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:158](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L158)

---

<a id="method__inspect.8" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Window},  win::Int64) [¶](#method__inspect.8)
Determines if a window exists, by window number. See `lswindow`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:163](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L163)

---

<a id="method__inspect.9" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Window},  wname::AbstractString) [¶](#method__inspect.9)
Determines if a window exists, by window name. See `lswindow`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:171](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L171)

---

<a id="method__lswindows.1" class="lexicon_definition"></a>
#### lswindows(ins::PainterQB.ZNB20Module.ZNB20) [¶](#method__lswindows.1)
[DISPLAY:CATALOG?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/abdd1db5dc0c48ee.htm)

Report the windows and their names in a tuple: (`arrNums::Array{Int64,1}`,
    `arrNames::Array{SubString{ASCIIString},1})`).


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:226](https://github.com/ajkeller34/PainterQB.jl/tree/abc51a4b7d5f8bbf1713ef04ad347ebc00105106/src\instruments\VNAs\ZNB20.jl#L226)

