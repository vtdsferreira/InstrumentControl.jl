export RandomResponse

"Random number response suitable for testing the measurement code without having
a physical instrument."
immutable RandomResponse <: Response{typeof(rand())} end

"Returns a random number in the unit interval."
measure(ch::RandomResponse) = rand()
