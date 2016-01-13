# Controlling instruments in Julia

[Painter group](http://copilot.caltech.edu) implementation of instrument control in [Julia](https://github.com/julialang/Julia). Special attention is being given to instruments suitable for qubit measurements. Work in progress, not ready for implementation.

[Documentation](https://ajkeller34.github.io/PainterQB.jl/) is being written as the code is developed.

## To do

### Documentation

- Keep an eye on updated versions of the
[Docile.jl](https://github.com/MichaelHatherly/Docile.jl) and
[Lexicon.jl](https://github.com/MichaelHatherly/Lexicon.jl) packages. These
are currently used to build this documentation. However, at present, methods
and types that are created with metaprogramming are unable to be documented.
These packages predate the built-in documentation feature in Julia and at
present a rewrite is underway:
[Lapidary.jl](https://github.com/MichaelHatherly/Lapidary.jl)

### Units

- At present there is not an established units package in Julia. A good starting
point would be the [SIUnits.jl](https://github.com/Keno/SIUnits.jl) package.
It currently does not support fractional units like V/sqrt(Hz) but support
could be added.

### Saving / loading

- How to save / load configurations for instruments? Maybe JSON files?

- How to save / load data? Start with these packages:
[HDF5.jl](https://github.com/JuliaLang/HDF5.jl),
[JLD.jl](https://github.com/JuliaLang/JLD.jl)

### Plotting

- Live plotting engine. Right now we are using the recently open-sourced
[Plotly.js library](https://plot.ly/javascript/). The Julia process
responsible for measurement dumps some JSON data into a web socket during
a measurement. A web page connects to that web socket, parses the JSON data,
and configures Plotly accordingly. It is not obvious that this is the best
approach.
  - [node-julia](https://node-julia.readme.io/) appears to allow sharing of
  memory between Julia code and Javascript code, somehow. May be worth
  asking for clarification.
  - [Escher.jl](http://escher-jl.org/) looks intriguing but appears to be in
  development. Would probably take quite a bit of work to get this working.

- There are two places where notifications could be emitted for plotting:
in `measure` or in `sweep`. Some thought should be given to how best to do this.
Current idea is to emit plotting notifications from `sweep` when `measure`
returns a `Number`, and instead emit plotting notifications from `measure` when
`measure` returns an `AbstractArray`.

#### AWG5014C

- Waveform methods could be made more Julian
- Sequencer support needed

### VNAs

- Probably a lot of work needs to be done. First of all, which VNA are we
going to use?

### Alazar

- Some properties seem to be overwritten when switching between measurement
modes. e.g. when measuring a ContinuousStreamResponse the trigger needs to be
reconfigured before measuring a TriggeredStreamResponse.

- IQ mixing, FFT support needs improvement
