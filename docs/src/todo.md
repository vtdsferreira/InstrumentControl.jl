## General

- How should we implement error-handling?

- How should we implement background tasks?

- Implement confirmation of changed instrument properties.

## Documentation

- Improve documentation of this package.
[Documenter.jl](https://github.com/MichaelHatherly/Documenter.jl)

## Units support

- Further work on [Unitful.jl](https://github.com/ajkeller34/Unitful.jl)
- Consider how to improve Julia Base to play nicely with Unitful.jl
- Should we start integrating support already?

## Saving and loading data

- Database for metadata?
- How to save / load configurations for instruments? Maybe JSON files?
- How to save / load data? Start with these packages:
[HDF5.jl](https://github.com/JuliaLang/HDF5.jl),
[JLD.jl](https://github.com/JuliaLang/JLD.jl)

## Plotting

- Take a look at [Plots.jl](https://github.com/tbreloff/Plots.jl)

- Live plotting engine. Right now we are using the recently open-sourced
[Plotly.js library](https://plot.ly/javascript/). The Julia process
responsible for measurement dumps some JSON data into a web socket during
a measurement. A web page connects to that web socket, parses the JSON data,
and configures Plotly accordingly. It is not obvious that this is the best
approach.

- There are two places where notifications could be emitted for plotting:
in `measure` or in `sweep`. Some thought should be given to how best to do this.

## Instrument-specific

### AWG5014C

- Sequencer support needed.

### VNAs

### Alazar

- A lot has changed since this code was written. Probably it does not work as is.
