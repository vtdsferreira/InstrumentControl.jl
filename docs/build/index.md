
<a id='PainterQB.jl-1'></a>

# PainterQB.jl


A [Julia](http://julialang.org) package for qubit measurement and analysis.


<a id='Installation-1'></a>

## Installation


  * Install [National Instruments VISA libraries](https://www.ni.com/visa/)  (tested with v15.0.1 on Windows 10)
  * Install [AlazarTech](http://www.alazartech.com) digitizer drivers and shared libraries  (may need to contact AlazarTech)
  * Install [VISA.jl](http://www.github.com/ajkeller34/VISA.jl)
  * Install [Alazar.jl](http://www.github.com/ajkeller34/Alazar.jl)
  * Install [PainterQB.jl](http://www.github.com/ajkeller34/PainterQB.jl)


<a id='Quick-start-1'></a>

## Quick start


```
using PainterQB
using PainterQB.Alazar
using PainterQB.AWG5014C  # etc.

awg = InsAWG5014C(tcpip_socket("1.2.3.4",5000))
ats = InsAlazarATS9360()

# do something with awg and ats
```

