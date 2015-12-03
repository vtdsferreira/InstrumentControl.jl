export RandomResponse
immutable RandomResponse <: Response end

measure(ch::RandomResponse) = rand()
