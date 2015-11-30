PainterQB.jl
============

A [Julia](http://julialang.org) package for qubit measurement and analysis.

Work in development, not ready for implementation. The documentation may assume some familiarity
with Julia.

Installation
------------

+ Install [National Instruments VISA libraries](https://www.ni.com/visa/)
 (tested with v15.0.1 on Windows 10)
+ Install [AlazarTech](http://www.alazartech.com) digitizer drivers and shared libraries
 (may need to contact AlazarTech)
+ Install [VISA.jl](http://www.github.com/ajkeller34/VISA.jl)
+ Install [Alazar.jl](http://www.github.com/ajkeller34/Alazar.jl)
+ Install this code and `include` it in a Julia environment

Quick start
-----------

```
using PainterQB
using PainterQB.AlazarModule
using PainterQB.AWG5014CModule  # etc.

awg = AWG5014C(tcpip_socket(1.2.3.4),5000)
ats = AlazarATS9360()

# do something with awg and ats
```

To do
-----

#### Globally

- Units! A good starting point would be the
[SIUnits.jl](https://github.com/Keno/SIUnits.jl) package. It currently does
not support fractional units like V/sqrt(Hz) but support could be added.

- How to save / load configurations for instruments? Maybe JSON files?

#### AWG5014C

- Waveform methods could be made more Julian
