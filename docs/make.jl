using Documenter, InstrumentControl

makedocs()

deploydocs(
    deps   = Deps.pip("mkdocs", "mkdocs-material", "python-markdown-math"),
    julia  = "0.6",
    osname = "linux",
    repo   = "github.com/PainterQubits/InstrumentControl.jl.git"
)
