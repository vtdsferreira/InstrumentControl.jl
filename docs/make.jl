using Documenter, InstrumentControl

makedocs()

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo   = "github.com/PainterQubits/InstrumentControl.jl.git",
    julia  = "0.6",
    osname = "linux"
)
