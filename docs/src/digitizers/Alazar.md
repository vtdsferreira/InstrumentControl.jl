```@meta
CurrentModule = InstrumentControl.AlazarModule
DocTestSetup = quote
    using InstrumentControl
end
```

# Alazar digitizers

We put all Alazar digitizers in module `AlazarModule`; the feature set and API is so similar
for the various models that just one module makes sense.

An [`AlazarResponse`](@ref) type is given for each measurement mode of the digitizer.
("Traditional record mode" has not been implemented yet for lack of immediate need.)
Additionally, one can define custom `AlazarResponse` types so that some custom computations
or data reductions can be performed during acquisition. [`IQSoftwareResponse`](@ref) is
a good example of this.

In the following discussion, it is important to understand some Alazar terminology. Newer
Alazar digitizers use direct memory access (DMA) to stream data into a computer's RAM. A
single *acquisition* uses one or many *buffers*, which constitute preallocated regions in
the computer's physical memory. Each buffer contains one or many *records*. Each *record*
contains many *samples*, which are the voltages measured by the digitizer. In streaming
mode, there is only one record per buffer, but in other modes there can be many records per
buffer.

Looking at the source code, it would seem that there is some redundancy in the types, for
instance there is an `NPTRecordMode` and an `NPTRecordResponse` object. The former is used
internally in the code to denote a particular method of configuring the instrument,
mirroring the terminology used in the Alazar API documentation. The latter specifies what
you actually want to do using that configuration of the instrument. Perhaps you want to
measure in a given mode, but do some custom post-processing or processing during
acquisition. `IQSoftwareResponse` is an example of this: it uses `NPTRecordMode` but
reduces the data during measurement. Typically the user doesn't have to deal with the
various mode objects, unless developing a new `AlazarResponse` type.

## Usage

Here are the currently defined `AlazarResponse` types you can use:

```@docs
    ContinuousStreamResponse
    TriggeredStreamResponse
    NPTRecordResponse
    FFTHardwareResponse
    IQSoftwareResponse
```

These definitions referenced some abstract types, described here:

```@docs
    AlazarResponse
    StreamResponse
    RecordResponse
```

## Technical details

### Digitizer requirements

The Alazar digitizers expect buffers in physical memory which are page-aligned. The size of
each buffer should also be chosen appropriately.

The behavior of the digitizer is not specified when the buffer is made larger than 64 MB. On
our computer, it seems like an `ApiWaitTimeout` error is thrown when the buffer is too large
(for some unspecified definition of "large" greater than 64 MB). The digitizer will then
throw `ApiInsufficientResources` errors whenever another acquisition is attempted, until the
computer is restarted. Just restarting the Julia kernel, forcing a reload of the Alazar
DLLs, does not appear to be enough to reset the digitizer fully.

For performance reasons, a buffer should not be made much smaller than 1 MB if mulitple
buffers are required. There is also a minimum record size for each model of digitizer. For
the ATS9360, if a record has fewer than 256 samples (could be 128 from channel A + 128 from
channel B) then the acquisition will proceed, but return garbage data. Allocating too small
of a buffer is therefore still bad, but less fatal than allocating one that is too large.

### How to allocate appropriate buffers in Julia

In Julia, just allocating an array will not necessarily return a page-aligned block in
memory. The Alazar.jl package provides two array types to help with this. These arrays
are not required to be created by the user.

- `Alazar.PageAlignedVector` is just like `Base.Vector` except that the memory backing
  the array is guaranteed to be page-aligned.
- The elements of an `Alazar.DMABufferVector` are pointers to different locations in memory
  which are page-aligned and can act as DMA buffers. The array is iterable and indexable as
  usual. The `Alazar.DMABufferVector` must itself be backed by a page-aligned array type,
  like `Alazar.PageAlignedVector` or `Base.SharedVector` (although support for
  `Base.SharedVector` is absent in InstrumentControl).
