# Credit due to Fábio Cardeal
# https://groups.google.com/forum/#!topic/julia-users/h2cJ40NHljQ

codetyp(code) = code.args[3].typ

function returntype(f::Function, types::Tuple)
    if isgeneric(f)
        mapreduce(codetyp, Union, code_typed(f, types))::Type
    else
        Any
    end
end

function returntype(f, types::Tuple)
    returntype(call, (typeof(f), types...))
end
