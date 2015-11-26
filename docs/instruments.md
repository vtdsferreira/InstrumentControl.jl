# Instruments

## What is an instrument?

For the purposes of this package, an instrument is just something connected to the
computer that we need to communicate with, and which can source or measure something.
Every instrument may connect to the computer by different hardware,
comms protocols, and command dialects.

All instruments are Julia objects, subtypes of the abstract type `Instrument`.

## Instrument types

Many instruments share the same communications protocols. We subtype `Instrument`
based on these protocols.

### VISA

Many instruments are able to be addressed using the
[VISA](http://www.ivifoundation.org/docs/vpp432_2014-06-19.pdf) standard (Virtual
Instrument Software Architecture), currently maintained by the IVI Foundation.
Any such instrument matches type signature `InstrumentVISA <: Instrument`.

To talk to VISA instruments will require the Julia package [VISA.jl](http://www.github.com/ajkeller34/VISA.jl)
as well as the [National Instruments VISA libraries](https://www.ni.com/visa/).
Installation instructions are available at each link.

### Alazar digitizers

Digitizers made by [AlazarTech](http://www.alazartech.com) are notably *not*
compatible with the VISA standard. The VISA standard was not really intended
for PCIe cards with extreme data throughput. All Alazar digitizers are addressable by an API
supplied by the company, which talks to the card through a shared library (.dll on
Windows or .so on Linux). Therefore, such instruments match type signature
`InstrumentAlazar <: Instrument`.

The shared library files and API documentation are only available from AlazarTech.

## Instrument interface

Instrument properties are configured and inspected using two functions,
`configure` and `inspect`. Why not `set` and `get`? Ultimately these verbs are
pretty generic and often have implicit meanings in other programming languages.
Merriam-Webster defines ["configure"](http://m-w.com/dictionary/configure)
as "to arrange or prepare (something) so that it can be used," and ["inspect"](http://m-w.com/dictionary/inspect)
as "to look at (something) carefully in order to learn more about it, to find problems, etc."
These verbs are perfect for describing what the functions do.

## Type definition

`abstract Instrument <: Any`

Abstract supertype of all concrete Instrument types, e.g. `AWG5014C <: Instrument`.
