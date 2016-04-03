
<a id='General-1'></a>

## General


  * How should we implement error-handling?


  * How should we implement background tasks?


  * Implement confirmation of changed instrument properties.


<a id='Documentation-1'></a>

## Documentation


  * Improve documentation of this package. [Documenter.jl](https://github.com/MichaelHatherly/Documenter.jl)


<a id='Units-support-1'></a>

## Units support


  * Further work on [Unitful.jl](https://github.com/ajkeller34/Unitful.jl)
  * Consider how to improve Julia Base to play nicely with Unitful.jl
  * Should we start integrating support already?


<a id='Saving-and-loading-data-1'></a>

## Saving and loading data


  * Database for metadata?
  * How to save / load configurations for instruments? Maybe JSON files?
  * How to save / load data? Start with these packages: [HDF5.jl](https://github.com/JuliaLang/HDF5.jl), [JLD.jl](https://github.com/JuliaLang/JLD.jl)


<a id='Plotting-1'></a>

## Plotting


  * Take a look at [Plots.jl](https://github.com/tbreloff/Plots.jl)


  * Live plotting engine. Right now we are using the recently open-sourced [Plotly.js library](https://plot.ly/javascript/). The Julia process responsible for measurement dumps some JSON data into a web socket during a measurement. A web page connects to that web socket, parses the JSON data, and configures Plotly accordingly. It is not obvious that this is the best approach.


  * There are two places where notifications could be emitted for plotting: in `measure` or in `sweep`. Some thought should be given to how best to do this.


<a id='Instrument-specific-1'></a>

## Instrument-specific


<a id='AWG5014C-1'></a>

### AWG5014C


  * Sequencer support needed.


<a id='VNAs-1'></a>

### VNAs


<a id='Alazar-1'></a>

### Alazar


  * A lot has changed since this code was written. Probably it does not work as is.

