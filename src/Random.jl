export RandomResponse

immutable RandomResponse <: Response{typeof(rand())} end

measure(ch::RandomResponse) = rand()
