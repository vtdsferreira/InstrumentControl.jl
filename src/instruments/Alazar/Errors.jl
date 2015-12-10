"Create descriptive exceptions."
InstrumentException(ins::InstrumentAlazar, r) =
    InstrumentException(ins, r, alazar_exception(r))

"Takes a function definition and brackets the RHS with some checking."
macro eh(expr)
    quote
        $(esc(expr.args[1])) = begin
            r = $(esc(expr.args[2]))
            if (r != alazar_no_error)
                throw(InstrumentException($(esc(expr.args[1].args[2].args[1])),r))
            end
            r
        end
    end
end

"Takes an Alazar API call and brackets it with some checking."
macro eh2(expr)
    quote
        r = $(esc(expr))
        r != alazar_no_error &&
            throw(InstrumentException($(esc(expr.args[2].args[1])),r))
        r
    end
end
