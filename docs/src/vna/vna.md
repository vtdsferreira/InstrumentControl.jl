```@meta
DocTestSetup = quote
    using InstrumentControl.VNA
end
```

Most of the time you will probably want [`VNA.stimdata`](@ref), [`VNA.data`](@ref),
and [`VNA.FrequencySweep`](@ref).

## Stimuli and responses

```@docs
VNA.FrequencySweep
```

## Instrument properties

```@docs
VNA.Format
VNA.Graphs
VNA.Marker
VNA.MarkerX
VNA.MarkerY
VNA.Parameter
VNA.SearchTracking
```

## Methods

```@docs
    VNA.clearavg
    VNA.data
    VNA.search(::VNA.InstrumentVNA, ::VNA.MarkerSearch, ::VNA.MarkerSearch, ::VNA.MarkerSearch...)
    VNA.shotgun
    VNA.stimdata
    VNA.sweeptime
```

## Miscellaneous

```@docs
VNA.MarkerSearch
VNA.MarkerSearch(::Symbol, ::Any, ::Any, ::Any)
```
