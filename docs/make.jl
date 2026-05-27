using Documenter, RespecializeParams

mkpath("./docs/src/assets")
cp("./docs/Manifest.toml", "./docs/src/assets/Manifest.toml", force = true)
cp("./docs/Project.toml", "./docs/src/assets/Project.toml", force = true)

makedocs(
    modules = [RespecializeParams],
    sitename = "RespecializeParams.jl",
    clean = true,
    doctest = false,
    linkcheck = true,
    format = Documenter.HTML(
        canonical = "https://docs.sciml.ai/RespecializeParams/stable/"
    ),
    pages = [
        "Home" => "index.md",
    ]
)

deploydocs(repo = "github.com/SciML/RespecializeParams.jl"; push_preview = true)
