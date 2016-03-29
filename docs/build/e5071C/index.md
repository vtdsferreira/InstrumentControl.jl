<a id='Base.getindex' href='#Base.getindex'>#</a>
**`Base.getindex`** &mdash; *Function*.

---


[:CALCulate#:TRACe#:MARKer#:FUNCtion:TRACking][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_function_tracking.htm]

Set whether or not the marker search for marker `m` is repeated with trace updates.

[CALCulate#:TRACe#:MARKer#:Y?][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_y.htm]

[CALCulate#:TRACe#:MARKer#:X][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_x.htm]

[CALCulate#:TRACe#:MARKer#:STATe][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_state.htm]

Query whether marker `m` is displayed for channel `ch` and trace `tr`.

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.TriggerOutput})
```

[TRIGger:OUTPut][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_output_state.htm]

Turn on or off the external trigger output.

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TriggerSource})
```

[TRIGger:SEQuence:SOURce][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_sequence_source.htm]

Configure the trigger source: `InternalTrigger`, `ExternalTrigger`, `BusTrigger`, `ManualTrigger`.

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TriggerSlope})
```

[:TRIG:SEQ:EXT:SLOP][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_sequence_external_slope.htm]

Set slope of external trigger input port: `RisingTrigger`, `FallingTrigger`.

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TransferFormat})
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TransferByteOrder})
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.YReferencePosition},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.YReferenceLevel},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.YScalePerDivision},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.YDivisions},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.WaveguideCutoff},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.TraceMaximized},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.SmoothingAperture},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.Smoothing},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.TraceDisplay},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerSweepFrequency},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerSlopeLevel},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerSlope},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerPortLevel},ch::Integer=1,port::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerLevel},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerCoupled},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PointTrigger})
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PhaseOffset},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.Output})
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.NumPoints},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.NumTraces},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.IFBandwidth},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.FrequencySpan},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.FrequencyCenter},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.FrequencyStop},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.FrequencyStart},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.ExtTriggerLowLatency})
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.ExtTriggerDelay})
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.ElectricalDelay},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.AveragingTrigger})
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.AveragingFactor},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.Averaging},ch::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TriggerOutputTiming})
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TriggerOutputPolarity})
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.Parameter},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.Format},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.ElectricalMedium},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.SweepTime},ch::Integer=1)
```

This command sets/gets the sweep time of selected channel (ch). Before using this object to set the sweep time, turns OFF the auto setting of the sweep time (specify False with the SCPI.SENSe(Ch).SWEep.TIME.AUTO object). When Port IFBW is turned ON, this command returns the sweep time for Port 1.

<a id='Base.setindex!' href='#Base.setindex!'>#</a>
**`Base.setindex!`** &mdash; *Function*.

---


DISPlay:SPLit [E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/display/scpi_display_split.htm]

`setindex!(ins::InstrumentVNA, ::Type{Windows}, a::AbstractArray{Int})`

Configure the layout of graph windows using a matrix to abstract the layout. For instance, passing [1 2; 3 3] makes two windows in one row and a third window below.

:CALC#:TRAC#:MARK#:X [E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_x.htm]

[:CALC#:TRAC#:MARK#:STATe][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_state.htm]

Turn on or off display of marker `m` for channel `ch` and trace `tr`.

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.E5071CModule.TriggerOutput})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.TriggerOutput})
```

[TRIGger:OUTPut][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_output_state.htm]

Turn on or off the external trigger output.

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Symbol,::Type{PainterQB.TriggerSource})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TriggerSource})
```

[TRIGger:SEQuence:SOURce][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_sequence_source.htm]

Configure the trigger source: `InternalTrigger`, `ExternalTrigger`, `BusTrigger`, `ManualTrigger`.

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Symbol,::Type{PainterQB.TriggerSlope})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TriggerSlope})
```

[:TRIG:SEQ:EXT:SLOP][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_sequence_external_slope.htm]

Set slope of external trigger input port: `RisingTrigger`, `FallingTrigger`.

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Symbol,::Type{PainterQB.TransferFormat})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TransferFormat})
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Symbol,::Type{PainterQB.TransferByteOrder})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TransferByteOrder})
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Integer,::Type{PainterQB.E5071CModule.YReferencePosition},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.YReferencePosition},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.YReferenceLevel},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.YReferenceLevel},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.YScalePerDivision},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.YScalePerDivision},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Integer,::Type{PainterQB.E5071CModule.YDivisions},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.YDivisions},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.WaveguideCutoff},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.WaveguideCutoff},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.E5071CModule.TraceMaximized},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.TraceMaximized},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.SmoothingAperture},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.SmoothingAperture},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.E5071CModule.Smoothing},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.Smoothing},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.E5071CModule.TraceDisplay},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.TraceDisplay},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.PowerSweepFrequency},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerSweepFrequency},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.PowerSlopeLevel},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerSlopeLevel},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.E5071CModule.PowerSlope},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerSlope},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.PowerPortLevel},ch::Integer=1,port::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerPortLevel},ch::Integer=1,port::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.PowerLevel},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerLevel},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.E5071CModule.PowerCoupled},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PowerCoupled},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.E5071CModule.PointTrigger})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PointTrigger})
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.PhaseOffset},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.PhaseOffset},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.Output})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.Output})
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Integer,::Type{PainterQB.NumPoints},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.NumPoints},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Integer,::Type{PainterQB.VNA.NumTraces},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.NumTraces},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.VNA.IFBandwidth},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.IFBandwidth},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.VNA.FrequencySpan},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.FrequencySpan},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.VNA.FrequencyCenter},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.FrequencyCenter},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.FrequencyStop},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.FrequencyStop},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.FrequencyStart},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.FrequencyStart},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.E5071CModule.ExtTriggerLowLatency})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.ExtTriggerLowLatency})
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.ExtTriggerDelay})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.ExtTriggerDelay})
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.ElectricalDelay},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.ElectricalDelay},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.E5071CModule.AveragingTrigger})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.AveragingTrigger})
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Integer,::Type{PainterQB.VNA.AveragingFactor},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.AveragingFactor},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Bool,::Type{PainterQB.VNA.Averaging},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.Averaging},ch::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Symbol,::Type{PainterQB.TriggerOutputTiming})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TriggerOutputTiming})
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Symbol,::Type{PainterQB.TriggerOutputPolarity})
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.TriggerOutputPolarity})
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Symbol,::Type{PainterQB.VNA.Parameter},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.Parameter},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Symbol,::Type{PainterQB.VNA.Format},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.Format},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Symbol,::Type{PainterQB.VNA.ElectricalMedium},ch::Integer=1,tr::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.VNA.ElectricalMedium},ch::Integer=1,tr::Integer=1)
```

Hey

```jl
setindex!(ins::PainterQB.E5071CModule.E5071C,v::Real,::Type{PainterQB.E5071CModule.SweepTime},ch::Integer=1)
```

```jl
getindex(ins::PainterQB.E5071CModule.E5071C,::Type{PainterQB.E5071CModule.SweepTime},ch::Integer=1)
```

This command sets/gets the sweep time of selected channel (ch). Before using this object to set the sweep time, turns OFF the auto setting of the sweep time (specify False with the SCPI.SENSe(Ch).SWEep.TIME.AUTO object). When Port IFBW is turned ON, this command returns the sweep time for Port 1.

