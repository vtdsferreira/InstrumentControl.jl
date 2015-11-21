export InstrumentVISA

## Get the resource manager
import VISA
const  resourcemanager = VISA.viOpenDefaultRM()
export resourcemanager

## Finding and obtaining resources
export find_ins_resources
export gpib, tcpip_instr, tcpip_socket

## Reading and writing
export query_ins, read_ins, write_ins, readavailable_ins
export binblockwrite_ins, binblockreadavailable_ins

## Common VISA commands
export test_ins, reset_ins, identify_ins, clear_ins_registers
export trigger_ins, abort_trigger_ins

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
find_ins_resources(expr::AbstractString="?*::INSTR") = VISA.viFindRsrc(resourceManager, expr)

"Returns a viSession for the given GPIB address."
gpib(primary) = VISA.viOpen(resourceManager, "GPIB::"*primary*"::0::INSTR")

gpib(board, primary) = VISA.viOpen(
    resourceManager, "GPIB"*(board == 0 ? "" : board)+"::"*primary*"::0::INSTR")

gpib(board, primary, secondary) = VISA.viOpen(resourceManager,
    "GPIB"*(board == 0 ? "" : board)*"::"+primary+"::"+secondary+"::INSTR")

"Returns a INSTR viSession for the given IPv4 address."
tcpip_instr(ip) = VISA.viOpen(resourceManager, "TCPIP::"*ip*"::INSTR")

"Returns a raw socket viSession for the given IPv4 address."
tcpip_socket(ip,port) = VISA.viOpen(resourceManager,
    "TCPIP0::"*ip*"::"*string(port)*"::SOCKET")

## Reading and writing

"""Idiomatic "write and read available" function with optional delay."""
function query_ins(ins::InstrumentVISA, msg::ASCIIString, delay::Real=0)
    write_ins(ins, msg)
    sleep(delay)
    readavailable_ins(ins)
end

"""
Read from an instrument. Strips trailing carriage returns and new lines.
Note that this function will only read so many characters (buffered).
"""
read_ins(ins::InstrumentVISA) =
    rstrip(bytestring(VISA.viRead(ins.vi)), ['\r', '\n'])

"Write to an instrument. Appends the instrument's write terminator."
write_ins(ins::InstrumentVISA, msg::ASCIIString) =
    VISA.viWrite(ins.vi, string(msg, ins.writeTerminator))

"Keep reading from an instrument until the instrument says we are done."
readavailable_ins(ins::InstrumentVISA) =
    rstrip(bytestring(VISA.readAvailable(ins.vi)), ['\r','\n'])

"""
Write an IEEE header block followed by an arbitary sequency of bytes and the terminator.
"""
binblockwrite_ins(ins::InstrumentVISA,
    message::Union{ASCIIString, Vector{UInt8}}, data::Vector{UInt8}) =
    VISA.binBlockWrite(ins.vi, message, data, ins.writeTerminator)

"Read an entire block of bytes with properly formatted IEEE header."
binblockreadavailable_ins(ins::InstrumentVISA) = VISA.binBlockReadAvailable(ins.vi)

## Common VISA commands

test_ins(ins::InstrumentVISA)            = write(ins, "*TST?")
reset_ins(ins::InstrumentVISA)           = write(ins, "*RST")
identify_ins(ins::InstrumentVISA)        = query(ins, "*IDN?")
clear_ins_registers(ins::InstrumentVISA) = write(ins, "*CLS")

trigger_ins(ins::InstrumentVISA)         = write(ins, "*TRG")
abort_trigger_ins(ins::InstrumentVISA)   = write(ins, "ABOR")

## Convenient functions for parsing and sending strings.

quoted(str::ASCIIString) = "\""*str*"\""
unquoted(str::ASCIIString) = strip(str,"\"")
