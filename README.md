# Controlling instruments in Julia

[Painter group](http://copilot.caltech.edu) implementation of instrument control in [Julia](https://github.com/julialang/Julia). Special attention is being given to instruments suitable for qubit measurements. Work in progress, not ready for implementation.

[Documentation](https://ajkeller34.github.io/PainterQB.jl/) is being written as the code is developed.

## To do

#### Globally

- Methods created with metaprogramming are undocumented.
- Types created with metaprogramming are undocumented.
- Units! A good starting point would be the
[SIUnits.jl](https://github.com/Keno/SIUnits.jl) package. It currently does
not support fractional units like V/sqrt(Hz) but support could be added.
- How to save / load configurations for instruments? Maybe JSON files?
- How to save / load data?
- Plotting ease-of-use features?

#### AWG5014C

- Waveform methods could be made more Julian
- Sequencer support needed

#### Alazar

- Some properties seem to be overwritten when switching between measurement
modes. e.g. when measuring a ContinuousStreamResponse the trigger needs to be
reconfigured before measuring a TriggeredStreamResponse.
