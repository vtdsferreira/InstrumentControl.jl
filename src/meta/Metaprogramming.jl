# This file is not a module, which is very apparently important.
#
# If we want instruments to be in their own modules, which makes some sense to
# avoid needlessly polluting the namespace for people who won't use all of the
# instruments, then this code needs to appear inside each instrument's module.
# Otherwise, if this code were in its own module `Metaprogramming`, @eval would
# get called in module `Metaprogramming` rather than the instrument's module.
# This would be a bit problematic.
#
# Nothing is exported as the user should never use these, and we don't want
# instruments to see this if it is used from our PainterQB module.

import JSON
include("ConfigInspect.jl")
include("Properties.jl")
include("Handlers.jl")
