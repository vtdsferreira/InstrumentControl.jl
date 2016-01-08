# PainterQB.AlazarModule


## Functions [Exported]

---

<a id="function__abort.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.abort [¶](#function__abort.1)
Aborts an acquisition. Must be called in the case of a DSP acquisition; somehow
less fatal otherwise. Should be automatically taken care of in a well-written
`measure` method, but can be called manually by the paranoid.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:44](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L44)

---

<a id="function__before_async_read.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.before_async_read [¶](#function__before_async_read.1)
Performs setup for asynchronous acquisitions. Should be called after
`buffersizing` has been called.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:114](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L114)

---

<a id="function__bufferarray.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.bufferarray [¶](#function__bufferarray.1)
Given and `InstrumentAlazar` and `AlazarMode`, returns a `DMABufferArray`
with the correct number of buffers and buffer sizes. `buffersizing` should have
been called before this function.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:164](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L164)

---

<a id="function__buffersizing.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.buffersizing [¶](#function__buffersizing.1)
Given an `InstrumentAlazar` and an `AlazarMode`, this will tweak parameters
in the `AlazarMode` object to comply with record alignment and buffer granularity
requirements imposed by either the AlazarTech digitizer itself, or the implementation
of measurement code. Should be called toward the very beginning of a `measure`
method.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:387](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L387)

---

<a id="function__dsp_generatewindowfunction.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.dsp_generatewindowfunction [¶](#function__dsp_generatewindowfunction.1)
Given a `DSPWindow`, `Re` or `Im` type, and `FFTRecordMode`, this will prepare
a window function to be set later by calling `windowing`.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:445](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L445)

---

<a id="function__recordsizing.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.recordsizing [¶](#function__recordsizing.1)
Calls C function `AlazarSetRecordSize` if necessary, given an `InstrumentAlazar`
and `AlazarMode`.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:625](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L625)

---

<a id="function__wait_buffer.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.wait_buffer [¶](#function__wait_buffer.1)
Waits for a buffer to be processed (or a timeout to elapse).

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:789](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L789)

---

<a id="function__windowing.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.windowing [¶](#function__windowing.1)
Set up DSP windowing if necessary, given an `InstrumentAlazar` and `AlazarMode`.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:806](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L806)

## Methods [Exported]

---

<a id="method__busy.1" class="lexicon_definition"></a>
#### busy(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__busy.1)
Returns whether or not the `InstrumentAlazar` is busy (Bool).

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:396](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L396)

---

<a id="method__configure.1" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.SampleRate},  rate::Real) [¶](#method__configure.1)
Configure the sample rate to any multiple of 1 MHz (within 300 MHz and 1.8 GHz)
using the external clock.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:145](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L145)

---

<a id="method__configure.2" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AuxSoftwareTriggerEnable},  b::Bool) [¶](#method__configure.2)
If an AUX IO output mode has been configured, then this will configure
software trigger enable. From the Alazar API:

When this flag is set, the board will wait for software to call
`AlazarForceTriggerEnable` to generate a trigger enable event; then wait for
sufficient trigger events to capture the records in an AutoDMA buffer; then wait
for the next trigger enable event and repeat.


*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:81](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L81)

---

<a id="method__configure.3" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.LED},  ledState::Bool) [¶](#method__configure.3)
Configures the LED on the digitizer card chassis.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:202](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L202)

---

<a id="method__configure.4" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.RecordCount},  count) [¶](#method__configure.4)
Wrapper for C function `AlazarSetRecordCount`. See the Alazar API.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:104](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L104)

---

<a id="method__configure.5" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.Sleep},  sleepState) [¶](#method__configure.5)
Configures the sleep state of the digitizer card.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:208](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L208)

---

<a id="method__configure.6" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.TriggerDelaySamples},  delay_samples) [¶](#method__configure.6)
Configure how many samples to wait after receiving a trigger event before capturing
a record.


*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:294](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L294)

---

<a id="method__configure.7" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.TriggerTimeoutS},  timeout_s) [¶](#method__configure.7)
Wrapper for C function `AlazarSetTriggerTimeOut`, except we take seconds here
instead of ticks (units of 10 us).


*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:313](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L313)

---

<a id="method__configure.8" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.TriggerTimeoutTicks},  ticks) [¶](#method__configure.8)
Wrapper for C function `AlazarSetTriggerTimeOut`.


*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:303](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L303)

---

<a id="method__configure.9" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.TriggerLevel},  levelJ,  levelK) [¶](#method__configure.9)
Configure the trigger level for trigger engine J and K. This should be an
unsigned 8 bit integer (0--255) corresponding to the full range of the digitizer.


*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:269](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L269)

---

<a id="method__configure.10" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxDigitalInput}) [¶](#method__configure.10)
Configure a digitizer's AUX IO to act as a digital input.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:25](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L25)

---

<a id="method__configure.11" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxDigitalOutput},  level::Integer) [¶](#method__configure.11)
Configure a digitizer's AUX IO port to act as a general purpose digital output.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:62](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L62)

---

<a id="method__configure.12" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxOutputPacer},  divider::Integer) [¶](#method__configure.12)
Configure a digitizer's AUX IO port to output the sample clock, divided by an integer.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:49](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L49)

---

<a id="method__configure.13" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxOutputTrigger}) [¶](#method__configure.13)
Configure a digitizer's AUX IO to output a trigger signal synced to the sample clock.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:15](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L15)

---

<a id="method__configure.14" class="lexicon_definition"></a>
#### configure(a::PainterQB.AlazarModule.InstrumentAlazar,  ch::Type{PainterQB.AlazarModule.BothChannels}) [¶](#method__configure.14)
Configures acquisition from both channels, simultaneously.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:122](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L122)

---

<a id="method__configure.15" class="lexicon_definition"></a>
#### configure{S<:PainterQB.AlazarModule.AlazarDataPacking}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  pack::Type{S<:PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{PainterQB.AlazarModule.BothChannels}) [¶](#method__configure.15)
Configures the data packing mode for both channels.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:191](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L191)

---

<a id="method__configure.16" class="lexicon_definition"></a>
#### configure{S<:PainterQB.AlazarModule.AlazarDataPacking}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  pack::Type{S<:PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{PainterQB.AlazarModule.ChannelA}) [¶](#method__configure.16)
Configures the data packing mode for channel A.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:163](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L163)

---

<a id="method__configure.17" class="lexicon_definition"></a>
#### configure{S<:PainterQB.AlazarModule.AlazarDataPacking}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  pack::Type{S<:PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{PainterQB.AlazarModule.ChannelB}) [¶](#method__configure.17)
Configures the data packing mode for channel B.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:177](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L177)

---

<a id="method__configure.18" class="lexicon_definition"></a>
#### configure{S<:PainterQB.AlazarModule.DSPWindow, T<:PainterQB.AlazarModule.DSPWindow}(a::PainterQB.AlazarModule.AlazarATS9360,  re::Type{S<:PainterQB.AlazarModule.DSPWindow},  im::Type{T<:PainterQB.AlazarModule.DSPWindow}) [¶](#method__configure.18)
Configures the DSP windows. `AlazarFFTSetWindowFunction` is called towards
the start of `measure` rather than here.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:180](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L180)

---

<a id="method__configure.19" class="lexicon_definition"></a>
#### configure{S<:PainterQB.TriggerSlope, T<:PainterQB.TriggerSlope}(a::PainterQB.AlazarModule.InstrumentAlazar,  slopeJ::Type{S<:PainterQB.TriggerSlope},  slopeK::Type{T<:PainterQB.TriggerSlope}) [¶](#method__configure.19)
Configures whether to trigger on a rising or falling slope, for engine J and K.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:240](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L240)

---

<a id="method__configure.20" class="lexicon_definition"></a>
#### configure{S<:PainterQB.TriggerSource, T<:PainterQB.TriggerSource}(a::PainterQB.AlazarModule.InstrumentAlazar,  sourceJ::Type{S<:PainterQB.TriggerSource},  sourceK::Type{T<:PainterQB.TriggerSource}) [¶](#method__configure.20)
Configure the trigger source for trigger engine J and K.


*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:254](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L254)

---

<a id="method__configure.21" class="lexicon_definition"></a>
#### configure{T<:PainterQB.AlazarModule.AlazarChannel}(a::PainterQB.AlazarModule.InstrumentAlazar,  ch::Type{T<:PainterQB.AlazarModule.AlazarChannel}) [¶](#method__configure.21)
Configures the acquisition channel.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:114](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L114)

---

<a id="method__configure.22" class="lexicon_definition"></a>
#### configure{T<:PainterQB.AlazarModule.AlazarTimestampReset}(a::PainterQB.AlazarModule.InstrumentAlazar,  t::Type{T<:PainterQB.AlazarModule.AlazarTimestampReset}) [¶](#method__configure.22)
Configures timestamp reset. From the Alazar API, the choices are
`TimestampResetOnce`
(Reset the timestamp counter to zero on the next call to `AlazarStartCapture`,
but not thereafter.) or `TimestampResetAlways` (Reset the timestamp counter to
zero on each call to AlazarStartCapture. This is the default operation.)


*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:221](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L221)

---

<a id="method__configure.23" class="lexicon_definition"></a>
#### configure{T<:PainterQB.AlazarModule.AlazarTriggerEngine}(a::PainterQB.AlazarModule.InstrumentAlazar,  engine::Type{T<:PainterQB.AlazarModule.AlazarTriggerEngine}) [¶](#method__configure.23)
Configures the trigger engines, e.g. TriggerOnJ, TriggerOnJAndNotK, etc.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:231](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L231)

---

<a id="method__configure.24" class="lexicon_definition"></a>
#### configure{T<:PainterQB.AlazarModule.AlazarTriggerRange}(a::PainterQB.AlazarModule.AlazarATS9360,  range::Type{T<:PainterQB.AlazarModule.AlazarTriggerRange}) [¶](#method__configure.24)
Does nothing but display info telling you that this parameter cannot be changed
from 5V range on the ATS9360.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:172](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L172)

---

<a id="method__configure.25" class="lexicon_definition"></a>
#### configure{T<:PainterQB.AlazarModule.AlazarTriggerRange}(a::PainterQB.AlazarModule.InstrumentAlazar,  range::Type{T<:PainterQB.AlazarModule.AlazarTriggerRange}) [¶](#method__configure.25)
Configure the external trigger range.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:284](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L284)

---

<a id="method__configure.26" class="lexicon_definition"></a>
#### configure{T<:PainterQB.ClockSlope}(a::PainterQB.AlazarModule.InstrumentAlazar,  slope::Type{T<:PainterQB.ClockSlope}) [¶](#method__configure.26)
Configures whether the clock ticks on a rising or falling slope.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:146](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L146)

---

<a id="method__configure.27" class="lexicon_definition"></a>
#### configure{T<:PainterQB.Coupling}(a::PainterQB.AlazarModule.AlazarATS9360,  coupling::Type{T<:PainterQB.Coupling}) [¶](#method__configure.27)
Does nothing but display info telling you that this parameter cannot be changed
from DC coupling on the ATS9360.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:164](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L164)

---

<a id="method__configure.28" class="lexicon_definition"></a>
#### configure{T<:PainterQB.Coupling}(a::PainterQB.AlazarModule.InstrumentAlazar,  coupling::Type{T<:PainterQB.Coupling}) [¶](#method__configure.28)
Configure the external trigger coupling.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:277](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L277)

---

<a id="method__configure.29" class="lexicon_definition"></a>
#### configure{T<:PainterQB.SampleRate}(a::PainterQB.AlazarModule.InstrumentAlazar,  rate::Type{T<:PainterQB.SampleRate}) [¶](#method__configure.29)
Configures one of the preset sample rates derived from the internal clock.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:131](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L131)

---

<a id="method__configure.30" class="lexicon_definition"></a>
#### configure{T<:PainterQB.TriggerSlope}(a::PainterQB.AlazarModule.InstrumentAlazar,  aux::Type{PainterQB.AlazarModule.AuxInputTriggerEnable},  trigSlope::Type{T<:PainterQB.TriggerSlope}) [¶](#method__configure.30)
Configure a digitizer's AUX IO port to use the edge of a pulse as an AutoDMA
trigger signal.


*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:37](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L37)

---

<a id="method__dsp_getinfo.1" class="lexicon_definition"></a>
#### dsp_getinfo(dspModule::PainterQB.AlazarModule.DSPModule) [¶](#method__dsp_getinfo.1)
Returns a DSPModuleInfo object that describes a DSPModule.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:449](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L449)

---

<a id="method__dsp_getmodulehandles.1" class="lexicon_definition"></a>
#### dsp_getmodulehandles(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__dsp_getmodulehandles.1)
Returns an Array of `dsp_module_handle`.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:473](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L473)

---

<a id="method__dsp_modules.1" class="lexicon_definition"></a>
#### dsp_modules(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__dsp_modules.1)
Returns an array of `DSPModule`.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:490](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L490)

---

<a id="method__dsp_num_modules.1" class="lexicon_definition"></a>
#### dsp_num_modules(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__dsp_num_modules.1)
Returns the number of `DSPModule`.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:495](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L495)

---

<a id="method__fft_setup.1" class="lexicon_definition"></a>
#### fft_setup(a::PainterQB.AlazarModule.InstrumentAlazar,  m::PainterQB.AlazarModule.FFTRecordMode) [¶](#method__fft_setup.1)
Performs `AlazarFFTSetup`, which should be called before `AlazarBeforeAsyncRead`.
In our code, this method is called by `before_async_read` and does not need to
be called.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:510](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L510)

---

<a id="method__fft_setwindowfunction.1" class="lexicon_definition"></a>
#### fft_setwindowfunction(dspModule::PainterQB.AlazarModule.DSPModule,  samplesPerRecord,  reArray,  imArray) [¶](#method__fft_setwindowfunction.1)
A wrapper for the C function `AlazarFFTSetWindowFunction`, but taking a
`DSPModule` instead of a `dsp_module_handle`. Includes error handling.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:536](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L536)

---

<a id="method__forcetrigger.1" class="lexicon_definition"></a>
#### forcetrigger(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__forcetrigger.1)
Force a software trigger.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:557](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L557)

---

<a id="method__forcetriggerenable.1" class="lexicon_definition"></a>
#### forcetriggerenable(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__forcetriggerenable.1)
Force a software "trigger enable." This involves the AUX I/O connector (see
Alazar API).


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:566](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L566)

---

<a id="method__inputcontrol.1" class="lexicon_definition"></a>
#### inputcontrol(a::PainterQB.AlazarModule.InstrumentAlazar,  channel,  coupling,  inputRange,  impedance) [¶](#method__inputcontrol.1)
Controls coupling, input range, and impedance for applicable digitizer cards.
Does nothing for ATS9360 cards since there is only one choice of arguments.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:575](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L575)

---

<a id="method__inspect.1" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.BufferAlignment}) [¶](#method__inspect.1)
Returns the buffer alignment requirement (samples / record / channel).
Note that buffers must also be page-aligned.
From Table 8 of the Alazar API.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:220](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L220)

---

<a id="method__inspect.2" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.MaxBufferBytes}) [¶](#method__inspect.2)
Maximum number of bytes for a given DMA buffer.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:202](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L202)

---

<a id="method__inspect.3" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.MaxFFTSamples}) [¶](#method__inspect.3)
Maximum number of samples in an FPGA-based FFT. Can be obtained from `dsp_getinfo`
but we have hardcoded since it should not change for this model of digitizer.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:213](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L213)

---

<a id="method__inspect.4" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.MinFFTSamples}) [¶](#method__inspect.4)
Minimum number of samples in an FPGA-based FFT. Set by the minimum record size.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:207](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L207)

---

<a id="method__inspect.5" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.MinSamplesPerRecord}) [¶](#method__inspect.5)
Minimum samples per record. Observed behavior deviates from Table 8 of the
Alazar API.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:196](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L196)

---

<a id="method__inspect.6" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.AlazarATS9360,  ::Type{PainterQB.AlazarModule.PretriggerAlignment}) [¶](#method__inspect.6)
Returns the pretrigger alignment requirement (samples / record / channel).
From Table 8 of the Alazar API.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:227](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L227)

---

<a id="method__inspect.7" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarAux}) [¶](#method__inspect.7)
Inspect the AUX IO mode.

*source:*
[PainterQB\src\instruments\Alazar\Inspect.jl:6](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Inspect.jl#L6)

---

<a id="method__inspect.8" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarChannel}) [¶](#method__inspect.8)
Returns which channel(s) will be acquired.

*source:*
[PainterQB\src\instruments\Alazar\Inspect.jl:13](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Inspect.jl#L13)

---

<a id="method__inspect.9" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.ChannelCount}) [¶](#method__inspect.9)
Returns the number of channels to acquire.

*source:*
[PainterQB\src\instruments\Alazar\Inspect.jl:17](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Inspect.jl#L17)

---

<a id="method__inspect.10" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.SampleMemoryPerChannel}) [¶](#method__inspect.10)
Returns the memory per channel in units of samples.

*source:*
[PainterQB\src\instruments\Alazar\Inspect.jl:41](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Inspect.jl#L41)

---

<a id="method__inspect.11" class="lexicon_definition"></a>
#### inspect(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.SampleRate}) [¶](#method__inspect.11)
Inspect the sample rate. As currently programmed, does not distinguish
between the internal preset clock rates and otherwise.

*source:*
[PainterQB\src\instruments\Alazar\Inspect.jl:35](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Inspect.jl#L35)

---

<a id="method__inspect.12" class="lexicon_definition"></a>
#### inspect{T<:PainterQB.AlazarModule.AlazarChannel}(a::PainterQB.AlazarModule.InstrumentAlazar,  ::Type{PainterQB.AlazarModule.AlazarDataPacking},  ch::Type{T<:PainterQB.AlazarModule.AlazarChannel}) [¶](#method__inspect.12)
Inspect the data packing mode for a given channel.

*source:*
[PainterQB\src\instruments\Alazar\Inspect.jl:22](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Inspect.jl#L22)

---

<a id="method__measure.1" class="lexicon_definition"></a>
#### measure(ch::PainterQB.AlazarModule.AlazarResponse{T}) [¶](#method__measure.1)
Largely generic method for measuring `AlazarResponse`. Can be considered a
prototype for more complicated user-defined methods.

*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:279](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L279)

---

<a id="method__post_async_buffer.1" class="lexicon_definition"></a>
#### post_async_buffer(a::PainterQB.AlazarModule.InstrumentAlazar,  buffer,  bufferLength) [¶](#method__post_async_buffer.1)
Post an asynchronous buffer to the digitizer for use in an acquisition.
Buffer address must meet alignment requirements.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:594](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L594)

---

<a id="method__set_parameter.1" class="lexicon_definition"></a>
#### set_parameter(a::PainterQB.AlazarModule.InstrumentAlazar,  channelId,  parameterId,  value) [¶](#method__set_parameter.1)
Julia wrapper for C function AlazarSetParameter, with error checking.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:712](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L712)

---

<a id="method__set_parameter_ul.1" class="lexicon_definition"></a>
#### set_parameter_ul(a::PainterQB.AlazarModule.InstrumentAlazar,  channelId,  parameterId,  value) [¶](#method__set_parameter_ul.1)
Julia wrapper for C function AlazarSetParameterUL, with error checking.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:718](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L718)

---

<a id="method__set_triggeroperation.1" class="lexicon_definition"></a>
#### set_triggeroperation(a::PainterQB.AlazarModule.InstrumentAlazar,  args...) [¶](#method__set_triggeroperation.1)
Configure the trigger operation. Usually not called directly.
Args should be, in the following order:

a::InstrumentAlazar

engine:  one of the trigger engine operation IDs in the Alazar API.

source1: one of `TRIG_CHAN_A`, `TRIG_CHAN_B`, or `TRIG_DISABLE`

slope1:  `TRIGGER_SLOPE_POSITIVE` or `TRIGGER_SLOPE_NEGATIVE`

level1:  a voltage (V).

source2: one of `TRIG_CHAN_A`, `TRIG_CHAN_B`, or `TRIG_DISABLE`

slope2:  `TRIGGER_SLOPE_POSITIVE` or `TRIGGER_SLOPE_NEGATIVE`

level2:  a voltage (V).


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:743](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L743)

---

<a id="method__startcapture.1" class="lexicon_definition"></a>
#### startcapture(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__startcapture.1)
Should be called after `before_async_read` has been called and buffers are posted.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:770](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L770)

---

<a id="method__triggered.1" class="lexicon_definition"></a>
#### triggered(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__triggered.1)
Reports whether or not the digitizer has been triggered.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:776](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L776)

## Types [Exported]

---

<a id="type__alazarats9360.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.AlazarATS9360 [¶](#type__alazarats9360.1)
Concrete InstrumentAlazar subtype representing an ATS9360 digitizer.

Defaults are selected as:

- DC coupling (all). Cannot be changed for the ATS9360.
- Input range +/- 0.4V for channel A, B. Cannot be changed for the ATS9360.
- External trigger range: 5 V. Cannot be changed for the ATS9360 (?)
- All impedances 50 Ohm. Cannot be changed for the ATS9360.
- Internal clock, 1 GSps, rising edge.
- Trigger on J; engine J fires when channel A crosses zero from below.
- Trigger delay 0 samples; no trigger timeout
- Acquire with both channels
- AUX IO outputs a trigger signal synced to the sample clock.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:18](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L18)

---

<a id="type__alazarwindow.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.AlazarWindow [¶](#type__alazarwindow.1)
Abstract type representing a windowing function for DSP, built into the
AlazarDSP API. Subtype of `DSPWindow`.


*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:25](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L25)

---

<a id="type__continuousstreamresponse.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.ContinuousStreamResponse{T} [¶](#type__continuousstreamresponse.1)
Response type implementing the "continuous streaming mode" of the Alazar API.


*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:26](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L26)

---

<a id="type__dspmodule.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.DSPModule [¶](#type__dspmodule.1)
Represents a DSP module of an AlazarTech digitizer.

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:52](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L52)

---

<a id="type__dspmoduleinfo.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.DSPModuleInfo [¶](#type__dspmoduleinfo.1)
Encapsulates DSP module information: type, version, and max record length.

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:58](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L58)

---

<a id="type__dspwindow.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.DSPWindow [¶](#type__dspwindow.1)
Abstract type representing a windowing function for DSP.

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:19](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L19)

---

<a id="type__ffthardwareresponse.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.FFTHardwareResponse{T} [¶](#type__ffthardwareresponse.1)
Response type implementing the FPGA-based "FFT record mode" of the Alazar API.


*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:88](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L88)

---

<a id="type__fftsoftwareresponse.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.FFTSoftwareResponse{T} [¶](#type__fftsoftwareresponse.1)
Response type for measuring with NPT record mode, then using Julia's FFTW to
return the FFT. Slower than doing it with the FPGA, but ultimately necessary if
we want to use both channels as inputs to the FFT.


*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:117](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L117)

---

<a id="type__instrumentalazar.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.InstrumentAlazar [¶](#type__instrumentalazar.1)
Abstract type representing an AlazarTech digitizer.


*source:*
[PainterQB\src\instruments\Alazar\Alazar.jl:31](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Alazar.jl#L31)

---

<a id="type__nptrecordresponse.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.NPTRecordResponse{T} [¶](#type__nptrecordresponse.1)
Response type implementing the "NPT record mode" of the Alazar API.


*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:66](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L66)

---

<a id="type__triggeredstreamresponse.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.TriggeredStreamResponse{T} [¶](#type__triggeredstreamresponse.1)
Response type implementing the "triggered streaming mode" of the Alazar API.


*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:46](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L46)

---

<a id="type__windowbartlett.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.WindowBartlett [¶](#type__windowbartlett.1)
Bartlett window.

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:43](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L43)

---

<a id="type__windowblackman.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.WindowBlackman [¶](#type__windowblackman.1)
Blackman window.

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:37](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L37)

---

<a id="type__windowblackmanharris.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.WindowBlackmanHarris [¶](#type__windowblackmanharris.1)
Blackman-Harris window.

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:40](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L40)

---

<a id="type__windowhamming.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.WindowHamming [¶](#type__windowhamming.1)
Hamming window.

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:34](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L34)

---

<a id="type__windowhanning.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.WindowHanning [¶](#type__windowhanning.1)
Hanning window.

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:31](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L31)

---

<a id="type__windownone.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.WindowNone [¶](#type__windownone.1)
Flat window (ones).

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:28](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L28)

---

<a id="type__windowzeroes.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.WindowZeroes [¶](#type__windowzeroes.1)
Flat window (zeroes!).

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:49](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L49)

## Typealiass [Exported]

---

<a id="typealias__windowones.1" class="lexicon_definition"></a>
#### WindowOnes [¶](#typealias__windowones.1)
Type alias for `WindowNone`.

*source:*
[PainterQB\src\instruments\Alazar\DSPTypes.jl:46](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\DSPTypes.jl#L46)

## Globals [Exported]

---

<a id="global__inf_records.1" class="lexicon_definition"></a>
#### inf_records [¶](#global__inf_records.1)
Alazar API representation of an infinite number of records.

*source:*
[PainterQB\src\instruments\Alazar\Alazar.jl:27](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Alazar.jl#L27)


## Functions [Internal]

---

<a id="function__adma.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.adma [¶](#function__adma.1)
Returns the asynchronous DMA flags for a given `AlazarMode`. These are
passed as the final parameter to the C function `AlazarBeforeAsyncRead`.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:68](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L68)

---

<a id="function__dsp.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.dsp [¶](#function__dsp.1)
Given a DSPWindow type, this returns the constant needed to use the AlazarDSP
API to generate a particular window function.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:415](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L415)

---

<a id="function__initmodes.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.initmodes [¶](#function__initmodes.1)
Should be called at the beginning of a measure method to initialize the
AlazarMode objects.


*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:183](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L183)

---

<a id="function__postprocess.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.postprocess [¶](#function__postprocess.1)
Arrange for reinterpretation or conversion of the data stored in the
DMABuffers (backed by SharedArrays) to the desired return type. 


*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:436](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L436)

---

<a id="function__pretriggersamples.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.pretriggersamples [¶](#function__pretriggersamples.1)
Given an `AlazarMode`, returns the number of pre-trigger samples.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:605](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L605)

---

<a id="function__processing.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.processing [¶](#function__processing.1)
Specifies what to do with the buffers during measurement based on the response type.


*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:378](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L378)

---

<a id="function__rec_acq_param.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.rec_acq_param [¶](#function__rec_acq_param.1)
Returns the value to pass as the recordsPerAcquisition parameter in the C
function `AlazarBeforeAsyncRead`, given an `AlazarMode` object.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:634](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L634)

---

<a id="function__records_per_acquisition.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.records_per_acquisition [¶](#function__records_per_acquisition.1)
Given an `InstrumentAlazar` and `AlazarMode`, return the records per acquisition.
For `StreamMode` this will return the number of buffers per acquisition.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:646](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L646)

---

<a id="function__records_per_buffer.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.records_per_buffer [¶](#function__records_per_buffer.1)
Given an `InstrumentAlazar` and `AlazarMode`, return the records per buffer.
For `StreamMode` this will return 1.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:659](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L659)

---

<a id="function__samples_per_buffer_measured.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.samples_per_buffer_measured [¶](#function__samples_per_buffer_measured.1)
Given an `InstrumentAlazar` and `AlazarMode`, return the samples per buffer
measured by the digitizer.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:669](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L669)

---

<a id="function__samples_per_buffer_returned.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.samples_per_buffer_returned [¶](#function__samples_per_buffer_returned.1)
Given an `InstrumentAlazar` and `AlazarMode`, return the samples per buffer
returned by the digitizer.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:679](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L679)

---

<a id="function__samples_per_record_measured.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.samples_per_record_measured [¶](#function__samples_per_record_measured.1)
Given an `InstrumentAlazar` and `AlazarMode`, return the samples per record
measured by the digitizer.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:693](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L693)

---

<a id="function__samples_per_record_returned.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.samples_per_record_returned [¶](#function__samples_per_record_returned.1)
Given an `InstrumentAlazar` and `AlazarMode`, return the samples per record
returned by the digitizer.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:709](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L709)

## Methods [Internal]

---

<a id="method__auxmode.1" class="lexicon_definition"></a>
#### auxmode(m::UInt32,  b::Bool) [¶](#method__auxmode.1)
Masks an AUX IO mode parameter to specify AUX IO software trigger enable.

*source:*
[PainterQB\src\instruments\Alazar\Configure.jl:6](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Configure.jl#L6)

---

<a id="method__bits_per_sample.1" class="lexicon_definition"></a>
#### bits_per_sample(a::PainterQB.AlazarModule.AlazarATS9360) [¶](#method__bits_per_sample.1)
Hard coded to return 0x0c. May need to change if we want to play with data packing.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:234](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L234)

---

<a id="method__bits_per_sample.2" class="lexicon_definition"></a>
#### bits_per_sample(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__bits_per_sample.2)
Returns the number of bits per sample. Queries the digitizer directly via
the C function `AlazarGetChannelInfo`.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:120](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L120)

---

<a id="method__boardhandle.1" class="lexicon_definition"></a>
#### boardhandle(sysid::Integer,  boardid::Integer) [¶](#method__boardhandle.1)
Return a handle to an Alazar digitizer given a system ID and board ID.
For single digitizer systems, pass 1 for both to get a handle for the digitizer.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:136](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L136)

---

<a id="method__boardkind.1" class="lexicon_definition"></a>
#### boardkind(handle::UInt32) [¶](#method__boardkind.1)
Returns the kind of digitizer; corresponds to a constant in AlazarConstants.jl
in the Alazar.jl package.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:144](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L144)

---

<a id="method__bytes_per_sample.1" class="lexicon_definition"></a>
#### bytes_per_sample(a::PainterQB.AlazarModule.AlazarATS9360) [¶](#method__bytes_per_sample.1)
Hard coded to return 2. May need to change if we want to play with data packing.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:239](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L239)

---

<a id="method__bytes_per_sample.2" class="lexicon_definition"></a>
#### bytes_per_sample(a::PainterQB.AlazarModule.InstrumentAlazar) [¶](#method__bytes_per_sample.2)
Returns the number of bytes per sample. Calls `bitspersample` and does ceiling
division by 8.


*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:402](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L402)

---

<a id="method__generate_configure.1" class="lexicon_definition"></a>
#### generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}}) [¶](#method__generate_configure.1)
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, ::Type{PropertySubtype}, infixes...)
```


*source:*
[PainterQB\src\Metaprogramming.jl:82](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\Metaprogramming.jl#L82)

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
[PainterQB\src\Metaprogramming.jl:122](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\Metaprogramming.jl#L122)

---

<a id="method__generate_configure.3" class="lexicon_definition"></a>
#### generate_configure{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  returntype...) [¶](#method__generate_configure.3)
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, Property, values..., infixes...)
```


*source:*
[PainterQB\src\Metaprogramming.jl:151](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\Metaprogramming.jl#L151)

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
[PainterQB\src\Metaprogramming.jl:221](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\Metaprogramming.jl#L221)

---

<a id="method__generate_inspect.1" class="lexicon_definition"></a>
#### generate_inspect{S<:PainterQB.Instrument, T<:PainterQB.InstrumentProperty{T}}(instype::Type{S<:PainterQB.Instrument},  command::ASCIIString,  proptype::Type{T<:PainterQB.InstrumentProperty{T}},  ::Type{PainterQB.NoArgs}) [¶](#method__generate_inspect.1)
This method does/returns nothing.

*source:*
[PainterQB\src\Metaprogramming.jl:14](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\Metaprogramming.jl#L14)

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
[PainterQB\src\Metaprogramming.jl:33](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\Metaprogramming.jl#L33)

---

<a id="method__generate_properties.1" class="lexicon_definition"></a>
#### generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}}) [¶](#method__generate_properties.1)
Creates and exports immutable singleton subtypes.

*source:*
[PainterQB\src\Metaprogramming.jl:183](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\Metaprogramming.jl#L183)

---

<a id="method__generate_properties.2" class="lexicon_definition"></a>
#### generate_properties{S<:PainterQB.InstrumentProperty{T}}(subtype::Symbol,  supertype::Type{S<:PainterQB.InstrumentProperty{T}},  docstring) [¶](#method__generate_properties.2)
Creates and exports immutable singleton subtypes.

*source:*
[PainterQB\src\Metaprogramming.jl:183](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\Metaprogramming.jl#L183)

---

<a id="method__scaling.1" class="lexicon_definition"></a>
#### scaling{T<:AbstractArray{T, N}}(resp::PainterQB.AlazarModule.FFTResponse{T<:AbstractArray{T, N}}) [¶](#method__scaling.1)
Returns the axis scaling for an FFT response.

*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:189](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L189)

---

<a id="method__scaling.2" class="lexicon_definition"></a>
#### scaling{T<:AbstractArray{T, N}}(resp::PainterQB.AlazarModule.FFTResponse{T<:AbstractArray{T, N}},  whichaxis::Integer) [¶](#method__scaling.2)
Returns the axis scaling for an FFT response.

*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:189](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L189)

---

<a id="method__setwindow.1" class="lexicon_definition"></a>
#### setwindow(window,  ::Type{PainterQB.AlazarModule.Im},  m::PainterQB.AlazarModule.FFTRecordMode) [¶](#method__setwindow.1)
Set the window for the imag part of the FFT. Must be followed by calling `windowing`.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:764](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L764)

---

<a id="method__setwindow.2" class="lexicon_definition"></a>
#### setwindow(window,  ::Type{PainterQB.AlazarModule.Re},  m::PainterQB.AlazarModule.FFTRecordMode) [¶](#method__setwindow.2)
Set the window for the real part of the FFT. Must be followed by calling `windowing`.

*source:*
[PainterQB\src\instruments\Alazar\Functions.jl:758](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Functions.jl#L758)

---

<a id="method__tofloat.1" class="lexicon_definition"></a>
#### tofloat!(sam_per_buf::Integer,  buf_completed::Integer,  backing::SharedArray{T, N}) [¶](#method__tofloat.1)
Arrange multithreaded conversion of the Alazar 12-bit integer format to 16-bit
floating point format.


*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:384](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L384)

---

<a id="method__triglevel.1" class="lexicon_definition"></a>
#### triglevel(a::PainterQB.AlazarModule.AlazarATS9360,  x) [¶](#method__triglevel.1)
Returns a UInt32 in the range 0--255 given a desired trigger level in Volts.


*source:*
[PainterQB\src\instruments\Alazar\models\ATS9360.jl:244](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9360.jl#L244)

## Types [Internal]

---

<a id="type__alazarats9440.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.AlazarATS9440 [¶](#type__alazarats9440.1)
Abstract type; not implemented.

*source:*
[PainterQB\src\instruments\Alazar\models\ATS9440.jl:2](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\models\ATS9440.jl#L2)

---

<a id="type__alazarresponse.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.AlazarResponse{T} [¶](#type__alazarresponse.1)
Abstract `Response` from an Alazar digitizer instrument.

*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:12](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L12)

---

<a id="type__fftresponse.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.FFTResponse{T} [¶](#type__fftresponse.1)
Abstract FFT `Response` from an Alazar digitizer instrument.

*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:21](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L21)

---

<a id="type__recordresponse.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.RecordResponse{T} [¶](#type__recordresponse.1)
Abstract time-domain record `Response` from an Alazar digitizer instrument.

*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:18](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L18)

---

<a id="type__streamresponse.1" class="lexicon_definition"></a>
#### PainterQB.AlazarModule.StreamResponse{T} [¶](#type__streamresponse.1)
Abstract time-domain streaming `Response` from an Alazar digitizer instrument.

*source:*
[PainterQB\src\instruments\Alazar\Responses.jl:15](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Responses.jl#L15)

## Macros [Internal]

---

<a id="macro___eh2.1" class="lexicon_definition"></a>
#### @eh2(expr) [¶](#macro___eh2.1)
Takes an Alazar API call and brackets it with some error checking.
Throws an InstrumentException if there is an error.


*source:*
[PainterQB\src\instruments\Alazar\Errors.jl:8](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Errors.jl#L8)

## Globals [Internal]

---

<a id="global__lib_opened.1" class="lexicon_definition"></a>
#### lib_opened [¶](#global__lib_opened.1)
Flag indicating whether the AlazarTech shared library has been opened.

*source:*
[PainterQB\src\instruments\Alazar\Alazar.jl:16](https://github.com/ajkeller34/PainterQB.jl/tree/180ac247894f4bc6fc3d116db9044f49f6fdd84c/src\instruments\Alazar\Alazar.jl#L16)

