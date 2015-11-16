### Keysight / Agilent E5071C
type E5071C <: InstrumentVISA
	vi::PyObject 	# this is the GpibInstrument object!
	E5071C(x) = new(x)
	E5071C() = new()
end

responseDictionary = Dict(

	:InstrumentNetwork					=> Dict("DHCP" => :DHCP,
												"MAN"  => :ManualNetwork),

	:InstrumentTriggerSource			=> Dict("INT"  => :InternalTrigger,
												"EXT"  => :ExternalTrigger,
												"MAN"  => :ManualTrigger,
												"BUS"  => :BusTrigger),

	:InstrumentTiming					=> Dict("BEF"  => :Before,
												"AFT"  => :After),

	:InstrumentTriggerSlope				=> Dict("POS"  => :RisingTrigger,
												"NEG"  => :FallingTrigger),

	:InstrumentPolarity					=> Dict("POS"  => :PositivePolarity,
												"NEG"  => :NegativePolarity),

    :InstrumentSearch				    => Dict("MAX"  => :Max,
												"MIN"  => :Min,
												"PEAK" => :Peak,
												"LPE"  => :LeftPeak,
												"RPE"  => :RightPeak,
												"TARG" => :Target,
												"LTAR" => :LeftTarget,
												"RTAR" => :RightTarget),

	:InstrumentSParameter				=> Dict("S11"  => :S11,
												"S12"  => :S12,
												"S21"  => :S21,
												"S22"  => :S22),

	:InstrumentMedium					=> Dict("COAX" => :Coaxial,
												"WAV"  => :Waveguide),

	:InstrumentDataRepresentation       => Dict("MLOG" => :LogMagnitude,
    											"PHAS" => :Phase,
    											"GDEL" => :GroupDelay,
    											"SLIN" => :SmithLinear,
    											"SLOG" => :SmithLog,
    											"SCOM" => :SmithComplex,
    											"SMIT" => :Smith,
    											"SADM" => :SmithAdmittance,
    											"PLIN" => :PolarLinear,
    											"PLOG" => :PolarLog,
    											"POL"  => :PolarComplex,
    											"MLIN" => :LinearMagnitude,
    											"SWR"  => :SWR,
    											"REAL" => :RealPart,
    											"IMAG" => :ImaginaryPart,
    											"UPH"  => :ExpandedPhase,
    											"PPH"  => :PositivePhase)
)

generateResponseHandlers(E5071C, responseDictionary)

sfd = Dict(
	"electricalDelay"              => [":CALC#:TRAC#:CORR:EDEL:TIME",	Float64],		#1-160, 1-16
	"electricalMedium"             => [":CALC#:TRAC#:CORR:EDEL:MED",	InstrumentMedium],	#...
	"waveguideCutoffFrequency"     => [":CALC#:TRAC#:CORR:EDEL:WGC",	Float64],
	"phaseOffset"                  => [":CALC#:TRAC#:CORR:OFFS:PHAS",	Float64],
	"formattedData"                => [":CALC#:TRAC#:DATA:FDAT",		ASCIIString],
	"frequencyData"                => [":CALC#:TRAC#:DATA:XAX?",		ASCIIString],
	"dataFormat"                   => [":CALC#:TRAC#:FORM",				InstrumentDataRepresentation],
	"numberOfTraces"               => [":CALC#:PAR:COUN",				Int64],		#1-160, arg: 1-9
	"smoothingAperture"            => [":CALC#:SMO:APER",				Float64],
	"smoothingOn"                  => [":CALC1:SMO:STAT",				Bool],
	"markerOn"                     => [":CALC#:MARK#",					Bool],
	"setActiveMarker"              => [":CALC#:MARK#:ACT",				InstrumentNoArgs],
	"markerX"                      => [":CALC#:MARK#:X",				Float64],
	"markerY"                      => [":CALC#:MARK#:Y?",				Float64],		#:CALC{1-160}:MARK{1-9}:DATA
	"markerSearch"                 => [":CALC#:MARK#:FUNC:EXEC",		InstrumentNoArgs],
	#:CALC{1-160}:MARK{1-10}:SET
	"setActiveTrace"               => [":CALC#:PAR#:SEL",				InstrumentNoArgs],
	"measurementParameter"         => [":CALC#:PAR#:DEF", 				InstrumentSParameter],
	"frequencyDisplayed"           => [":DISP:ANN:FREQ",				Bool],
	"displayEnabled"               => [":DISP:ENAB",					Bool],
	"setActiveChannel"             => [":DISP:WIND#:ACT",				InstrumentNoArgs],
	"channelMaximized"             => [":DISP:MAX",						Bool],
	"windowLayout"                 => [":DISP:SPL",						ASCIIString],
	"traceMaximized"               => [":DISP:WIND#:MAX",				Bool], #1-160
	"graphLayout"                  => [":DISP:WIND#:SPL",				ASCIIString], #1-36 (why?)
	"autoscale"                    => [":DISP:WIND#:TRAC#:Y:AUTO",		InstrumentNoArgs],  #1-160, 1-16
	"yScalePerDivision"            => [":DISP:WIND#:TRAC#:Y:PDIV",		Float64],
	"yReferenceLevel"              => [":DISP:WIND#:TRAC#:Y:RLEV",		Float64],
	"yReferencePosition"           => [":DISP:WIND#:TRAC#:Y:RPOS",		Int64],
	"dataTraceOn"                  => [":DISP:WIND#:TRAC#:STAT",        Bool],
	"yDivisions"                   => [":DISP:WIND#:Y:DIV",				Int64],
	"clearAveraging"               => [":SENS#:AVER:CLE",				InstrumentNoArgs],	#1-160
	"averagingFactor"              => [":SENS#:AVER:COUN",				Int64],			#1-160
	"averagingOn"                  => [":SENS#:AVER",					Bool],
	"IFBandwidth"                  => [":SENS1:BAND",					Float64],
	"powerSweepFrequency"          => [":SENS#:FREQ",					Float64],
	"startFrequency"               => [":SENS#:FREQ:STAR",				Float64],
	"stopFrequency"                => [":SENS#:FREQ:STOP",				Float64],
	"centerFrequency"              => [":SENS#:FREQ:CENT",				Float64],
	"spanFrequency"                => [":SENS#:FREQ:SPAN",				Float64],
	"powerLevel"                   => [":SOUR#:POW",					Float64],	# 1-160
	"powerCoupled"                 => [":SOUR#:POW:PORT:COUP",			Bool],
	"portPower"                    => [":SOUR#:POW:PORT#",				Float64],
	"powerSlopeLevel"              => [":SOUR#:POW:SLOP",				Float64],	#dB/GHz
	"powerSlopeOn"                 => [":SOUR#:POW:SLOP:STAT",			Bool],
	"averagingTriggerOn"           => [":TRIG:AVER",					Bool],
	"externalTriggerSlope"         => [":TRIG:SEQ:EXT:SLOP",			InstrumentTriggerSlope],
	"externalTriggerDelay"         => [":TRIG:EXT:DEL",					Float64],
	"externalTriggerLowLatencyOn"  => [":TRIG:EXT:LLAT",				Bool],
	"triggerOutputOn"              => [":TRIG:OUTP:STAT",				Bool],
	"triggerOutputPolarity"        => [":TRIG:OUTP:POL",				InstrumentPolarity],
	"triggerOutputTiming"          => [":TRIG:OUTP:POS",				InstrumentTiming],
	"pointTriggerOn"               => [":TRIG:POIN",					Bool],
	"triggerSource"                => [":TRIG:SOUR",					InstrumentTriggerSource],
	"powerOn"                      => [":OUTP",							Bool],
)

for (fnName in keys(sfd))
		createStateFunction(E5071C,fnName,sfd[fnName][1],sfd[fnName][2])
end
