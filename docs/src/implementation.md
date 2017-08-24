# Implementation overview

## Code organization

- Each instrument is defined within its own module, a submodule of `InstrumentControl`.
Each instrument is a subtype of `Instrument`. By convention, instrument model
numbers are used for module definitions (e.g. `AWG5014C`), so type names have
"Ins" prepended (e.g. `InsAWG5014`).
- Low-level wrappers for shared libraries are kept in their own packages (e.g. `VISA`, `Alazar`, and `KeysightInstruments` calls).
This way, at least some code can be reused if someone else does not want to use our codebase.
- All sweep related type definitions and functions described in [Sweep Jobs](https://painterqubits.github.io/InstrumentControl.jl/sweep/)
can be found in `src/Sweep.jl`
- Abstract type definitions like `Instrument` and `Stimulus`, are defined in
[ICCommon.jl](https://github.com/PainterQubits/ICCommon.jl)  
- `src/Definitions.jl` contains some definitions of other commonly used functions
and types. `src/config.jl` parses information in `deps/config.json` for talking to
the database set up by ICDataServer, such as username information, database server
address, path for saving results of sweeps, and stores it in a dictionary for access
to all other functions that need this information to communicate with the database

## Communication with ICDataServer

The functionality of the InstrumentControl.jl package is intertwined with the
[ICDataServer.jl](https://github.com/PainterQubits/ICDataServer.jl) package.
ICDataServer sets up a relational database (RDBMS) with which it communicates with
through SQL. InstrumentControl talks to that database; this database is used to
maintain a log of information for each job: the job is identified by the job ID,
and it mantains any metadata specified by the database creator. In its current
implementation, the data saved to the database is the time of job submission, the
time of job completion, and the latest job status, but we hope to add more logging
functionality to the code over time.

When `sweep` is executed, the function communicates with the ICDataServer to create
a new entry in the database table; the identifier of the new entry is a new job ID
that the RDMS itself creates. ICDataServer then communicates back to InstrumentControl
with this particular job ID and the time of submission; this job metadata is immediately
stored in the `SweepJob` object (created by the `sweep` function as a handle to
the new job). The job is then queued with the provided job ID as it's identifier.

The actual communication between the two packages is mediated by the popular
[ZeroMQ](http://zeromq.org/) distributed messaging software; we utilize it's
[ZMQ](https://github.com/JuliaInterop/ZMQ.jl) Julia interface. While the reader is
encouraged to go to these links for in-depth information, what you essentially need
to communicate between a client and a server with ZeroMQ is a *Context* and a
*socket*. In Julia, a `ZMQ.Context` object provides the framework for communication
via a TCP connection (or any analagous form of communication). The client and server
respectively will connect to a TCP port to send/receive information. The point of
entry/exit for information being passed along this TCP connection are the
ZMQ.Socket objects; they "bind" to the TCP ports and are the objects that the user
actually calls on the send and receive information.

When InstrumentControl is imported, a `ZMQ.Context` object is automatically
initialized. `ZMQ.Socket` objects are initialized in the first instance of
communication with the ICDataServer, and the same object is used thereafter for
communication within the same usage session. The socket objects are automatically bound
to TCP ports that the user specifies in the `deps/config.json` file. InstrumentControl
and ICDataServer communicate by binding to the same TCP connection.

## Metaprogramming for VISA instruments

Many commercial instruments support a common communications protocol and command
syntax (VISA and SCPI respectively). For such instruments, methods for
`setindex!` and `getindex`, as well as `Instrument` subtype and `InstrumentProperty`
subtype definitions, can be generated with metaprogramming, rather than
typing them out explicitly.

The file `src/MetaprogrammingVISA.jl` is used heavily for code generation based
on JSON template files. Since much of the logic for talking to instruments is
the same between VISA instruments, in some cases no code needs to be written
to control a new instrument provided an appropriate template file is prepared.
The metaprogramming functions are described below although they are not intended
to be used interactively.

```@docs
    InstrumentControl.insjson
    InstrumentControl.@generate_instruments
    InstrumentControl.@generate_properties
    InstrumentControl.@generate_handlers
    InstrumentControl.@generate_configure
    InstrumentControl.@generate_inspect
```

## Sweep, Sweep Jobs, and Sweep Queueing implementation

We stratify InstrumentControl "sweeps" functionality into different types, along
with helper functions for each type, in order to achieve a object-oriented architecture
with code modularity.

Measurement specific information, such as what independent variables will be swept and
what response will be measured, are contained in a `Sweep` type:

```@docs
InstrumentControl.Sweep
```

However, additional metadata is needed for scheduling and queueing of sweeps, as
well as logging of job information on ICDataServer. We "bundle" that information, along with a `Sweep` object, in a more comprehensive `SweepJob` type:

```@docs
InstrumentControl.SweepJob
InstrumentControl.SweepJob()
```

Finally, we require a *collection* object that can hold `SweepJob` objects, and
sort them by job priority, in addition to having  functionality for  automatic
scheduling of jobs in the background. For this purpose we define the
`SweepJobQueue` type, as well as a initialization inner constructor.

```@docs
InstrumentControl.SweepJobQueue
InstrumentControl.job_updater
InstrumentControl.job_starter
```

When InstrumentControl is imported, a default 'SweepJobQueue' object is instantiated
via the `SweepJobQueue()` constructor, and associated with a pointer called
`sweepjobqueue`. This is THE queue running in the background automatically scheduling
jobs, and referred to as the "default sweep job queue object" in the documentation.
This object can be returned by the following function:

```@docs
InstrumentControl.jobs()
```
Sweeps are scheduled by a call to the `sweep` function:

```@docs
InstrumentControl.sweep
InstrumentControl._sweep!
```
