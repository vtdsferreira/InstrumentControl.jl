"""
Julia interface to the AlazarTech SDK.

Adapted from the C and Python APIs by Andrew Keller (andrew.keller.09@gmail.com)

Please see the ATS-SDK Guide for detailed specification of any functions
from the Alazar API.

In our implementation a "sample" refers to a value from a single channel.
You need to allocate memory for two values if you are measuring both channels.

Types:

InstrumentAlazar: Represents a digitizer. Abstract type.

AlazarATS9360: Concrete type.
AlazarATS9440: Abstract for now; accidentally wrote a method I didn't need

DSPModule: Concrete type representing a DSP module on a particular digitizer.

"""

module AlazarModule

lib_opened = false

using Alazar
import Base.show
importall PainterQB

export InstrumentAlazar

export inf_records
const inf_records = U32(0x7FFFFFFF)

"""
The InstrumentAlazar types represent an AlazarTech device on the local
system. It can be used to control configuration parameters, to
start acquisitions and to retrieve the acquired data.

Args:

  systemId (int): The board system identifier of the target
  board. Defaults to 1, which is suitable when there is only one
  board in the system.

  boardId (int): The target's board identifier in it's
  system. Defaults to 1, which is suitable when there is only one
  board in the system.

"""
abstract InstrumentAlazar <: Instrument

Base.show(io::IO, ins::InstrumentAlazar) = begin
    println(io, "$(typeof(ins)): ",
                "SystemId $(ins.systemId), BoardId $(ins.boardId)")
end

include("Errors.jl")
include("Modes.jl")
include("Properties.jl")
include("Functions.jl")
include("ConfigureInspect.jl")
include("DSP.jl")

# Model-specific type definitions and methods
include("models/ATS9360.jl")
include("models/ATS9440.jl")    # ~~not yet implemented~~

end
