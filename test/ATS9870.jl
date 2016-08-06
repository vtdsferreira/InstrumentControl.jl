using Base.Test

info("Tests are starting.")
info("Tests assume a 10 MHz reference clock is connected to ECLK.")
# Acquisition channel selection
ats[AlazarChannel] = :ChannelA
@test ats[AlazarChannel] == :ChannelA
ats[AlazarChannel] = :ChannelB
@test ats[AlazarChannel] == :ChannelB
ats[AlazarChannel] = :BothChannels
@test ats[AlazarChannel] == :BothChannels

@test ats[SampleMemoryPerChannel] /1024/1024 == 256 #MB
@test dsp_num_modules(ats) == 0

# Test trigger engine
for a in (:J, :K, :JOrK, :JAndK, :JXorK, :JAndNotK, :NotJAndK)
    ats[TriggerEngine] = a
    @test ats[TriggerEngine] == a
end

slopes = (:Rising, :Falling)
for a in slopes, b in slopes
    ats[TriggerSlope] = a,b
    @test ats[TriggerSlope] == (a,b)
end

sources = (:ChannelA, :ChannelB, :External, :Disabled)
for a in sources, b in sources
    ats[TriggerSource] = a,b
    @test ats[TriggerSource] == (a,b)
end

# Test valid internal sample rates
ats[SampleRate] = :Rate1kSps
@test ats[SampleRate] == 1000
ats[SampleRate] = :Rate2kSps
@test ats[SampleRate] == 2000
# Should not fail, but does (Alazar API problem?):
# ats[SampleRate] = :Rate5kSps
# @test ats[SampleRate] == 5000
ats[SampleRate] = :Rate10kSps
@test ats[SampleRate] == 10000
ats[SampleRate] = :Rate20kSps
@test ats[SampleRate] == 20000
ats[SampleRate] = :Rate50kSps
@test ats[SampleRate] == 50000
ats[SampleRate] = :Rate100kSps
@test ats[SampleRate] == 100000
ats[SampleRate] = :Rate200kSps
@test ats[SampleRate] == 200000
ats[SampleRate] = :Rate500kSps
@test ats[SampleRate] == 500000
ats[SampleRate] = :Rate1MSps
@test ats[SampleRate] == 1e6
ats[SampleRate] = :Rate2MSps
@test ats[SampleRate] == 2e6
ats[SampleRate] = :Rate5MSps
@test ats[SampleRate] == 5e6
ats[SampleRate] = :Rate10MSps
@test ats[SampleRate] == 10e6
ats[SampleRate] = :Rate20MSps
@test ats[SampleRate] == 20e6
ats[SampleRate] = :Rate50MSps
@test ats[SampleRate] == 50e6
ats[SampleRate] = :Rate100MSps
@test ats[SampleRate] == 100e6
ats[SampleRate] = :Rate250MSps
@test ats[SampleRate] == 250e6
ats[SampleRate] = :Rate500MSps
@test ats[SampleRate] == 500e6
ats[SampleRate] = :Rate1000MSps
@test ats[SampleRate] == 1e9
ats[SampleRate] = :Rate1GSps
@test ats[SampleRate] == 1e9

# Test invalid internal sample rates
@test_throws InstrumentException ats[SampleRate] = :Rate25MSps
@test_throws InstrumentException ats[SampleRate] = :Rate125MSps
@test_throws InstrumentException ats[SampleRate] = :Rate160MSps
@test_throws InstrumentException ats[SampleRate] = :Rate180MSps
@test_throws InstrumentException ats[SampleRate] = :Rate200MSps
@test_throws InstrumentException ats[SampleRate] = :Rate800MSps
@test_throws InstrumentException ats[SampleRate] = :Rate1200MSps
# Should fail, but does not (Alazar API problem?):
# @test_throws InstrumentException ats[SampleRate] = :Rate1500MSps
@test_throws InstrumentException ats[SampleRate] = :Rate1800MSps
@test_throws InstrumentException ats[SampleRate] = :Rate2000MSps
@test_throws InstrumentException ats[SampleRate] = :Rate2400MSps
@test_throws InstrumentException ats[SampleRate] = :Rate3000MSps
@test_throws InstrumentException ats[SampleRate] = :Rate3600MSps
@test_throws InstrumentException ats[SampleRate] = :Rate4000MSps

# Test valid rates when using external 10 MHz reference clock
# These tests will fail if the 10 MHz reference is not connected to ECLK.
info("Warnings are expected to be emitted. Please do not be alarmed.")
ats[SampleRate] = 1.1e9
@test ats[SampleRate] == 1e9
ats[SampleRate] = 1.0e9
@test ats[SampleRate] == 1e9
ats[SampleRate] = 0.9e9
@test ats[SampleRate] == 1e9
ats[SampleRate] = 5e8
@test ats[SampleRate] == 5e8
ats[SampleRate] = 9999
@test ats[SampleRate] == 1e4
info("No further warnings are expected.")
info("Testing complete.")
nothing
