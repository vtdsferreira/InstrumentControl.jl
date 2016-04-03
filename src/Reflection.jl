# Since the use of Base.return_types is discouraged,
# we need a way to determine the return type of a function.
#
# Credit due to Fábio Cardeal
# https://groups.google.com/forum/#!topic/julia-users/h2cJ40NHljQ

"""
`codetyp(code)`

Given an expression resulting from
[`code_typed`](http://docs.julialang.org/en/release-0.4/stdlib/base/?highlight=code_typed#Base.code_typed),
returns the return type.
"""
codetyp(code) = code.args[3].typ

"""
`returntype(f::Function, types::Tuple)`

For a given function and argument type tuple, a method is specified.
This function returns the return type of that method.
"""
function returntype(f::Function, types::Tuple)
    if isgeneric(f)
        mapreduce(codetyp, Union, code_typed(f, types))::Type
    else
        Any
    end
end

"""
`returntype(f, types::Tuple)`

For a given function and argument type tuple, a method is specified.
This function returns the return type of that method.
"""
function returntype(f, types::Tuple)
    returntype(call, (typeof(f), types...))
end
