## Continuous integration testing

Tests are run on this package whenever an update is merged into the master branch.
Two environment variables are required to be set on the testing server for tests to pass
(they can be set to anything). These are `ICTESTMODE` and `VISA_JL_NO_LOAD`. The former
tells InstrumentControl.jl not to open a VISA resource manager as well as to skip loading
the `config.json` file. The latter tells VISA.jl not to look for and load a VISA library.
Together, these environment variables enable some basic testing and automatic docs building
for InstrumentControl.jl.

## Documentation build process

[Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) is used to build these docs
automatically whenever tests complete successfully.
