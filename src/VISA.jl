## Imports
import VISA
import Base: read, write, readavailable, reset

## Get the resource manager
const  resourcemanager = VISA.viOpenDefaultRM()
export resourcemanager

## InstrumentVISA type
export InstrumentVISA

## Finding and obtaining resources
export findresources
export gpib, tcpip_instr, tcpip_socket

## Reading and writing
export ask, read, write, readavailable
export binblockwrite, binblockreadavailable

## Common VISA commands
export test, reset, identify, clearregisters
export trigger, aborttrigger

## Convenience
export quoted, unquoted

"""
### InstrumentVISA
`abstract InstrumentVISA <: Instrument`

Abstract supertype of all Instruments addressable using a VISA library.
Concrete types are expected to have fields:

`vi::ViSession`
`writeTerminator::ASCIIString`
"""
abstract InstrumentVISA <: Instrument

## Finding and obtaining resources

"Finds VISA resources to which we can connect. Doesn't find ethernet instruments."
findresources(expr::AbstractString="?*::INSTR") = VISA.viFindRsrc(resourcemanager, expr)

"Returns a viSession for the given GPIB address."
gpib(primary) = VISA.viOpen(resourcemanager, "GPIB::"*primary*"::0::INSTR")

gpib(board, primary) = VISA.viOpen(
    resourcemanager, "GPIB"*(board == 0 ? "" : board)+"::"*primary*"::0::INSTR")

gpib(board, primary, secondary) = VISA.viOpen(resourcemanager,
    "GPIB"*(board == 0 ? "" : board)*"::"+primary+"::"+secondary+"::INSTR")

"Returns a INSTR viSession for the given IPv4 address."
tcpip_instr(ip) = VISA.viOpen(resourcemanager, "TCPIP::"*ip*"::INSTR")

"Returns a raw socket viSession for the given IPv4 address."
tcpip_socket(ip,port) = VISA.viOpen(resourcemanager,
    "TCPIP0::"*ip*"::"*string(port)*"::SOCKET")

## Reading and writing

"""Idiomatic "write and read available" function with optional delay."""
function ask(ins::InstrumentVISA, msg::ASCIIString, delay::Real=0)
    write(ins, msg)
    sleep(delay)
    readavailable(ins)
end

"""
Read from an instrument. Strips trailing carriage returns and new lines.
Note that this function will only read so many characters (buffered).
"""
read(ins::InstrumentVISA) =
    rstrip(bytestring(VISA.viRead(ins.vi)), ['\r', '\n'])

"Write to an instrument. Appends the instrument's write terminator."
write(ins::InstrumentVISA, msg::ASCIIString) =
    VISA.viWrite(ins.vi, string(msg, ins.writeTerminator))

"Keep reading from an instrument until the instrument says we are done."
readavailable(ins::InstrumentVISA) =
    rstrip(bytestring(VISA.readAvailable(ins.vi)), ['\r','\n'])

"""
Write an IEEE header block followed by an arbitary sequency of bytes and the terminator.
"""
binblockwrite(ins::InstrumentVISA,
    message::Union{ASCIIString, Vector{UInt8}}, data::Vector{UInt8}) =
    VISA.binBlockWrite(ins.vi, message, data, ins.writeTerminator)

"Read an entire block of bytes with properly formatted IEEE header."
binblockreadavailable(ins::InstrumentVISA) = VISA.binBlockReadAvailable(ins.vi)

## Common VISA commands

test(ins::InstrumentVISA)            = write(ins, "*TST?")
reset(ins::InstrumentVISA)           = write(ins, "*RST")
identify(ins::InstrumentVISA)        = ask(ins, "*IDN?")
clearregisters(ins::InstrumentVISA)  = write(ins, "*CLS")

trigger(ins::InstrumentVISA)         = write(ins, "*TRG")
aborttrigger(ins::InstrumentVISA)   = write(ins, "ABOR")

## Convenient functions for parsing and sending strings.

quoted(str::ASCIIString) = "\""*str*"\""
unquoted(str::ASCIIString) = strip(str,"\"")
