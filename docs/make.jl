using Documenter, PainterQB

makedocs()

makedocs(source="src/e5071C",
         build="build/e5071C",
         doctest=false,
         modules = [E5071CModule])

makedocs(source="src/awg5014c",
         build="build/awg5014c",
         doctest=false,
         modules = [AWG5014CModule])
