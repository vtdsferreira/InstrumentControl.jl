InstrumentControl.jl
============

A [Julia](http://julialang.org) package for qubit measurement and analysis.

Installation
------------

+ Install [National Instruments VISA libraries](https://www.ni.com/visa/)
 (tested with v15.0.1 on Windows 10)
+ Install [AlazarTech](http://www.alazartech.com) digitizer drivers and shared libraries
 (may need to contact AlazarTech)
+ Install [VISA.jl](http://www.github.com/painterqubits/VISA.jl)
+ Install [Alazar.jl](http://www.github.com/painterqubits/Alazar.jl)
+ Install [InstrumentControl.jl](http://www.github.com/painterqubits/InstrumentControl.jl)

Quick start
-----------

```
using InstrumentControl
using InstrumentControl.Alazar
using InstrumentControl.AWG5014C  # etc.

awg = InsAWG5014C(tcpip_socket("1.2.3.4",5000))
ats = InsAlazarATS9360()

# do something with awg and ats
```
