### Keysight / Agilent E5071C
type E5071C <: InstrumentVISA
	vi::PyObject 	# this is the GpibInstrument object!
	E5071C(x) = new(x)
	E5071C() = new()
end

responseDictionary = Dict(

	:InstrumentNetwork						=> Dict("DHCP" => :DHCP,
																				"MAN"	 => :ManualNetwork),

	:InstrumentBoolean 						=> Dict( 1		=> :Yes,
																   			 0		=> :No),

	:InstrumentTriggerSource			=> Dict("INT"	=> :InternalTrigger,
																				"EXT"	=> :ExternalTrigger,
																				"MAN"	=> :ManualTrigger,
																				"BUS"	=> :BusTrigger),

	:InstrumentTiming							=> Dict("BEF" => :Before,
																				"AFT" => :After),

	:InstrumentTriggerSlope				=> Dict("POS"	=> :RisingTrigger,
																				"NEG"	=> :FallingTrigger),

	:InstrumentPolarity						=> Dict("POS" => :PositivePolarity,
																				"NEG" => :NegativePolarity),

	:InstrumentSearch							=> Dict("MAX"  => :Max,
																				"MIN"  => :Min,
																				"PEAK" => :Peak,
																				"LPE"	 => :LeftPeak,
																				"RPE"  => :RightPeak,
																				"TARG" => :Target,
																				"LTAR" => :LeftTarget,
																				"RTAR" => :RightTarget),

	:InstrumentSParameter					=> Dict("S11" 	=> :S11,
																				"S12" 	=> :S12,
																				"S21" 	=> :S21,
																				"S22" 	=> :S22),

	:InstrumentMedium							=> Dict("COAX" 	=> :Coaxial,
																				"WAV" 	=> :Waveguide),

	:InstrumentDataRepresentation => Dict("MLOG"	=> :LogMagnitude,
																				"PHAS"	=> :Phase,
																				"GDEL"  => :GroupDelay,
																				"SLIN"	=> :SmithLinear,
																				"SLOG"  => :SmithLog,
																				"SCOM"	=> :SmithComplex,
																				"SMIT"	=> :Smith,
																				"SADM"	=> :SmithAdmittance,
																				"PLIN"	=> :PolarLinear,
																				"PLOG"	=> :PolarLog,
																				"POL"		=> :PolarComplex,
																				"MLIN"	=> :LinearMagnitude,
																				"SWR"		=> :SWR,
																				"REAL"	=> :RealPart,
																				"IMAG"	=> :ImaginaryPart,
																				"UPH"		=> :ExpandedPhase,
																				"PPH"		=> :PositivePhase)
)

generateResponseHandlers(E5071C, responseDictionary)

sfd = Dict(
	"electricalDelay"					=> [":CALC#:TRAC#:CORR:EDEL:TIME",	InstrumentFloat],		#1-160, 1-16
	"electricalMedium"				=> [":CALC#:TRAC#:CORR:EDEL:MED",		InstrumentMedium],	#...
	"waveguideCutoffFrequency"=> [":CALC#:TRAC#:CORR:EDEL:WGC",		InstrumentFloat],
	"phaseOffset"							=> [":CALC#:TRAC#:CORR:OFFS:PHAS",	InstrumentFloat],
	"formattedData"						=> [":CALC#:TRAC#:DATA:FDAT",				InstrumentASCIIString],
	"frequencyData"						=> [":CALC#:TRAC#:DATA:XAX?",				InstrumentASCIIString],
	"dataFormat"							=> [":CALC#:TRAC#:FORM",						InstrumentDataRepresentation],
	"numberOfTraces"					=> [":CALC#:PAR:COUN",							InstrumentInt],		#1-160, arg: 1-9
	"smoothingAperture"				=> [":CALC#:SMO:APER",							InstrumentFloat],
	"smoothingOn"							=> [":CALC1:SMO:STAT",							InstrumentBoolean],
	"markerOn"								=> [":CALC#:MARK#",									InstrumentBoolean],
	"setActiveMarker"					=> [":CALC#:MARK#:ACT",							InstrumentNoArgs],
	"markerX"									=> [":CALC#:MARK#:X",								InstrumentFloat],
	"markerY"									=> [":CALC#:MARK#:Y?",							InstrumentFloat],		#:CALC{1-160}:MARK{1-9}:DATA
	"markerSearch"						=> [":CALC#:MARK#:FUNC:EXEC",				InstrumentNoArgs],
	#:CALC{1-160}:MARK{1-10}:SET
	"setActiveTrace"					=> [":CALC#:PAR#:SEL",							InstrumentNoArgs],
	"measurementParameter"		=> [":CALC#:PAR#:DEF", 							InstrumentSParameter],
	"frequencyDisplayed"			=> [":DISP:ANN:FREQ",								InstrumentBoolean],
	"displayEnabled"					=> [":DISP:ENAB",										InstrumentBoolean],
	"setActiveChannel"				=> [":DISP:WIND#:ACT",							InstrumentNoArgs],
	"channelMaximized"				=> [":DISP:MAX",										InstrumentBoolean],
	"windowLayout"						=> [":DISP:SPL",										InstrumentASCIIString],
	"traceMaximized"					=> [":DISP:WIND#:MAX",							InstrumentBoolean], #1-160
	"graphLayout"							=> [":DISP:WIND#:SPL",							InstrumentASCIIString], #1-36 (why?)
	"autoscale"								=> [":DISP:WIND#:TRAC#:Y:AUTO",			InstrumentNoArgs],  #1-160, 1-16
	"yScalePerDivision"				=> [":DISP:WIND#:TRAC#:Y:PDIV",			InstrumentFloat],
	"yReferenceLevel"					=> [":DISP:WIND#:TRAC#:Y:RLEV",			InstrumentFloat],
	"yReferencePosition"			=> [":DISP:WIND#:TRAC#:Y:RPOS",			InstrumentInt],
	"dataTraceOn"							=> [":DISP:WIND#:TRAC#:STAT",				InstrumentBoolean],
	"yDivisions"							=> [":DISP:WIND#:Y:DIV",						InstrumentInt],
	"clearAveraging"					=> [":SENS#:AVER:CLE",							InstrumentNoArgs],	#1-160
	"averagingFactor"					=> [":SENS#:AVER:COUN",							InstrumentInt],			#1-160
	"averagingOn"							=> [":SENS#:AVER",									InstrumentBoolean],
	"IFBandwidth"							=> [":SENS1:BAND",									InstrumentFloat],
	"powerSweepFrequency"			=> [":SENS#:FREQ",									InstrumentFloat],
	"startFrequency"					=> [":SENS#:FREQ:STAR",							InstrumentFloat],
	"stopFrequency"						=> [":SENS#:FREQ:STOP",							InstrumentFloat],
	"centerFrequency"					=> [":SENS#:FREQ:CENT",							InstrumentFloat],
	"spanFrequency"						=> [":SENS#:FREQ:SPAN",							InstrumentFloat],
	"powerLevel"							=> [":SOUR#:POW",										InstrumentFloat],	# 1-160
	"powerCoupled"						=> [":SOUR#:POW:PORT:COUP",					InstrumentBoolean],
	"portPower"								=> [":SOUR#:POW:PORT#",							InstrumentFloat],
	"powerSlopeLevel"					=> [":SOUR#:POW:SLOP",							InstrumentFloat],	#dB/GHz
	"powerSlopeOn"						=> [":SOUR#:POW:SLOP:STAT",					InstrumentBoolean],
	"averagingTriggerOn"			=> [":TRIG:AVER",										InstrumentBoolean],
	"externalTriggerSlope"		=> [":TRIG:SEQ:EXT:SLOP",						InstrumentTriggerSlope],
	"externalTriggerDelay"		=> [":TRIG:EXT:DEL",								InstrumentFloat],
	"externalTriggerLowLatencyOn" => [":TRIG:EXT:LLAT",						InstrumentBoolean],
	"triggerOutputOn"					=> [":TRIG:OUTP:STAT",							InstrumentBoolean],
	"triggerOutputPolarity"		=> [":TRIG:OUTP:POL",								InstrumentPolarity],
	"triggerOutputTiming"			=> [":TRIG:OUTP:POS",								InstrumentTiming],
	"pointTriggerOn"					=> [":TRIG:POIN",										InstrumentBoolean],
	"triggerSource"						=> [":TRIG:SOUR",										InstrumentTriggerSource],
	"powerOn"									=> [":OUTP",												InstrumentBoolean],
)

for (fnName in keys(sfd))
		createStateFunction(E5071C,fnName,sfd[fnName][1],sfd[fnName][2])
end
