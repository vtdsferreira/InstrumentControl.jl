module ZNB20Module

## Import packages
import VISA
import Base: cd, cp, readdir, pwd, mkdir, rm

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
include(joinpath(Pkg.dir("PainterQB"),"src/Metaprogramming.jl"))

export ZNB20

export AutoSweepTime
export Bandwidth
export DisplayUpdate
export SweepTime
export TransferByteOrder
export TransferFormat
export Window

export cd
export cp
export data
export hidetrace
export lstrace
export mkdir
export mktrace
export pwd
export readdir
export rm
export rmtrace
export showtrace
export stimdata

znbool(a) = (Bool(a) ? "ON" : "OFF")

type ZNB20 <: InstrumentVISA
    vi::(VISA.ViSession)
    writeTerminator::ASCIIString
    model::AbstractString

    ZNB20(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        ins.model = "ZNB20"
        VISA.viSetAttribute(ins.vi, VISA.VI_ATTR_TERMCHAR_EN, UInt64(1))
        ins
    end

    ZNB20() = new()
end

abstract TransferByteOrder <: InstrumentProperty
abstract TransferFormat{T} <: InstrumentProperty

subtypesArray = [
    (:LittleEndianTransfer,  TransferByteOrder),
    (:BigEndianTransfer,     TransferByteOrder),
]

# Create all the concrete types we need using the generate_properties function.
for ((subtypeSymb,supertype) in subtypesArray)
    generate_properties(subtypeSymb, supertype)
end

responseDictionary = Dict(

    :TransferByteOrder => Dict("NORM"    => :BigEndianTransfer,
                               "SWAP"    => :LittleEndianTransfer),

    :VNAFormat         => Dict("MLIN" => :LinearMagnitude,
                               "MLOG" => :LogMagnitude,
                               "PHAS" => :Phase,
                               "UPH"  => :ExpandedPhase,  # Is it?
                               "POL"  => :PolarLinear, # Is it though?
                               "SMIT" => :Smith, # Is it?
                               "ISM"  => :SmithAdmittance, #Is it?
                               "GDEL" => :GroupDelay,
                               "REAL" => :RealPart,
                               "IMAG" => :ImagPart,
                               "SWR"  => :SWR),

    :OscillatorSource  => Dict("INT" => :InternalOscillator,
                               "EXT" => :ExternalOscillator),

    :TriggerSlope      => Dict("POS"  => :RisingTrigger,
                               "NEG"  => :FallingTrigger),

    :TriggerSource     => Dict("IMM"  => :InternalTrigger,
                               "EXT"  => :ExternalTrigger,
                               "MAN"  => :ManualTrigger,
                               "MULT" => :MultipleTrigger),

)

generate_handlers(ZNB20, responseDictionary)

code(ins::ZNB20, ::Type{TransferFormat{ASCIIString}}) = "ASC,0"
code(ins::ZNB20, ::Type{TransferFormat{Float32}}) = "REAL,32"
code(ins::ZNB20, ::Type{TransferFormat{Float64}}) = "REAL,64"
TransferFormat(ins::ZNB20, x::AbstractString) = begin
    if x=="ASC,0"
        return TransferFormat{ASCIIString}
    elseif x=="REAL,32"
        return TransferFormat{Float32}
    elseif x=="REAL,64"
        return TransferFormat{Float64}
    else
        error("Transfer format error.")
    end
end

"Configure or inspect. Does the instrument choose the minimum sweep time?"
abstract AutoSweepTime <: InstrumentProperty

"Configure or inspect. Measurement / resolution bandwidth. May be rounded."
abstract Bandwidth     <: InstrumentProperty{Float64}

"Configure or inspect. Display updates during measurement."
abstract DisplayUpdate <: InstrumentProperty

"Configure or inspect. Adjust time it takes to complete a sweep (all partial measurements)."
abstract SweepTime     <: InstrumentProperty

"`InstrumentProperty`: Window."
abstract Window        <: InstrumentProperty

### Configure and inspect

"""
[CALCULATE#:PARAMETER:SELECT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/3c03effa6de64ee5.htm)

Select an active trace. Channel `ch` defaults to 1.
"""
function configure(ins::ZNB20, ::Type{ActiveTrace}, name::AbstractString, ch::Int=1)
    write(ins, "CALCulate"*string(ch)":PARameter:SELect "*quoted(name))
end

"""
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Determines whether or not the instrument chooses the minimum sweep time,
including all partial measurements. Channel `ch` defaults to 1.
"""
function configure(ins::ZNB20, ::Type{AutoSweepTime}, b::Bool, ch::Int=1)
    write(ins, "SENSe"*string(ch)*":SWEep:TIME:AUTO "*znbool(b))
end

"""
[SENSE#:BWIDTH:RESOLUTION](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/dd1fd694e0ce4dd8.htm)

Set the measurement bandwidth between 1 Hz and 1 MHz
(option ZNBT-K17 up to 10 MHz).
Channel `ch` defaults to 1.
"""
function configure(ins::ZNB20, ::Type{Bandwidth}, bw::Float64, ch::Int=1)
    write(ins, "SENSe"*string(ch)*":BWIDth:RESolution "*string(bw))
end

"""
[SYSTEM:DISPLAY:UPDATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e114067.htm)

Switches display update on / off.
"""
function configure(ins::ZNB20, ::Type{DisplayUpdate}, b::Bool)
    write(ins, "SYSTem:DISPlay:UPDate "*znbool(b))
end

"""
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

Define measurement points per sweep. Channel `ch` defaults to 1.
"""
function configure(ins::ZNB20, ::Type{NumPoints}, n::Int, ch::Int=1)
    write(ins, "SENSe"*string(ch)*":SWEep:POINts "*string(n))
end

"""
[SENSE1:ROSCILLATOR:SOURCE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4314a7accd124cd8.htm)

Select oscillator source: `InternalOscillator`, `ExternalOscillator`
"""
function configure{T<:OscillatorSource}(ins::ZNB20, ::Type{T})
    write(ins, "SENSe1:ROSCillator:SOURce "*code(ins,T))
end

"""
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.
"""
function configure(ins::ZNB20, ::Type{SweepTime}, time::Real, ch::Int=1)
    write(ins, "SENSe"*string(ch)*":SWEep:TIME "*string(time))
end

"""
[FORMAT:BORDER](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e85486.htm)

Configure the transfer byte order: `LittleEndianTransfer`, `BigEndianTransfer`.
"""
function configure{T<:TransferByteOrder}(ins::ZNB20, ::Type{T})
    write(ins, "FORMat:BORDer "*code(ins, T))
end

"""
[FORMAT:DATA](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e85516.htm)

Configures the data transfer format:
`TransferFormat{ASCIIString}`, `TransferFormat{Float32}`,
`TransferFormat{Float64}`.
For the latter two the byte order should also be considered.
"""
function configure{T<:TransferFormat}(ins::ZNB20, ::Type{T})
    write(ins, "FORMat:DATA "*code(ins, T))
end

"""
[TRIGGER#:SEQUENCE:SLOPE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/cbc5449b57664ad3.htm)

Configure the trigger slope: `RisingTrigger`, `FallingTrigger`.
Channel `ch` defaults to 1.
"""
function configure{T<:TriggerSlope}(ins::ZNB20, ::Type{T}, ch::Int=1)
    write(ins, "TRIGger"*string(ch)*":SLOPe "*code(ins, T))
end

"""
[TRIGger#:SEQuence:SOURce](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/9c62999c5a1642f2.htm)

Configure the trigger source: `InternalTrigger`, `ExternalTrigger`, `ManualTrigger`,
`MultipleTrigger`. Channel `ch` defaults to 1.
"""
function configure{T<:TriggerSource}(ins::ZNB20, ::Type{T}, ch::Int=1)
    write(ins, "TRIGger"*string(ch)*":SOURce "*code(ins, T))
end

"""
[CALCULATE#:FORMAT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/132d40cd4d1d43c4.htm)

Configure the format of the active trace:
`LinearMagnitude`, `LogMagnitude`, `Phase`, `ExpandedPhase`, `PolarLinear`,
`Smith`, `SmithAdmittance`, `GroupDelay`, `RealPart`, `ImagPart`, `SWR`.
Channel `ch` defaults to 1.
"""
function configure{T<:VNAFormat}(ins::ZNB20, ::Type{T}, ch::Int=1)
    write(ins, "CALCulate"*string(ch)*":FORMat "*code(ins,T))
end

"""
[DISPLAY:WINDOW#:STATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/065c895d5a2c4230.htm)

Turn a window on or off.
"""
function configure(ins::ZNB20, ::Type{Window}, b::Bool, win::Int)
    write(ins,"DISPlay:WINDow"*string(win)*":STATe "*znbool(b))
end



"""
[CALCULATE#:PARAMETER:SELECT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/3c03effa6de64ee5.htm)

Query an active trace. Channel `ch` defaults to 1.
"""
function inspect(ins::ZNB20, ::Type{ActiveTrace}, ch::Int=1)
    unquoted(ask(ins, "CALCulate"*string(ch)":PARameter:SELect "*quoted(name)))
end

"""
[SENSE#:SWEEP:TIME:AUTO](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4e1073e7fde645a8.htm)

Does the instrument choose the minimum sweep time,
including all partial measurements? Channel `ch` defaults to 1.
"""
function inspect(ins::ZNB20, ::Type{AutoSweepTime}, ch::Int=1)
    Bool(parse(ask(ins, "SENSe"*string(ch)*":SWEep:TIME:AUTO?")))
end

"""
[SENSE#:BWIDTH:RESOLUTION](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/dd1fd694e0ce4dd8.htm)

Inspect the measurement bandwidth.
Channel `ch` defaults to 1.
"""
function inspect(ins::ZNB20, ::Type{Bandwidth}, ch::Int=1)
    parse(write(ins, "SENSe"*string(ch)*":BWIDth:RESolution?"))
end

"""
[FORMAT:BORDER](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e85486.htm)

Configure the transfer byte order: `LittleEndianTransfer`, `BigEndianTransfer`.
"""
function inspect(ins::ZNB20, ::Type{TransferByteOrder})
    TransferByteOrder(ins, ask(ins, "FORMat:BORDer?"))
end

"""
[FORMAT:DATA](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e85516.htm)

Inspect the data transfer format. The byte order should also be considered.
"""
function inspect(ins::ZNB20, ::Type{TransferFormat})
    TransferFormat(ins, ask(ins, "FORMat:DATA?"))
end

"""
[SYSTEM:DISPLAY:UPDATE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e114067.htm)

Is the display updating?
"""
function inspect(ins::ZNB20, ::Type{DisplayUpdate})
    Bool(parse(ask(ins, "SYSTem:DISPlay:UPDate?")))
end

"""
[SENSE#:SWEEP:POINTS](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/68b77d9828354b78.htm)

How many measurement points per sweep? Channel `ch` defaults to 1.
"""
function inspect(ins::ZNB20, ::Type{NumPoints}, ch::Int=1)
    parse(ask(ins, "SENSe"*string(ch)*":SWEep:POINts?"))
end

"""
[SENSE1:ROSCILLATOR:SOURCE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/4314a7accd124cd8.htm)

Inspect oscillator source: `InternalOscillator`.
"""
function inspect(ins::ZNB20, ::Type{OscillatorSource})
    OscillatorSource(ins,ask(ins, "SENSe1:ROSCillator:SOURce?"))
end

"""
[SENSE#:SWEEP:TIME](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8227ae4383e449fe.htm)

Define the time to complete a sweep, including all partial measurements.
Channel `ch` defaults to 1.
"""
function inspect(ins::ZNB20, ::Type{SweepTime}, ch::Int=1)
    parse(ask(ins, "SENSe"*string(ch)*":SWEep:TIME?"))
end

"""
[TRIGGER#:SEQUENCE:SLOPE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/cbc5449b57664ad3.htm)

Inspect the trigger slope. Channel `ch` defaults to 1.
"""
function inspect(ins::ZNB20, ::Type{TriggerSlope}, ch::Int=1)
    TriggerSlope(ins, write(ins, "TRIGger"*string(ch)*":SLOPe?"))
end

"""
[TRIGger#:SEQuence:SOURce](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/ZNB_ZNBT_WebHelp_en.htm)

Inspect the trigger source. Channel `ch` defaults to 1.
"""
function inspect(ins::ZNB20, ::Type{TriggerSource}, ch::Int=1)
    TriggerSource(ins, ask(ins, "TRIGger"*string(ch)*":SOURce?"))
end

"""
[CALCULATE#:FORMAT](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/132d40cd4d1d43c4.htm)

Inspect the format of the active trace. Channel `ch` defaults to 1.
"""
function inspect(ins::ZNB20, ::Type{VNAFormat}, ch::Int=1)
    VNAFormat(unquoted(ask(ins, "CALCulate"*string(ch)*":FORMat?")))
end

"""
Determines if a window exists, by window number. See `lswindow`.
"""
function inspect(ins::ZNB20, ::Type{Window}, win::Int)
    nums = lswindows(ins)[1]
    findfirst(nums,win) != 0
end

"""
Determines if a window exists, by window name. See `lswindow`.
"""
function inspect(ins::ZNB20, ::Type{Window}, wname::AbstractString)
    names = lswindows(ins)[2]
    findfirst(names,wname) != 0
end

## Other commands

"""
[MMEMory:CDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87010.htm)

Change directories. Pass "~" for default.
"""
function cd(ins::ZNB20, dir::AbstractString)
    if dir == "~"
        write(ins, "MMEMory:CDIRectory DEFault")
    else
        write(ins, "MMEMory:CDIRectory "*quoted(dir))
    end
end

"""
[MMEMory:COPY](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87048.htm)

Copy a file.
"""
function cp(ins::ZNB20, src::AbstractString, dest::AbstractString)
    write(ins, "MMEMory:COPY "*quoted(src)*","*quoted(dest))
end

"""
[DISPLAY:WINDOW#:TRACE#:DELETE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/35e75331f5ce4fce.htm)

Releases the assignment of window trace `wtrace` to window `win`.
"""
function hidetrace(ins::ZNB20, win::Int, wtrace::Int)
    write(ins, "DISPlay:WINDow"*string(win)*":TRACe"*string(wtrace)*":DELETE")
end

"""
[CALCULATE#:PARAMETER:CATALOG?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/2ce049f1af684d21.htm)

Report the traces assigned to a given channel.
"""
function lstrace(ins::ZNB20, ch::Int)
    res = ask(ins, "CALCulate"*string(ch)*":PARameter:CATALOG?")
end

"""
[DISPLAY:CATALOG?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/abdd1db5dc0c48ee.htm)

Report the windows and their names in a tuple: (`arrNums::Array{Int64,1}`,
    `arrNames::Array{SubString{ASCIIString},1})`).
"""
function lswindows(ins::ZNB20)
    wins = unquoted(ask(ins, "DISPlay:CATalog?"))
    arr = split(wins,",")
    arrNums = arr[1:2:end]
    arrNames = arr[2:2:end]
    arrNums = [parse(x)::Int for x in arrNums]

    (arrNums, arrNames)
end

"""
[MMEMory:MDIRectory](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e89416.htm)

Make a directory.
"""
function mkdir(ins::ZNB20, dir::AbstractString)
    write(ins, "MMEMory:MDIRectory "*quoted(dir))
end

"""
[CALCulate#:PARameter:SDEFine](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/e75d49e2a14541c5.htm)

Create a new trace with `name` and measurement `parameter` on channel `ch`,
defaulting to 1.
"""
function mktrace(ins::ZNB20, name::AbstractString, parameter, ch::Int=1)
    cmd = "CALCulate"*ch
    cmd = cmd*":PARameter:SDEFine "*quoted(name)*","*quoted(parameter)
    write(ins, cmd)
end

"""
[MMEMory:CDIRectory?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87010.htm)

Print the working directory.
"""
function pwd(ins::ZNB20)
    unquoted(ask(ins, "MMEMory:CDIRectory?"))
end

"""
[MMEMory:CATalog?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/7f7650b75a604b3d.htm)

Read the directory contents.
"""
function readdir(ins::ZNB20, dir::AbstractString="")
    cmd = "MMEMory:CATalog?"
    if dir != ""
        cmd = cmd*" "*quoted(dir)
    end
    ask(ins, cmd)
end

"""
[MMEMory:DELete](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e87202.htm)

Remove a file.
"""
function rm(ins::ZNB20, file::AbstractString)
    write(ins, "MMEMory:DELete "*quoted(dir))
end


"""
[CALCULATE#:PARAMETER:DELETE](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/0763f74d0a2d4d61.htm)

Remove trace with name `name` from channel `ch`, defaulting to 1.
"""
function rmtrace(ins::ZNB20, name::AbstractString, ch::Int=1)
    write(ins, "CALCulate"*string(ch)*":PARameter:DELete "*quoted(name))
end

"""
[CALCulate#:PARameter:DELete:CALL](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/8d937272d97244fb.htm)

Deletes all traces in the given channel `ch`, defaulting to 1.
"""
function rmtrace(ins::ZNB20, ch::Int=1)
    write(ins, "CALCulate"*string(ch)*":PARameter:DELete:CALL")
end

# """
# [CALCulate:PARameter:DELete:ALL](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/d36e69977.htm)
#
# Deletes all traces in all channels.
# """
# function rmtrace(ins::ZNB20)
#     write(ins, "CALCulate:PARameter:DELete:ALL")
# end

"""
[DISPLAY:WINDOW#:TRACE#:FEED](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/58dad852e7db48a0.htm)

Show a trace named `name` in window `win::Int` as
window trace number `wtrace::Int`.
"""
function showtrace(ins::ZNB20, name::AbstractString, win::Int, wtrace::Int)
    write(ins, "DISPlay:WINDow"*string(win)*
        ":TRACe"*string(wtrace)*":FEED "*quoted(name))
end

"""
[CALCulate#:DATA:STIMulus?](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/038ef1cf7a044e85.htm)

Read the stimulus values of the active data or memory trace.
"""
function stimdata(ins::ZNB20, ch::Int=1)
    xfer = inspect(ins, TransferFormat)
    _getdata(ins, xfer, "CALCulate"*string(ch)*":DATA:STIMulus?")
end


"""
[CALCULATE#:DATA](https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_5/Content/a9ce754f8a7c483a.htm)

Retrieve data from the active trace or memory trace.
Pass the desired format as a string, e.g. "fdat" for
formatted trace data. See the link above for details.

Channel `ch` defaults to 1.
"""
function data(ins::ZNB20, ch::Int=1; format=:fdat)

    xfer = inspect(ins, TransferFormat)
    array = _getdata(ins, xfer, "CALCulate"*string(ch)*":DATA? "*string(format))
    _reformat(array, Val{format})
end

function _reformat{T}(x, ::Type{Val{T}})
    x
end

function _reformat{T}(x::Array{T,1}, ::Type{Val{:sdat}})
    [Complex{T}(x[i],x[i+1]) for i in 1:2:length(x)]
end

function _reformat{T}(x::Array{T,1}, ::Type{Val{:mdat}})
    [Complex{T}(x[i],x[i+1]) for i in 1:2:length(x)]
end

"Retreive and parse a comma delimited string into an `Array{Float64,1}`."
function _getdata(ins::ZNB20, ::Type{TransferFormat{ASCIIString}}, cmd)
    data = ask(ins, cmd)
    [parse(x)::Float64 for x in split(data,",")]
end

"Parse a binary block, taking care of float size and byte ordering."
function _getdata{T<:Union{Float32,Float64}}(ins::ZNB20,
        ::Type{TransferFormat{T}}, cmd)

    write(ins, cmd)
    io = binblockreadavailable(ins)

    endian = inspect(ins, TransferByteOrder)
    _conv = (endian == LittleEndianTransfer ? ltoh : ntoh)

    bytes = sizeof(T)
    nsam = Int(floor((io.size-(io.ptr-1))/bytes))

    array = Vector{T}(nsam)
    for i=1:nsam
        array[i] = (_conv)(read(io, T))
    end

    array
end


end
