### Keysight / Agilent E8257D
module E8257DModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
include("../Metaprogramming.jl")

export E8257D

export E8257DStimulus
export E8257DPowerStimulus, E8257DFrequencyStimulus, source

export flatnesscorrectionfile_load, flatnesscorrectionfile_save
export boards, cumulativeattenuatorswitches, cumulativepowerons, cumulativeontime
export options, options_verbose, revision

type E8257D <: InstrumentVISA
    vi::(VISA.ViSession)
    writeTerminator::ASCIIString
    model::AbstractString
    E8257D(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        ins.model = "E8257D"
        VISA.viSetAttribute(ins.vi, VISA.VI_ATTR_TERMCHAR_EN, UInt64(1))
        ins
    end

    E8257D() = new()
end

abstract E8257DStimulus <: Stimulus

type E8257DPowerStimulus <: E8257DStimulus
    ins::E8257D
#   label::Label
    val::AbstractFloat
end

type E8257DFrequencyStimulus <: E8257DStimulus
    ins::E8257D
#   label::Label
    val::AbstractFloat
end

function source(ch::E8257DPowerStimulus, val::Real)
    ch.val = val
    setPower(ch.ins,val)
end

function source(ch::E8257DFrequencyStimulus, val::Real)
    ch.val = val
    setFrequency(ch.ins,val)
end

responses = Dict(

    :Network              => Dict("DHCP" => :DHCP,
                                  "MAN"  => :ManualNetwork),

    :TriggerSource        => Dict("IMM"  => :InternalTrigger,
                                  "EXT"  => :ExternalTrigger,
                                  "KEY"  => :ManualTrigger,
                                  "BUS"  => :BusTrigger),

    :OscillatorSource     => Dict("INT"  => :InternalOscillator,
                                  "EXT"  => :ExternalOscillator)
)

generateResponseHandlers(E8257D, responses)

sfd = Dict(
    "screenshot"                 => ["DISP:CAPT",                           NoArgs],
    "flatnesscorrection_points"  => ["SOURce:CORRection:FLATness:POINts?",  Int],
    "flatnesscorrection_factory" => ["SOURce:CORRection:FLATness:PRESet",   NoArgs],
    "flatnesscorrection_on"      => ["SOURce:CORRection:STATe",             Bool],
    "frequency_band_on"          => ["SOURce:FREQuency:CHANnels:STATe",     Bool],
    "frequency"                  => ["SOURce:FREQuency:FIXed",              AbstractFloat],            # units?
    "frequency_stepup"           => ["SOURce:FREQuency:FIXed UP",           NoArgs],
    "frequency_stepdown"         => ["SOURce:FREQuency:FIXed DOWN",         NoArgs],
    "frequency_multiplier"       => ["SOURce:FREQuency:MULTiplier",         Int],
    "frequency_offset_on"        => ["SOURce:FREQuency:OFFSet:STATe",       Bool],
    "frequency_offset"           => ["SOURce:FREQuency:OFFSet",             AbstractFloat],
    "frequency_reference"        => ["SOURce:FREQuency:REFerence",          AbstractFloat],
    "set_frequency_reference"    => ["SOURce:FREQuency:REFerence:SET",      NoArgs],
    "frequency_reference_on"     => ["SOURce:FREQuency:REFerence:STATe",    Bool],
    "frequency_start"            => ["SOURce:FREQuency:STARt",              AbstractFloat],
    "frequency_stop"             => ["SOURce:FREQuency:STOP",               AbstractFloat],
    "frequency_step"             => ["SOURce:FREQuency:STEP",               AbstractFloat],
    "phase"                      => ["SOURce:PHASe:ADJust",                 AbstractFloat],            #radians?
    "set_phase_reference"        => ["SOURce:PHASe:REFerence",              NoArgs],
    "referenceoscillator_source" => ["SOURce:ROSCillator:SOURce?",          OscillatorSource],
    "output_blanking_auto"       => ["SOURce:OUTPut:BLANking:AUTO",         Bool],
    "output_blanking_on"         => ["SOURce:OUTPut:BLANking:STATe",        Bool],
    "output_settled"             => [":OUTPut:SETTled?",                    NoArgs],
    "output_on"                  => [":OUTPut",                             Bool],
    "alc_bandwidth"              => ["SOURce:POWer:ALC:BANDwidth",          AbstractFloat],
    "alc_bandwidth_auto"         => ["SOURce:POWer:ALC:BANDwidth:AUTO",     Bool],
    "alc_level"                  => ["SOURce:POWer:ALC:LEVel",              AbstractFloat],            # step attenuator
    "alc_powersearch_reflevel"   => ["SOURce:POWer:ALC:SEARch:REF:LEVel",   AbstractFloat],
    "alc_powersearch_start"      => ["SOURce:POWer:ALC:SEARch:SPAN:START",  AbstractFloat],            # may want units?
    "alc_powersearch_stop"       => ["SOURce:POWer:ALC:SEARch:SPAN:STOP",   AbstractFloat],            # may want units?
    "alc_powersearch_spanon"     => ["SOURce:POWer:ALC:SEARch:SPAN:STATe",  Bool],
    "alc_on"                     => ["SOURce:POWer:ALC:STATe",              Bool],
    "trigger_sweep"              => ["SOURce:TSWeep",                       NoArgs],
    "power_attenuator_level"     => ["SOURce:POWer:ATTenuation",            AbstractFloat],            # step attenuator    # may want units?
    "power_attenuator_auto"      => ["SOURce:POWer:ATTenuation:AUTO",       Bool],        # step attenuator # docstring
    "power_optimize_snr_on"      => ["SOURce:POWer:NOISe:STATe",            Bool],
    "power_limit_adjustable"     => ["SOURce:POWer:LIMit:MAX:ADJust",       Bool],
    "power_limit"                => ["SOURce:POWer:LIMit:MAX",              AbstractFloat],            # units?
    "power_searchprotection"     => ["SOURce:POWer:PROTection:STATe",       Bool],
    "power_reference"            => ["SOURce:POWer:REFerence",              AbstractFloat],            # units?
    "power_reference_on"         => ["SOURce:POWer:REFerence:STATe",        Bool],
    "power_start"                => ["SOURce:POWer:STARt",                  AbstractFloat],            # units?
    "power_stop"                 => ["SOURce:POWer:STOP",                   AbstractFloat],            # units?
    "power_offset"               => ["SOURce:POWer:LEVel:OFFSet",           AbstractFloat],            # units?
    "power"                      => ["SOURce:POWer",                        AbstractFloat],            # units?
    "power_step"                 => ["SOURce:POWer:LEVel:STEP",             AbstractFloat],            # units?

    "lan_configuration"          => ["SYST:COMM:LAN:CONF",                  Network],    # IMPLEMENT ERROR HANDLING
    "lan_hostname"               => ["SYSTem:COMMunicate:LAN:HOSTname",     ASCIIString],
    "lan_ip"                     => ["SYSTem:COMMunicate:LAN:IP",           ASCIIString],
    "lan_subnet"                 => ["SYSTem:COMMunicate:LAN:SUBNet",       ASCIIString],
    "trigger_outputpolarity"     => ["TRIG:OUTP:POL",                       Polarity],
    "trigger_source"             => ["TRIG:SOUR",                           TriggerSource]
)

for (fnName in keys(sfd))
    createStateFunction(E8257D,fnName,sfd[fnName][1],sfd[fnName][2])
end

flatnesscorrectionfile_load(ins::E8257D, file::ASCIIString) =
    write(ins, "SOURce:CORRection:FLATness:LOAD \""*file*"\"")

flatnesscorrectionfile_save(ins::E8257D, file::ASCIIString) =
    write(ins, "SOURce:CORRection:FLATness:STORe \""*file*"\"")

boards(ins::E8257D)                       = ask(ins,"DIAGnostic:INFOrmation:BOARds?")
cumulativeattenuatorswitches(ins::E8257D) = ask(ins,"DIAGnostic:INFOrmation:CCOunt:ATTenuator?")
cumulativepowerons(ins::E8257D)           = ask(ins,"DIAGnostic:INFOrmation:CCOunt:PON?")
cumulativeontime(ins::E8257D)             = ask(ins,"DIAGnostic:INFOrmation:OTIMe?")
options(ins::E8257D)                      = ask(ins,"DIAGnostic:INFOrmation:OPTions?")
options_verbose(ins::E8257D)               = ask(ins,"DIAGnostic:INFOrmation:OPTions:DETail?")
revision(ins::E8257D)                     = ask(ins,"DIAGnostic:INFOrmation:REVision?")

end
