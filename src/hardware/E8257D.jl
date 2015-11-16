export E8257D
type E8257D <: InstrumentVISA
	vi::PyObject 	# this is the GpibInstrument object!
	E8257D(x) = new(x)
	E8257D() = new()
end

export E8257DOutput
abstract E8257DOutput <: Output

export E8257DPowerOutput
type E8257DPowerOutput <: E8257DOutput
	ins::E8257D
#	label::Label
	val::Float64
end

export E8257DFrequencyOutput
type E8257DFrequencyOutput <: E8257DOutput
	ins::E8257D
#	label::Label
	val::Float64
end

export source
function source(ch::E8257DPowerOutput, val::Real)
	ch.val = val
	setPower(ch.ins,val)
end

function source(ch::E8257DFrequencyOutput, val::Real)
	ch.val = val
	setFrequency(ch.ins,val)
end

subtypeStateDictionary = Dict(

	:InstrumentNetwork			 			=> Dict("DHCP" => :DHCP,
																				"MAN"	=> :ManualNetwork),

	:InstrumentBoolean						=> Dict(1 => :Yes,
																				0 => :No),

	:InstrumentTriggerSource			=> Dict("IMM"	=> :InternalTrigger,
																				"EXT" => :ExternalTrigger,
																				"KEY" => :ManualTrigger,
																				"BUS"	=> :BusTrigger),

	:InstrumentOscillatorSource		=> Dict("INT"		=> :InternalOscillator,
																				"EXT"		=> :ExternalOscillator)
)

generateResponseHandlers(E8257D, responseDictionary)

sfd = Dict(
	"screenshot"								=> ["DISP:CAPT",													InstrumentNoArgs],
	"numFlatnessCorrectionPts"	=> ["SOURce:CORRection:FLATness:POINts?",	InstrumentInt],
	"factoryFlatnessCorrection" => ["SOURce:CORRection:FLATness:PRESet",  InstrumentNoArgs],
	"flatnessCorrectionOn"			=> ["SOURce:CORRection:STATe",						InstrumentBoolean],
	"frequencyBandOn"						=> ["SOURce:FREQuency:CHANnels:STATe",		InstrumentBoolean],
	"frequency"									=> ["SOURce:FREQuency:FIXed",							InstrumentFloat],			# units?
	"stepFrequencyUp"						=> ["SOURce:FREQuency:FIXed UP",					InstrumentNoArgs],
	"stepFrequencyDown"					=> ["SOURce:FREQuency:FIXed DOWN",				InstrumentNoArgs],
	"frequencyMultiplier"				=> ["SOURce:FREQuency:MULTiplier",				InstrumentInt],
	"frequencyOffsetOn"					=> ["SOURce:FREQuency:OFFSet:STATe",			InstrumentBoolean],
	"frequencyOffset"						=> ["SOURce:FREQuency:OFFSet",						InstrumentFloat],
	"frequencyReference"				=> ["SOURce:FREQuency:REFerence",					InstrumentFloat],
	"setFrequencyReference"			=> ["SOURce:FREQuency:REFerence:SET",			InstrumentNoArgs],
	"frequencyReferenceOn"			=> ["SOURce:FREQuency:REFerence:STATe",		InstrumentBoolean],
	"startFrequency"						=> ["SOURce:FREQuency:STARt",							InstrumentFloat],
	"stopFrequency"							=> ["SOURce:FREQuency:STOP",							InstrumentFloat],
	"frequencyIncrement"				=> ["SOURce:FREQuency:STEP",							InstrumentFloat],
	"phase"											=> ["SOURce:PHASe:ADJust",								InstrumentFloat],			#radians?
	"setPhaseReference"					=> ["SOURce:PHASe:REFerence",							InstrumentNoArgs],
	"referenceOscillatorSource"	=> ["SOURce:ROSCillator:SOURce?",					InstrumentOscillatorSource],
	"autoBlanking"							=> ["SOURce:OUTPut:BLANking:AUTO",				InstrumentBoolean],
	"blankingOn"								=> ["SOURce:OUTPut:BLANking:STATe",				InstrumentBoolean],
	"outputSettled"							=> [":OUTPut:SETTled?",										InstrumentNoArgs],
	"powerOn"										=> [":OUTPut",														InstrumentBoolean],
	"alcBandwidth"							=> ["SOURce:POWer:ALC:BANDwidth",					InstrumentFloat],
	"alcAutoBandwidth"					=> ["SOURce:POWer:ALC:BANDwidth:AUTO",		InstrumentBoolean],
	"alcLevel"									=> ["SOURce:POWer:ALC:LEVel",							InstrumentFloat],			# step attenuator
	"alcPowerSearchRefLevel"  	=> ["SOURce:POWer:ALC:SEARch:REF:LEVel",	InstrumentFloat],
	"alcPowerSearchStart"				=> ["SOURce:POWer:ALC:SEARch:SPAN:START",	InstrumentFloat],			# may want units?
	"alcPowerSearchStop"				=> ["SOURce:POWer:ALC:SEARch:SPAN:STOP",	InstrumentFloat],			# may want units?
	"alcPowerSearchSpanOn"			=> ["SOURce:POWer:ALC:SEARch:SPAN:STATe", InstrumentBoolean],
	"alcOn"											=> ["SOURce:POWer:ALC:STATe", 						InstrumentBoolean],
	"triggerSweep"							=> ["SOURce:TSWeep",											InstrumentNoArgs],
	"attenuation"								=> ["SOURce:POWer:ATTenuation",						InstrumentFloat],			# step attenuator	# may want units?
	"autoAttenuator"						=> ["SOURce:POWer:ATTenuation:AUTO",			InstrumentBoolean],		# step attenuator # docstring
	"autoOptimizeSNROn"					=> ["SOURce:POWer:NOISe:STATe",						InstrumentBoolean],
	"outputPowerLimitAdjust"		=> ["SOURce:POWer:LIMit:MAX:ADJust",			InstrumentBoolean],
	"outputPowerLimit"					=> ["SOURce:POWer:LIMit:MAX",							InstrumentFloat],			# units?
	"powerSearchProtection"			=> ["SOURce:POWer:PROTection:STATe",			InstrumentBoolean],
	"powerOutputReference"			=> ["SOURce:POWer:REFerence",							InstrumentFloat],			# units?
	"powerOutputReferenceOn"		=> ["SOURce:POWer:REFerence:STATe",				InstrumentBoolean],
	"startPower"								=> ["SOURce:POWer:STARt",									InstrumentFloat],			# units?
	"stopPower"									=> ["SOURce:POWer:STOP",									InstrumentFloat],			# units?
	"powerOffset"								=> ["SOURce:POWer:LEVel:OFFSet",					InstrumentFloat],			# units?
	"power"											=> ["SOURce:POWer",												InstrumentFloat],			# units?
	"powerIncrement"						=> ["SOURce:POWer:LEVel:STEP",						InstrumentFloat],			# units?

	"lanConfiguration" 					=> ["SYST:COMM:LAN:CONF", 								InstrumentNetwork],	# IMPLEMENT ERROR HANDLING
	"lanHostname" 							=> ["SYSTem:COMMunicate:LAN:HOSTname",	 	InstrumentString],
	"lanIP" 										=> ["SYSTem:COMMunicate:LAN:IP", 					InstrumentString],
	"lanSubnet" 								=> ["SYSTem:COMMunicate:LAN:SUBNet", 			InstrumentString],
#	"systemDate" 								=> ["SYST:DATE", 													InstrumentInt],
#	"systemTime" 								=> ["SYST:TIME", 													InstrumentInt],
	"triggerOutputPolarity"			=> ["TRIG:OUTP:POL", 											InstrumentPolarity],
	"triggerSource"							=> ["TRIG:SOUR", 													InstrumentTriggerSource]
)

for (fnName in keys(sfd))
		createStateFunction(E8257D,fnName,sfd[fnName][1],sfd[fnName][2])
end

setSystemDate(ins,insDateTime::InstrumentDateTime) = setSystemDate(ins,Dates.year(insDateTime.dateTime),
																																			 Dates.month(insDateTime.dateTime),
																																			 Dates.day(insDateTime.dateTime))
setSystemTime(ins,insDateTime::InstrumentDateTime) = setSystemTime(ins,Dates.hour(insDateTime.dateTime),
																																			 Dates.minute(insDateTime.dateTime),
																																			 Dates.second(insDateTime.dateTime))

export loadFlatnessCorrectionFile
function loadFlatnessCorrectionFile(ins::E8257D, file::ASCIIString)
	write(ins, "SOURce:CORRection:FLATness:LOAD \""*file*"\"")
end

export saveFlatnessCorrectionFile
function saveFlatnessCorrectionFile(ins::E8257D, file::ASCIIString)
	write(ins, "SOURce:CORRection:FLATness:STORe \""*file*"\"")
end

export boards, cumulativeAttenuatorSwitches, cumulativePowerOns, cumulativeOnTime
export options, optionsVerbose, revision
boards(ins::E8257D) 											= query(ins,"DIAGnostic:INFOrmation:BOARds?")
cumulativeAttenuatorSwitches(ins::E8257D) = query(ins,"DIAGnostic:INFOrmation:CCOunt:ATTenuator?")
cumulativePowerOns(ins::E8257D) 					= query(ins,"DIAGnostic:INFOrmation:CCOunt:PON?")
cumulativeOnTime(ins::E8257D) 						= query(ins,"DIAGnostic:INFOrmation:OTIMe?")
options(ins::E8257D) 											= query(ins,"DIAGnostic:INFOrmation:OPTions?")
optionsVerbose(ins::E8257D) 							= query(ins,"DIAGnostic:INFOrmation:OPTions:DETail?")
revision(ins::E8257D)											= query(ins,"DIAGnostic:INFOrmation:REVision?")
