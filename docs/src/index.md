InstrumentControl.jl
============

A [Julia](http://julialang.org) package for qubit measurement and analysis.

Installation
------------

+ Install [National Instruments VISA libraries](https://www.ni.com/visa/)
  (tested with v15.0.1 on Windows 10)
+ Install [AlazarTech](http://www.alazartech.com) digitizer drivers and shared libraries
  (may need to contact AlazarTech) if using Alazar digitizer
+ Install [VISA.jl](http://www.github.com/painterqubits/VISA.jl) package
+ Install [Alazar.jl](http://www.github.com/painterqubits/Alazar.jl) package
+ Install [ICCommon.jl](https://github.com/PainterQubits/ICCommon.jl) package
+ Install [ICDataServer.jl](https://github.com/PainterQubits/ICDataServer.jl)
  package and follow it's [installation procedure](https://painterqubits.github.io/ICDataServer.jl/)
+ Install [InstrumentControl.jl](http://www.github.com/painterqubits/InstrumentControl.jl) package

Example Notebooks
-----------
InstrumentControl.jl relies on having physical instruments, communication
with a database set up by ICDataServer.jl, and various files with machine specific
configuration information in order to run. As such, we provide some example
notebooks in order to showcase this package's functionality.
```
# put example notebooks here
```
