InstrumentException(ins::InstrumentAlazar, r) =
    InstrumentException(ins, r, alazar_exception(r))

"""
Takes an Alazar API call and brackets it with some error checking.
Throws an InstrumentException if there is an error.
"""
macro eh2(expr)
    quote
        r = $(esc(expr))
        r != alazar_no_error &&
            throw(InstrumentException($(esc(expr.args[2].args[1])),r))
        r
    end
end
