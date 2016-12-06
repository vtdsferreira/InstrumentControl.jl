# Implementation overview

## Code organization

- Each instrument is defined within its own module, a submodule of `InstrumentControl`.
Each instrument is a subtype of `InstrumentVISA <: Instrument`. By convention,
instrument model numbers are used for module definitions
(e.g. `AWG5014C`), so type names have "Ins" prepended (e.g. `InsAWG5014`).
- `InstrumentVISA` and associated functions are defined in `src/VISA.jl`.
- Low-level wrappers for shared libraries are kept in their own packages
(e.g. `VISA` and `Alazar` calls). This way, at least some code can be reused if
someone else does not want to use our codebase.
- Early instrument definitions and functions like `Instrument` and
`InstrumentException` are defined in `src/definitions.jl`. If there is ever
trouble with `InstrumentProperty` subtypes not being defined by the time they
are used in a function, they can be defined and exported manually here.
- `export` statements from an instrument submodule are not currently exported
from `InstrumentControl`. Therefore you may want to type `using InstrumentControl.AWG5014C`
when using the AWG, for instance.

## Metaprogramming for VISA instruments

Many commercial instruments support a common communications protocol and command
syntax (VISA and SCPI respectively). For such instruments, methods for
`setindex!` and `getindex` can be generated with metaprogramming, rather than
typing them out explicitly.

The file `src/metaprogramming.jl` is used heavily for code generation based
on JSON template files. Since much of the logic for talking to instruments is
the same between VISA instruments, in some cases no code needs to be written
to control a new instrument provided an appropriate template file is prepared.
The metaprogramming functions are described below although they are not intended
to be used interactively.

```@docs
    InstrumentControl.insjson
    InstrumentControl.@generate_all
    InstrumentControl.@generate_instruments
    InstrumentControl.@generate_properties
    InstrumentControl.@generate_handlers
    InstrumentControl.@generate_configure
    InstrumentControl.@generate_inspect
```
