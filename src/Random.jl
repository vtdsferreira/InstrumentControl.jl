export RandomResponse
type RandomResponse <: Response
end

export measure
measure(ch::RandomResponse) = rand()
