# PainterQB.ZNB20Module


## Methods [Exported]

---

<a id="method__cd.1" class="lexicon_definition"></a>
#### cd(ins::PainterQB.ZNB20Module.ZNB20,  dir::AbstractString) [¶](#method__cd.1)
[MMEMory:CDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87010.htm)

Change directories. Pass "~" for default.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:399](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L399)

---

<a id="method__cp.1" class="lexicon_definition"></a>
#### cp(ins::PainterQB.ZNB20Module.ZNB20,  src::AbstractString,  dest::AbstractString) [¶](#method__cp.1)
[MMEMory:COPY](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87048.htm)

Copy a file.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:412](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L412)

---

<a id="method__hidetrace.1" class="lexicon_definition"></a>
#### hidetrace(ins::PainterQB.ZNB20Module.ZNB20,  win::Int64,  wtrace::Int64) [¶](#method__hidetrace.1)
[DISPLAY:WINDOW#:TRACE#:DELETE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/35e75331f5ce4fce.htm)

Releases the assignment of window trace `wtrace` to window `win`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:421](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L421)

---

<a id="method__lstrace.1" class="lexicon_definition"></a>
#### lstrace(ins::PainterQB.ZNB20Module.ZNB20,  ch::Int64) [¶](#method__lstrace.1)
[CALCULATE#:PARAMETER:CATALOG?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/2ce049f1af684d21.htm)

Report the traces assigned to a given channel.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:430](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L430)

---

<a id="method__mkdir.1" class="lexicon_definition"></a>
#### mkdir(ins::PainterQB.ZNB20Module.ZNB20,  dir::AbstractString) [¶](#method__mkdir.1)
[MMEMory:MDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e89416.htm)

Make a directory.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:455](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L455)

---

<a id="method__mktrace.1" class="lexicon_definition"></a>
#### mktrace(ins::PainterQB.ZNB20Module.ZNB20,  name::AbstractString,  parameter,  ch::Int64) [¶](#method__mktrace.1)
[CALCulate#:PARameter:SDEFine](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/e75d49e2a14541c5.htm)

Create a new trace with `name` and measurement `parameter` on channel `ch`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:464](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L464)

---

<a id="method__pwd.1" class="lexicon_definition"></a>
#### pwd(ins::PainterQB.ZNB20Module.ZNB20) [¶](#method__pwd.1)
[MMEMory:CDIRectory?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87010.htm)

Print the working directory.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:475](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L475)

---

<a id="method__readdir.1" class="lexicon_definition"></a>
#### readdir(ins::PainterQB.ZNB20Module.ZNB20) [¶](#method__readdir.1)
[MMEMory:CATalog?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/7f7650b75a604b3d.htm)

Read the directory contents.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:484](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L484)

---

<a id="method__readdir.2" class="lexicon_definition"></a>
#### readdir(ins::PainterQB.ZNB20Module.ZNB20,  dir::AbstractString) [¶](#method__readdir.2)
[MMEMory:CATalog?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/7f7650b75a604b3d.htm)

Read the directory contents.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:484](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L484)

---

<a id="method__rm.1" class="lexicon_definition"></a>
#### rm(ins::PainterQB.ZNB20Module.ZNB20,  file::AbstractString) [¶](#method__rm.1)
[MMEMory:DELete](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87202.htm)

Remove a file.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:497](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L497)

---

<a id="method__rmtrace.1" class="lexicon_definition"></a>
#### rmtrace(ins::PainterQB.ZNB20Module.ZNB20) [¶](#method__rmtrace.1)
[CALCulate:PARameter:DELete:ALL](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e69977.htm)

Deletes all traces in all channels.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:525](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L525)

---

<a id="method__rmtrace.2" class="lexicon_definition"></a>
#### rmtrace(ins::PainterQB.ZNB20Module.ZNB20,  ch::Int64) [¶](#method__rmtrace.2)
[CALCulate#:PARameter:DELete:CALL](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8d937272d97244fb.htm)

Deletes all traces in the given channel.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:516](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L516)

---

<a id="method__rmtrace.3" class="lexicon_definition"></a>
#### rmtrace(ins::PainterQB.ZNB20Module.ZNB20,  name::AbstractString,  ch::Int64) [¶](#method__rmtrace.3)
[CALCULATE#:PARAMETER:DELETE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/0763f74d0a2d4d61.htm)

Remove trace with name `name` from channel `ch`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:507](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L507)

---

<a id="method__showtrace.1" class="lexicon_definition"></a>
#### showtrace(ins::PainterQB.ZNB20Module.ZNB20,  name::AbstractString,  win::Int64,  wtrace::Int64) [¶](#method__showtrace.1)
[DISPLAY:WINDOW#:TRACE#:FEED](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/58dad852e7db48a0.htm)

Show a trace named `name` in window `win::Int` as
window trace number `wtrace::Int`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:536](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L536)

## Types [Exported]

---

<a id="type__activetrace.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.ActiveTrace [¶](#type__activetrace.1)
Configure or inspect. Active trace.

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:107](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L107)

---

<a id="type__autosweeptime.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.AutoSweepTime [¶](#type__autosweeptime.1)
Configure or inspect. Does the instrument choose the minimum sweep time?

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:110](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L110)

---

<a id="type__bandwidth.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.Bandwidth [¶](#type__bandwidth.1)
Configure or inspect. Measurement / resolution bandwidth. May be rounded.

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:113](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L113)

---

<a id="type__displayupdate.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.DisplayUpdate [¶](#type__displayupdate.1)
Configure or inspect. Display updates during measurement.

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:116](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L116)

---

<a id="type__sweeptime.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.SweepTime [¶](#type__sweeptime.1)
Configure or inspect. Adjust time it takes to complete a sweep (all partial measurements).

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:119](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L119)

---

<a id="type__window.1" class="lexicon_definition"></a>
#### PainterQB.ZNB20Module.Window [¶](#type__window.1)
`InstrumentProperty`: Window.

*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:122](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L122)


## Methods [Internal]

---

<a id="method__configure.1" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints},  n::Int64) [¶](#method__configure.1)
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

Define measurement points per sweep. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:179](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L179)

---

<a id="method__configure.2" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints},  n::Int64,  ch::Int64) [¶](#method__configure.2)
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

Define measurement points per sweep. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:179](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L179)

---

<a id="method__configure.3" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.ActiveTrace},  name::AbstractString) [¶](#method__configure.3)
[CALCULATE#:PARAMETER:SELECT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/3c03effa6de64ee5.htm)

Select an active trace. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:140](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L140)

---

<a id="method__configure.4" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.ActiveTrace},  name::AbstractString,  ch::Int64) [¶](#method__configure.4)
[CALCULATE#:PARAMETER:SELECT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/3c03effa6de64ee5.htm)

Select an active trace. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:140](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L140)

---

<a id="method__configure.5" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime},  b::Bool) [¶](#method__configure.5)
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Determines whether or not the instrument chooses the minimum sweep time,
including all partial measurements. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:151](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L151)

---

<a id="method__configure.6" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime},  b::Bool,  ch::Int64) [¶](#method__configure.6)
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Determines whether or not the instrument chooses the minimum sweep time,
including all partial measurements. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:151](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L151)

---

<a id="method__configure.7" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Bandwidth},  bw::Float64) [¶](#method__configure.7)
[SENSE#:BWIDTH:RESOLUTION](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/dd1fd694e0ce4dd8.htm)

Set the measurement bandwidth between 1 Hz and 1 MHz
(option ZNBT-K17 up to 10 MHz).
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:163](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L163)

---

<a id="method__configure.8" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Bandwidth},  bw::Float64,  ch::Int64) [¶](#method__configure.8)
[SENSE#:BWIDTH:RESOLUTION](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/dd1fd694e0ce4dd8.htm)

Set the measurement bandwidth between 1 Hz and 1 MHz
(option ZNBT-K17 up to 10 MHz).
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:163](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L163)

---

<a id="method__configure.9" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.DisplayUpdate},  b::Bool) [¶](#method__configure.9)
[SYSTEM:DISPLAY:UPDATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e114067.htm)

Switches display update on / off.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:170](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L170)

---

<a id="method__configure.10" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime},  time::Real) [¶](#method__configure.10)
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:199](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L199)

---

<a id="method__configure.11" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime},  time::Real,  ch::Int64) [¶](#method__configure.11)
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:199](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L199)

---

<a id="method__configure.12" class="lexicon_definition"></a>
#### configure(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Window},  b::Bool,  win::Int64) [¶](#method__configure.12)
[DISPLAY:WINDOW#:STATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/065c895d5a2c4230.htm)

Turn a window on or off.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:259](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L259)

---

<a id="method__configure.13" class="lexicon_definition"></a>
#### configure{T<:PainterQB.OscillatorSource}(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{T<:PainterQB.OscillatorSource}) [¶](#method__configure.13)
[SENSE1:ROSCILLATOR:SOURCE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4314a7accd124cd8.htm)

Select oscillator source: `InternalOscillator`, `ExternalOscillator`


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:188](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L188)

---

<a id="method__configure.14" class="lexicon_definition"></a>
#### configure{T<:PainterQB.TriggerSlope}(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{T<:PainterQB.TriggerSlope}) [¶](#method__configure.14)
[TRIGGER#:SEQUENCE:SLOPE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/cbc5449b57664ad3.htm)

Configure the trigger slope: `RisingTrigger`, `FallingTrigger`.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:229](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L229)

---

<a id="method__configure.15" class="lexicon_definition"></a>
#### configure{T<:PainterQB.TriggerSlope}(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{T<:PainterQB.TriggerSlope},  ch::Int64) [¶](#method__configure.15)
[TRIGGER#:SEQUENCE:SLOPE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/cbc5449b57664ad3.htm)

Configure the trigger slope: `RisingTrigger`, `FallingTrigger`.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:229](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L229)

---

<a id="method__configure.16" class="lexicon_definition"></a>
#### configure{T<:PainterQB.TriggerSource}(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{T<:PainterQB.TriggerSource}) [¶](#method__configure.16)
[TRIGger#:SEQuence:SOURce](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/9c62999c5a1642f2.htm)

Configure the trigger source: `InternalTrigger`, `ExternalTrigger`, `ManualTrigger`,
`MultipleTrigger`. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:239](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L239)

---

<a id="method__configure.17" class="lexicon_definition"></a>
#### configure{T<:PainterQB.TriggerSource}(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{T<:PainterQB.TriggerSource},  ch::Int64) [¶](#method__configure.17)
[TRIGger#:SEQuence:SOURce](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/9c62999c5a1642f2.htm)

Configure the trigger source: `InternalTrigger`, `ExternalTrigger`, `ManualTrigger`,
`MultipleTrigger`. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:239](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L239)

---

<a id="method__configure.18" class="lexicon_definition"></a>
#### configure{T<:PainterQB.VNAFormat}(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{T<:PainterQB.VNAFormat}) [¶](#method__configure.18)
[CALCULATE#:FORMAT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/132d40cd4d1d43c4.htm)

Configure the format of the active trace:
`LinearMagnitude`, `LogMagnitude`, `Phase`, `ExpandedPhase`, `PolarLinear`,
`Smith`, `SmithAdmittance`, `GroupDelay`, `RealPart`, `ImagPart`, `SWR`.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:253](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L253)

---

<a id="method__configure.19" class="lexicon_definition"></a>
#### configure{T<:PainterQB.VNAFormat}(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{T<:PainterQB.VNAFormat},  ch::Int64) [¶](#method__configure.19)
[CALCULATE#:FORMAT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/132d40cd4d1d43c4.htm)

Configure the format of the active trace:
`LinearMagnitude`, `LogMagnitude`, `Phase`, `ExpandedPhase`, `PolarLinear`,
`Smith`, `SmithAdmittance`, `GroupDelay`, `RealPart`, `ImagPart`, `SWR`.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:253](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L253)

---

<a id="method__configure.20" class="lexicon_definition"></a>
#### configure{T<:PainterQB.ZNB20Module.TransferByteOrder}(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{T<:PainterQB.ZNB20Module.TransferByteOrder}) [¶](#method__configure.20)
[FORMAT:BORDER](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e85486.htm)

Configure the transfer byte order: `LittleEndianTransfer`, `BigEndianTransfer`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:207](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L207)

---

<a id="method__configure.21" class="lexicon_definition"></a>
#### configure{T<:PainterQB.ZNB20Module.TransferFormat}(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{T<:PainterQB.ZNB20Module.TransferFormat}) [¶](#method__configure.21)
[FORMAT:DATA](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e85516.htm)

Configures the data transfer format:
`ASCIITransfer`, `Float32Transfer`, `Float64Transfer`.
For the latter two the byte order should also be considered.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:220](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L220)

---

<a id="method__generate_configure.1" class="lexicon_definition"></a>
#### generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}}) [¶](#method__generate_configure.1)
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, ::Type{PropertySubtype}, infixes...)
```


*source:*
[PainterQB\src\Metaprogramming.jl:82](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\Metaprogramming.jl#L82)

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
[PainterQB\src\Metaprogramming.jl:122](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\Metaprogramming.jl#L122)

---

<a id="method__generate_configure.3" class="lexicon_definition"></a>
#### generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...) [¶](#method__generate_configure.3)
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, Property, values..., infixes...)
```


*source:*
[PainterQB\src\Metaprogramming.jl:151](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\Metaprogramming.jl#L151)

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
[PainterQB\src\Metaprogramming.jl:218](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\Metaprogramming.jl#L218)

---

<a id="method__generate_inspect.1" class="lexicon_definition"></a>
#### generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs}) [¶](#method__generate_inspect.1)
This method does/returns nothing.

*source:*
[PainterQB\src\Metaprogramming.jl:14](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\Metaprogramming.jl#L14)

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
[PainterQB\src\Metaprogramming.jl:33](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\Metaprogramming.jl#L33)

---

<a id="method__generate_properties.1" class="lexicon_definition"></a>
#### generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}}) [¶](#method__generate_properties.1)
Creates and exports immutable singleton subtypes.

*source:*
[PainterQB\src\Metaprogramming.jl:183](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\Metaprogramming.jl#L183)

---

<a id="method__inspect.1" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints}) [¶](#method__inspect.1)
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

How many measurement points per sweep? Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:326](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L326)

---

<a id="method__inspect.2" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.NumPoints},  ch::Int64) [¶](#method__inspect.2)
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

How many measurement points per sweep? Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:326](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L326)

---

<a id="method__inspect.3" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.OscillatorSource}) [¶](#method__inspect.3)
[SENSE1:ROSCILLATOR:SOURCE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4314a7accd124cd8.htm)

Inspect oscillator source: `InternalOscillator`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:335](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L335)

---

<a id="method__inspect.4" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.TriggerSlope}) [¶](#method__inspect.4)
[TRIGGER#:SEQUENCE:SLOPE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/cbc5449b57664ad3.htm)

Inspect the trigger slope. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:354](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L354)

---

<a id="method__inspect.5" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.TriggerSlope},  ch::Int64) [¶](#method__inspect.5)
[TRIGGER#:SEQUENCE:SLOPE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/cbc5449b57664ad3.htm)

Inspect the trigger slope. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:354](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L354)

---

<a id="method__inspect.6" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.TriggerSource}) [¶](#method__inspect.6)
[TRIGger#:SEQuence:SOURce](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/ZNB_ZNBT_WebHelp_en.htm)

Inspect the trigger source. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:363](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L363)

---

<a id="method__inspect.7" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.TriggerSource},  ch::Int64) [¶](#method__inspect.7)
[TRIGger#:SEQuence:SOURce](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/ZNB_ZNBT_WebHelp_en.htm)

Inspect the trigger source. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:363](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L363)

---

<a id="method__inspect.8" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.VNAFormat}) [¶](#method__inspect.8)
[CALCULATE#:FORMAT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/132d40cd4d1d43c4.htm)

Inspect the format of the active trace. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:372](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L372)

---

<a id="method__inspect.9" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.VNAFormat},  ch::Int64) [¶](#method__inspect.9)
[CALCULATE#:FORMAT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/132d40cd4d1d43c4.htm)

Inspect the format of the active trace. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:372](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L372)

---

<a id="method__inspect.10" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.ActiveTrace}) [¶](#method__inspect.10)
[CALCULATE#:PARAMETER:SELECT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/3c03effa6de64ee5.htm)

Query an active trace. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:270](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L270)

---

<a id="method__inspect.11" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.ActiveTrace},  ch::Int64) [¶](#method__inspect.11)
[CALCULATE#:PARAMETER:SELECT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/3c03effa6de64ee5.htm)

Query an active trace. Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:270](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L270)

---

<a id="method__inspect.12" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime}) [¶](#method__inspect.12)
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Does the instrument choose the minimum sweep time,
including all partial measurements? Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:281](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L281)

---

<a id="method__inspect.13" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.AutoSweepTime},  ch::Int64) [¶](#method__inspect.13)
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Does the instrument choose the minimum sweep time,
including all partial measurements? Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:281](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L281)

---

<a id="method__inspect.14" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Bandwidth}) [¶](#method__inspect.14)
[SENSE#:BWIDTH:RESOLUTION](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/dd1fd694e0ce4dd8.htm)

Inspect the measurement bandwidth.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:291](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L291)

---

<a id="method__inspect.15" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Bandwidth},  ch::Int64) [¶](#method__inspect.15)
[SENSE#:BWIDTH:RESOLUTION](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/dd1fd694e0ce4dd8.htm)

Inspect the measurement bandwidth.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:291](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L291)

---

<a id="method__inspect.16" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime}) [¶](#method__inspect.16)
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:346](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L346)

---

<a id="method__inspect.17" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.SweepTime},  ch::Int64) [¶](#method__inspect.17)
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:346](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L346)

---

<a id="method__inspect.18" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.TransferByteOrder}) [¶](#method__inspect.18)
[FORMAT:BORDER](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e85486.htm)

Configure the transfer byte order: `LittleEndianTransfer`, `BigEndianTransfer`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:299](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L299)

---

<a id="method__inspect.19" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.TransferFormat}) [¶](#method__inspect.19)
[FORMAT:DATA](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e85516.htm)

Inspect the data transfer format. The byte order should also be considered.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:308](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L308)

---

<a id="method__inspect.20" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Window},  win::Int64) [¶](#method__inspect.20)
Determines if a window exists, by window number. See `lswindow`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:378](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L378)

---

<a id="method__inspect.21" class="lexicon_definition"></a>
#### inspect(ins::PainterQB.ZNB20Module.ZNB20,  ::Type{PainterQB.ZNB20Module.Window},  wname::AbstractString) [¶](#method__inspect.21)
Determines if a window exists, by window name. See `lswindow`.


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:386](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L386)

---

<a id="method__lswindows.1" class="lexicon_definition"></a>
#### lswindows(ins::PainterQB.ZNB20Module.ZNB20) [¶](#method__lswindows.1)
[DISPLAY:CATALOG?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/abdd1db5dc0c48ee.htm)

Report the windows and their names in a tuple: (`arrNums::Array{Int64,1}`,
    `arrNames::Array{SubString{ASCIIString},1})`).


*source:*
[PainterQB\src\instruments\VNAs\ZNB20.jl:441](https://github.com/ajkeller34/PainterQB.jl/tree/6ad6dc59e005ae7fd2f7b1b39403f3466e50ae22/src\instruments\VNAs\ZNB20.jl#L441)

