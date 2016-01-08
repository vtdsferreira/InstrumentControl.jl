using PainterQB, Lexicon

cd(dirname(@__FILE__))

docs = [save("api/PainterQB.md",PainterQB; md_subheader=:category)]

push!(docs, save("api/E5071C.md", PainterQB.E5071CModule; md_subheader=:category))
push!(docs, save("api/E8257D.md", PainterQB.E8257DModule; md_subheader=:category))
push!(docs, save("api/AWG5014C.md", PainterQB.AWG5014CModule; md_subheader=:category))
push!(docs, save("api/AlazarTech.md", PainterQB.AlazarModule; md_subheader=:category))

save("api/api.md", Index(docs); md_subheader=:category);
