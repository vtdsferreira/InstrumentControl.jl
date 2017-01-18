## Imports
import VISA
import Base: read, write, readavailable, reset, wait
import Base: cp, mkdir, readdir, rm
import Base: getindex, setindex!
import Compat
import Compat.@compat

## Get the resource manager
# """
# ```
# const resourcemanager
# ```
#
# The default VISA resource manager as returned by `VISA.viOpenDefaultRM()`.
# """

export resourcemanager

## VISA specific InstrumentProperty subtypes
export WriteTermCharEnable

## Finding and obtaining resources
export findresources
export gpib, tcpip_instr, tcpip_socket

## Reading and writing (commands)
export ask, read, write, readavailable
export binblockwrite, binblockreadavailable

## Common VISA commands
export tst, rst, idn, cls
export trg, abor, wai, opc, errors

## Convenience
export quoted, unquoted

## Instrument file manipulation
export cp
export getfile
export loadstate
export mkdir
export readdir
export rm
export savestate

# Instruments supporting VISA are expected to have fields, at minimum:
# `vi::ViSession`
# `writeTerminator::AbstractString`


"""
```
abstract WriteTermCharEnable <: InstrumentProperty
```

Write terminator character for VISA instruments.
"""
abstract WriteTermCharEnable <: InstrumentProperty


## Finding and obtaining resources

"Finds VISA resources to which we can connect. Doesn't seem to find ethernet instruments."
findresources(expr::AbstractString="?*::INSTR") = VISA.viFindRsrc(resourcemanager, expr)

"""
Returns a `viSession` for the given GPIB primary address using board 0.
See VISA spec for details on what a `viSession` is.
"""
gpib(primary) = VISA.viOpen(resourcemanager, "GPIB::"*primary*"::0::INSTR")

"""
Returns a `viSession` for the given GPIB board and primary address.
See VISA spec for details on what a `viSession` is.
"""
gpib(board, primary) = VISA.viOpen(
    resourcemanager, "GPIB"*(board == 0 ? "" : board)+"::"*primary*"::0::INSTR")

"""
Returns a `viSession` for the given GPIB board, primary, and secondary address.
See VISA spec for details on what a `viSession` is.
"""
gpib(board, primary, secondary) = VISA.viOpen(resourcemanager,
    "GPIB"*(board == 0 ? "" : board)*"::"+primary+"::"+secondary+"::INSTR")

"Returns a INSTR `viSession` for the given IPv4 address string."
tcpip_instr(ip) = VISA.viOpen(resourcemanager, "TCPIP::"*ip*"::INSTR")

"Returns a raw socket `viSession` for the given IPv4 address string."
tcpip_socket(ip,port) = VISA.viOpen(resourcemanager,
    "TCPIP0::"*ip*"::"*string(port)*"::SOCKET")

## Reading and writing

"""Idiomatic "write and read available" function with optional delay."""
function ask(ins::Instrument, msg::AbstractString, infixes...; delay::Real=0)
    write(ins, msg, infixes...)
    sleep(delay)
    readavailable(ins)
end

"""
Read from an instrument. Strips trailing carriage returns and new lines.
Note that this function will only read so many characters (buffered).
"""
read(ins::Instrument) =
    rstrip(Compat.String(VISA.viRead(ins.vi)), ['\r', '\n'])

"""
Write to an instrument.
Replaces hash signs with infixes and appends the instrument's write terminator.
"""
function write(ins::Instrument, msg::AbstractString, infixes...)
    for infix in infixes
        msg = replace(msg, "#", infix, 1)
    end
    msg == "" && return nothing
    # println(msg)
    VISA.viWrite(ins.vi, string(msg, ins.writeTerminator))
    return nothing
end

"Keep reading from an instrument until the instrument says we are done."
readavailable(ins::Instrument) =
    rstrip(Compat.String(VISA.readAvailable(ins.vi)), ['\r','\n'])

"""
Write an IEEE header block followed by an arbitary sequency of bytes and the terminator.
"""
binblockwrite(ins::Instrument,
    message::Union{AbstractString, Vector{UInt8}}, data::Vector{UInt8}) =
    VISA.binBlockWrite(ins.vi, message, data, ins.writeTerminator)

"Read an entire block of bytes with properly formatted IEEE header."
binblockreadavailable(ins::Instrument) = VISA.binBlockReadAvailable(ins.vi)

## IEEE standard commands

"Test with the *TST? command."
tst(ins::Instrument) = write(ins, "*TST?")

"""
```
rst(ins::Instrument)
```

Reset with the \*RST command.
"""
rst(ins::Instrument) = write(ins, "*RST")

"""
```
idn(ins::Instrument)
```

Ask the \*IDN? command.
"""
idn(ins::Instrument) = ask(ins, "*IDN?")

"""
```
cls(ins::Instrument)
```

Clear registers with \*CLS.
"""
cls(ins::Instrument) = write(ins, "*CLS")

"""
```
trg(ins::Instrument)
```

Bus trigger with \*TRG.
"""
trg(ins::Instrument) = write(ins, "*TRG")

"""
```
wai(ins::Instrument)
```

Wait for completion of a sweep with \*WAI.
"""
wai(ins::Instrument) = write(ins, "*WAI")

"""
```
opc(ins::Instrument)
```

Wait for completion of a sweep with \*OPC?.
"""
opc(ins::Instrument) = ask(ins, "*OPC?")

# Useful common commands

"Abort triggering with ABOR."
abor(ins::Instrument)   = write(ins, "ABOR")

"""
Interrogate errors using `:SYST:ERR?` and raise an `InstrumentException`
if appropriate. Otherwise, return `nothing`.

The `maxerrors` optional argument prevents this function from querying
the instrument forever if there is some unexpected trouble.
"""
function errors(ins::Instrument, maxerrors=100)
    i, res = 0, split(ask(ins, ":SYST:ERR?"), ",")
    if parse(res[1])::Int != 0
        codes = Int64[]
        strings = UTF8String[]
        while (i < maxerrors && parse(res[1])::Int != 0)
            push!(codes, parse(res[1])::Int)
            push!(strings, res[2])
            res = split(ask(ins, ":SYST:ERR?"),",")
            i+=1
        end
        throw(InstrumentException(ins, codes, strings))
    end
    nothing
end

"""
`getindex(ins::Instrument, ::Type{Timeout})`

Get the VISA timeout time (in ms).
"""
function getindex(ins::Instrument, ::Type{Timeout})
    Int64(VISA.viGetAttribute(ins.vi, VISA.VI_ATTR_TMO_VALUE))
end

"""
`getindex(ins::Instrument, ::Type{WriteTermCharEnable})`

Is the write termination character enabled?
"""
function getindex(ins::Instrument, ::Type{WriteTermCharEnable})
    Bool(VISA.viGetAttribute(ins.vi, VISA.VI_ATTR_TERMCHAR_EN))
end

"""
`setindex!(ins::Instrument, x::Real, ::Type{Timeout})`

Set the VISA timeout time (in ms).
"""
function setindex!(ins::Instrument, x::Real, ::Type{Timeout})
    VISA.viSetAttribute(ins.vi, VISA.VI_ATTR_TMO_VALUE, UInt64(x))
    nothing
end

"""
`setindex!(ins::Instrument, x::Bool, ::Type{WriteTermCharEnable})`

Set whether or not the write termination character is enabled.
"""
function setindex!(ins::Instrument, x::Bool, ::Type{WriteTermCharEnable})
    VISA.viSetAttribute(ins.vi, VISA.VI_ATTR_TERMCHAR_EN, UInt64(x))
    nothing
end

## Convenient functions for parsing and sending strings.

"Surround a string in quotation marks."
quoted(str::AbstractString) = "\""*str*"\""

"Strip a string of enclosing quotation marks."
unquoted(str::AbstractString) = strip(str,['"','\''])

## Convenient functions for querying arrays of numbers.
"Retreive and parse a delimited string into an `Array{Float64,1}`."
function getdata(ins::Instrument, ::Type{Val{:ASCIIString}},
        cmd, infixes...; delim=",")
    for infix in infixes
        cmd = replace(cmd, "#", infix, 1)
    end
    data = ask(ins, cmd)
    [parse(x)::Float64 for x in split(data, delim)]
end

"""
Parse a binary block, taking care of float size and byte ordering.
Return type is always `Array{Float64,1}` regardless of transfer format.
"""
function getdata{T}(ins::Instrument, ::Type{Val{T}}, cmd, infixes...)
    for infix in infixes
        cmd = replace(cmd, "#", infix, 1)
    end
    write(ins, cmd)
    io = binblockreadavailable(ins)

    endian = ins[TransferByteOrder]
    _conv = (endian == :LittleEndian ? ltoh : ntoh)

    bytes = sizeof(T)
    nsam = Int(floor((io.size-(io.ptr-1))/bytes))

    array = Vector{Float64}(nsam)
    for i=1:nsam
        array[i] = (_conv)(read(io, T))
    end

    array
end

## File management

"""
MMEMory:COPY
[E5071C](http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/memory/scpi_mmemory_copy.htm)
[ZNB20](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87048.htm)

Copy a file from path `src` to `dest`, both on the instrument.
"""
function cp(ins::Instrument, src::AbstractString, dest::AbstractString)
    write(ins, "MMEMory:COPY "*quoted(src)*","*quoted(dest))
end

"""
MMEMory:TRANsfer
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/memory/_mmem_tran.htm]

Copy a file from path `src` on the instrument, to path `dest` on the computer.
There may be size limits for transfer via this protocol.
"""
function getfile(ins::Instrument, src::AbstractString, dest::AbstractString)
    write(ins, ":MMEM:TRAN? #", quoted(src))
    io = binblockreadavailable(ins)
    byt = @compat read(io)
    fi = open(dest, "w+")   # Overwrites...
    write(fi, byt)
    close(fi)
end

"""
MMEMory:LOAD:STATe
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/memory/scpi_mmemory_load_state.htm]

Load the settings of the instrument, and possibly other info (e.g. calibration).
"""
function loadstate(ins::Instrument, file::AbstractString)
    write(ins, ":MMEM:LOAD:STAT #", quoted(file))
end

"""
MMEMory:MDIRectory
[E5071C](http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/memory/scpi_mmemory_mdirectory.htm)
[ZNB20](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e89416.htm)

Make a directory.
"""
function mkdir(ins::Instrument, dir::AbstractString)
    write(ins, "MMEMory:MDIRectory "*quoted(dir))
end

"""
MMEMory:CATalog?
[E5071C](http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/memory/scpi_mmemory_catalog_dir.htm)
[ZNB20](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/7f7650b75a604b3d.htm)

Read the directory contents.
"""
function readdir(ins::Instrument, dir::AbstractString="")
    cmd = "MMEMory:CATalog?"
    if dir != ""
        cmd = cmd*" "*quoted(dir)
    end
    res = unquoted(ask(ins, cmd))
    _readdir(ins, res)
end

"Helper function to process `readdir` response."
_readdir(ins::Instrument, res::AbstractString) = split(res,",")[3:3:end]

"""
MMEMory:DELete
[E5071C](http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/memory/scpi_mmemory_delete.htm)
[ZNB20](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87202.htm)

Remove a file.
"""
function rm(ins::Instrument, file::AbstractString)
    write(ins, "MMEM:DEL #", quoted(file))
end

"""
MMEMory:STORe:STATe
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/memory/scpi_mmemory_store_state.htm]

Save the settings of the instrument, and possibly other info (e.g. calibration).
"""
function savestate(ins::Instrument, file::AbstractString)
    write(ins, ":MMEM:STOR:STAT #", quoted(file))
end

## Data transfer formats
# """
# Configure the transfer byte order: `LittleEndianTransfer`, `BigEndianTransfer`.
#
# FORMAT:BORDER
# [E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/format/scpi_format_border.htm]
# [ZNB20](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/d36e85486.htm)
# """
# """
# FORMAT:DATA
# [E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/format/scpi_format_data.htm]
# [ZNB20](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/d36e85516.htm)
#
# Configures the data transfer format:
# `TransferFormat{ASCIIString}`, `TransferFormat{Float32}`,
# `TransferFormat{Float64}`.
# For the latter two the byte order should also be considered.
# """
