"Create descriptive exceptions."
InstrumentException(ins::InstrumentAlazar, r) =
    InstrumentException(ins, r, alazar_exception(r))

"Takes an Alazar API call and brackets it with some checking."
macro eh2(expr)
    quote
        r = $(esc(expr))
        r != alazar_no_error &&
            throw(InstrumentException($(esc(expr.args[2].args[1])),r))
        r
    end
end
