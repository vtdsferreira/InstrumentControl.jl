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
    - Common instrument definitions and functions are defined in `src/Definitions.jl`.
    - `InstrumentVISA` and associated functions are defined in `src/VISA.jl`.
    - Code that should be loaded by Julia workers for parallel processing is
    actually kept outside the module to avoid loading the whole module unnecessarily.
    These are typically functions that are focused on number crunching and don't
    need to know much about the internals of PainterQB.
- Each instrument is defined within its own module, a submodule of `PainterQB`.
    - Each instrument has a corresponding .jl file in `src/instruments`.
    - Instrument model numbers are used for type definitions (e.g. `AWG5014C`),
    so module names have "Module" appended (e.g. `AWG5014CModule`). We put all
    Alazar digitizers in `AlazarModule`; the feature set and API is so similar
    for the various models that just one module makes sense.
    - `export` statements from an instrument submodule are not currently exported
    from `PainterQB`. The statement `using PainterQB.AWG5014CModule`
    may be desired when using the AWG, for instance.
- To test for possible namespace conflicts when adding new instruments,
uncomment the `importall` statements in `src/PainterQB.jl`.
    - As functions from different instrument modules are imported, any functions
    that are defined in different modules will be printed and warned about. The
    solution is to define the shared function name in `src/Definitions.jl`
    (`global` and `export`) such that the submodules can both import the function.

## VISA instruments

Many commercial instruments support a common communications protocol and command
syntax (VISA and SCPI respectively). For such instruments, many methods for
`setindex!` and `getindex` can be generated with metaprogramming, rather than
typing them out explicitly.

The file `src/Metaprogramming.jl` is included in each VISA
instrument's source file, and therefore in each instrument's own module.
In the future this might be improved through more judicious choice of which
module `eval` is run in.

### Metaprogramming

The following methods are internal and do not need to be used explicitly.
They are described here for completeness.

    {docs}
    insjson


```
generate_handlers{T<:Instrument}(insType::Type{T}, responseDict::Dict)
```

Each instrument can have a `responseDict`. For each setting of the instrument,
for instance the `ClockSource`, we need to know the correspondence between a
logical state `ExternalClock` and how the instrument encodes that logical state
(e.g. "EXT").
The `responseDict` is actually a dictionary of dictionaries. The first level keys
are like `ClockSource` and the second level keys are like "EXT", with the value
being `:ExternalClock`. Undoubtedly
this nested dictionary is "nasty" (in the technical parlance) but the dictionary
is only used for code
creation and is not used at run-time (if the code works as intended).

This function makes a lot of other functions. Given some response from an instrument,
we require a function to map that response back on to the appropiate logical state.

`ClockSource(ins::AWG5014C, res::AbstractString)`
returns an `InternalClock` or `ExternalClock` type as appropriate,
based on the logical meaning of the response.

We also want a function to generate logical states without having to know the way
they are encoded by the instrument.

`code(ins::AWG5014C, ::Type{InternalClock})` returns "INT",
with "INT" encoding how to pass this logical state to the instrument `ins`.

## Responses
Unlike stimuli, all responses are subtypes of an abstract parametric type,
`Response{T}`. Although it may seem unduly abstract to have it be both abstract
and parametric, we use this
functionality to distinguish between desired return types of a measurement.
Suppose an instrument provides data in some kind of awkward format, like 12-bit
unsigned integers. For reasons of convenience we may want the measurement to
return the data in a machine-native `Int64` format, or we may want to specify
a linear or 2D shape for the data, etc.

An important consideration in writing fast Julia code is to ensure type stability.
In other words, the type that is returned from a function should depend only on
the method signature and not depend on some value at run-time. By parameterizing
`Response` types with the return type, we can ensure that `measure` will be
type stable. If we instead had the desired return type as some field
in a `Response` object, then `measure` would not be type stable.

#### Alazar digitizers

A response type is given for each measurement mode:
continuous streaming (`ContinuousStreamResponse`), triggered streaming (
`TriggeredStreamResponse`), NPT records (`NPTRecordResponse`),
and FPGA-based FFT calculations (`FFTHardwareResponse`).
Traditional record mode has not been implemented yet for lack of immediate need.

Looking at the source code, it would
seem that there is some redundancy in the types, for instance there is an
`NPTRecordMode` and an `NPTRecordResponse` object. The difference is that the
former is used internally in the code to denote a particular method of configuring
the instrument, allocating buffers, etc., whereas the latter specifies what you
actually want to do: retrieve NPT records from the digitizer, perhaps doing
some post-processing or processing during acquisition along the way. Perhaps
different responses would dictate different processing behavior, while the
instrument is ultimately configured the same way.

## Alazar instruments

In the following discussion, it is important to understand some Alazar terminology.
Newer Alazar digitizers use direct memory access (DMA) to stream data into
a computer's RAM. A single *acquisition* uses one or many *buffers*, which
constitute preallocated regions in the computer's physical memory. Each buffer
contains one or many *records*. Each *record* contains many *samples*,
which are the voltages measured by the digitizer.

In streaming mode, there is only one record per buffer, but in other modes there
can be many records per buffer.

### Buffer allocation

#### Digitizer requirements

The Alazar digitizers expect buffers in physical memory which are page-aligned.
The size of each buffer should also be chosen appropriately.

The behavior of the digitizer is not specified when the buffer is made larger
than 64 MB. On our computer, it seems like an `ApiWaitTimeout` error is thrown
when the buffer is too large (for some unspecified definition of "large" greater
than 64 MB). The digitizer will then throw `ApiInsufficientResources` errors
whenever another acquisition is attempted, until the computer is restarted.
Just restarting the Julia kernel, forcing a reload of the Alazar DLLs,
does not appear to be enough to reset the digitizer fully.

For performance reasons, a buffer should not be made much smaller than 1 MB if
mulitple buffers are required.
There is also a minimum record size for each model of digitizer. For the ATS9360,
if a record has fewer than 256 samples (could be 128 from channel A + 128 from channel B)
then the acquisition will proceed, but return garbage data. Allocating too small
of a buffer is therefore still bad, but less fatal than allocating one that is too large.

<!-- In our code a "sample" may be considered as a pair of values if two channels are
being measured, which is probably inconsistent with the API's definition. We
will clean this up eventually. -->

#### How to allocate appropriate buffers in Julia

In Julia, just allocating a fixed-size array will not necessarily return a
page-aligned block in memory. One approach would be to allocate our own page-aligned
memory using `valloc` and `vfree` (or their Windows equivalents).

```
function virtualalloc{T<:Union{UInt8,UInt16}}(size_bytes::Integer, ::Type{T})
    @windows? begin
        MEM_COMMIT = U32(0x1000)
        PAGE_READWRITE = U32(0x4)
        addr = ccall((:VirtualAlloc, "Kernel32"), Ptr{T},
                     (Ptr{Void}, Culonglong, Culong, Culong),
                     C_NULL, size_bytes, MEM_COMMIT, PAGE_READWRITE)
    end : (@linux? begin
        addr = ccall((:valloc, libc), Ptr{T}, (Culonglong,), size_bytes)
    end : throw(SystemError()))

    addr == C_NULL && throw(OutOfMemoryError())

    addr::Ptr{T}
end

function virtualfree{T<:Union{UInt16,UInt8}}(addr::Ptr{T})
    @windows? begin
        MEM_RELEASE = 0x8000
        ccall((:VirtualFree, "Kernel32"), Cint, (Ptr{Void}, Culonglong, Culong),
            addr, Culonglong(0), MEM_RELEASE)
    end : (@linux? begin
        ccall((:free, "libc"), Void, (Ptr{Void},), addr)
    end : throw(SystemError()))
    nothing
end
```

In case it wasn't obvious, this was my original approach.
Note that memory allocated in this way will not be visible to multiple processes
without extra work, and moreover we will need to deallocate the memory ourselves
at a later time, perhaps using `finalizer()` if the memory is made to be part of
a Julia object.

Fortunately, there is a special kind of array in Julia called the `SharedArray`.
It can be viewed and modified from multiple processes, and the memory is page-aligned.
Hopefully this continues to be the case in future Julia releases.
We implement a type called the `DMABufferArray` whose definition is worth
repeating here:

```
type DMABufferArray{sample_type} <:
        AbstractArray{Ptr{sample_type},1}

    bytes_buf::Int
    n_buf::Int
    backing::SharedArray{sample_type}

    DMABufferArray(bytes_buf, n_buf) = begin
        n_buf > 1 && bytes_buf % Base.Mmap.PAGESIZE != 0 &&
            error("Bytes per buffer must be a multiple of Base.Mmap.PAGESIZE when ",
                  "there is more than one buffer.")

        backing = SharedArray(sample_type,
                        Int((bytes_buf * n_buf) / sizeof(sample_type)))

        dmabuf = new(bytes_buf,
                     n_buf,
                     backing)

        return dmabuf
    end

end

Base.size(dma::DMABufferArray) = (dma.n_buf,)
Base.linearindexing(::Type{DMABufferArray}) = Base.LinearFast()
Base.getindex(dma::DMABufferArray, i::Int) =
    pointer(dma.backing) + (i-1) * dma.bytes_buf
Base.length(dma::DMABufferArray) = dma.n_buf

bytespersample{T}(buf_array::DMABufferArray{T}) = sizeof(T)
sampletype{T}(buf_array::DMABufferArray{T}) = T
```

Some comments:

- A single SharedArray is used to back *all* DMA buffers. Memory is therefore
contiguous and page-aligned.
- The memory for each DMA buffer is required to be a multiple of the page size
when there is more than one buffer.
- The memory can be accessed by multiple processes.
- The elements of a `DMABufferArray` are pointers to the the different
locations in memory which act as DMA buffers. The array is iterable and indexable
as usual.
