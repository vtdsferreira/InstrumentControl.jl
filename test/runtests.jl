using InstrumentControl
using Base.Test

import ICCommon: Response
import ICCommon: measure

@testset "Sweep" begin
    struct NotTypeStableResponse <: Response end
    measure(::NotTypeStableResponse) = if rand() > 0.5; return 1; else; return 1.0; end
    @test_throws ErrorException sweep(NotTypeStableResponse())
end
