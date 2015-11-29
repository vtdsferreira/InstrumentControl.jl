# Implementation overview

## Code organization

*Organizing the code into Julia modules is tricky and the organization may change
in future releases. It would not be surprising if the way Julia implements modules
changes before Julia v1.0.*

- With few exceptions, all code is kept inside a single package. For now the
package is unregistered and must be retrieved from the repository with
`Pkg.clone()` rather than `Pkg.add()`.
    - Low-level wrappers for shared libraries are kept in their own packages
    (e.g. VISA and Alazar calls). This way, at least some code can be reused if
    someone else does not want to use our codebase.
- All code is kept inside a "main" `PainterQB` module, defined inside `src/PainterQB.jl`.
    - Common instrument definitions and functions are defined in `src/InstrumentDefs.jl`.
    - `InstrumentVISA` and associated functions are defined in `src/InstrumentVISA.jl`.
- Each instrument is defined within its own module, a submodule of `PainterQB`.
    - Each instrument has a corresponding .jl file in `src/hardware`.
    - Instrument model numbers are used for type definitions (e.g. `AWG5014C`),
    so module names have "Module" appended (e.g. `AWG5014CModule`).
    - `export` statements from an instrument submodule are not currently exported
    from `PainterQB`. The statement `using PainterQB.AWG5014CModule`
    may be desired when using the AWG, for instance.
- To test for possible namespace conflicts when adding new instruments,
uncomment the `importall` statements in `src/PainterQB.jl`.
    - As functions from different instrument modules are imported, any functions
    that are defined in different modules will be printed and warned about. The
    solution is to define the shared function name in `src/InstrumentDefs.jl`
    (`global` and `export`) such that the submodules can both import the function.

## VISA Instruments

Many commercial instruments support a common communications protocol and command
syntax (VISA and SCPI respectively). For such instruments, many methods for
`configure` and `inspect` can be generated with metaprogramming, rather than
typing them out explicitly.

Technical note: The file `src/Metaprogramming.jl` is included in each VISA
instrument's source file, and therefore in each instrument's own module.
Initially this file was included directly in the PainterQB module, but it seems
there are subtleties regarding the use of the `@eval` macro between modules.

### Metaprogramming

#### generate_inspect

```
generate_inspect{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, returntype...)
```

This command takes an `Instrument` subtype `instype`, a VISA command, an
`InstrumentProperty` subtype `proptype`, and possibly an argument. It will
generate the following method in the module where `generate_inspect` is defined:

`inspect(ins::instype, ::Type{proptype}, infixes::Int...)`

The `infixes` variable argument allows for numbers to be inserted within the
commands, for instance in `OUTP#:FILT:FREQ`, where the `#` sign should be
replaced by an integer. The replacements are done in the order of the arguments.
Error checking is done on the number of arguments.

For a given property, `inspect` will return either an InstrumentProperty object,
a number, a boolean, or a string as appropriate.

#### generate_configure

```
generate_configure{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, returntype...)
```

This command takes an `Instrument` subtype `InsType`, a VISA command, an
`InstrumentProperty` type, and possibly an argument. It will generate one of the
following methods in the module where `generate_inspect` is defined:

```
configure(ins::InsType, PropertySubtype)
configure(ins::InsType, Property, values..., infixes...)
```

#### generate_properties

```
generate_properties{S<:InstrumentProperty}(subtype::Symbol, supertype::Type{S})
```

This makes it easy to generate new `InstrumentProperty` subtypes. Typically
this function is called inside a for loop. Calling this function is equivalent
to writing the following pseudocode:

```
immutable (subtype){T} <: supertype
    ins::Instrument
    code::T
    logicalname::AbstractString

    (subtype)(a,b) = new(a,b,string(subtype))
end

(subtype){T}(a::Instrument,b::T) = (subtype){T}(a,b)

export subtype

code{T}(inscode::subtype{T}) = inscode.code::T
```

Access to the `code` field is given through a method to allow for a little
flexibility in case implementation details change.

#### generate_handlers
