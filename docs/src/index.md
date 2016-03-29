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
+ Install [PainterQB.jl](http://www.github.com/ajkeller34/PainterQB.jl)

Quick start
-----------

```
using PainterQB
using PainterQB.AlazarModule
using PainterQB.AWG5014CModule  # etc.

awg = AWG5014C(tcpip_socket("1.2.3.4",5000))
ats = AlazarATS9360()

# do something with awg and ats
```

Building this documentation
---------------------------
In a fresh instance of Julia:
```
include(joinpath(Pkg.dir("PainterQB"),"docs/make.jl"))
```

To process with mkdocs, run the following in the PainterQB/docs directory:
```
mkdocs build --clean
```

To serve locally or publish to GitHub, run either of the following in the
PainterQB/docs directory:
```
mkdocs serve
mkdocs gh-deploy --clean
```
