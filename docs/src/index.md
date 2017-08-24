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
+ Install [KeysightInstruments.jl](https://github.com/PainterQubits/KeysightInstruments.jl) package
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

New to Julia
-----------
This documentation seeks to provide a higher-level description of the
architecture and control-flow of the code, with references to the source code only
to facilitate explanation. If the user seeks to understand the source code, while
this documentation is a useful aid, aptitude and understanding of the Julia language
will be necessary to fully understand it's implementation in a line by line level.
For those who have a background in programming, but not in Julia, below is a list
of Julia features used in the source code which might not be featured in other
languages, along with links to the Julia docs explaining them. It is our hope that,
with the reading listed below and this documentation, that any reader with some
background in programming would be able to satisfactorily understand the source code:

+ Types
    * [Julia Types in general](https://docs.julialang.org/en/stable/manual/types/)
    * [Parametric Types](https://docs.julialang.org/en/stable/manual/types/#Parametric-Types-1)
    * [Singleton Types](https://docs.julialang.org/en/stable/manual/types/#man-singleton-types-1)

+ Functions and Methods
    * [Optional and Keyword Arguments](https://docs.julialang.org/en/stable/manual/functions/#Optional-Arguments-1)
    * [Anonymous Functions](https://docs.julialang.org/en/stable/manual/functions/#man-anonymous-functions-1)
    * [Parametric Methods](https://docs.julialang.org/en/stable/manual/methods/#Parametric-Methods-1)
    * [Vararg Functions](https://docs.julialang.org/en/stable/manual/functions/#Varargs-Functions-1)

+ Macros and Metaprogramming
    * [Metaprogramming in general](https://docs.julialang.org/en/stable/manual/metaprogramming/) (also describes the `Symbol` type and expressions)
    * [Macros](https://docs.julialang.org/en/stable/manual/metaprogramming/#man-macros-1)

+ Tasks
    * [Tasks](https://docs.julialang.org/en/stable/manual/control-flow/#man-tasks-1)
    * [Dynamic Scheduling of Tasks](https://docs.julialang.org/en/stable/manual/parallel-computing/#Synchronization-With-Remote-References-1)

+ Miscellaneous
    * [Short Circuit Evaluation](https://docs.julialang.org/en/stable/manual/control-flow/#Short-Circuit-Evaluation-1)
