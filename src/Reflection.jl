# Since the use of Base.return_types is discouraged,
# we need a way to determine the return type of a function.
#
# Credit due to Fábio Cardeal
# https://groups.google.com/forum/#!topic/julia-users/h2cJ40NHljQ

"""
```
codetyp(code)
```

Given an expression resulting from
[`code_typed`](http://docs.julialang.org/en/release-0.4/stdlib/base/?highlight=code_typed#Base.code_typed),
returns the return type.
"""
function codetyp(code)
    @static if VERSION < v"0.5.0-pre"
        code.args[3].typ
    else
        code.rettype
    end
end

"""
```
returntype(f::Function, types::Tuple)
```

For a given function and argument type tuple, a method is specified.
This function returns the return type of that method. If the function is not
type-stable (the result type is not concrete), then an error is thrown.
"""
function returntype(f::Function, types::Tuple)
    arr = code_typed(f, types)
    length(arr) > 1 && error("return type not stable.")
    codetyp(arr[1])
end
