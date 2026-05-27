# RespecializeParams.jl

[![Join the chat at https://julialang.zulipchat.com #sciml-bridged](https://img.shields.io/static/v1?label=Zulip&message=chat&color=9558b2&labelColor=389826)](https://julialang.zulipchat.com/#narrow/stream/279055-sciml-bridged)
[![Global Docs](https://img.shields.io/badge/docs-SciML-blue.svg)](https://docs.sciml.ai/RespecializeParams/stable/)

[![codecov](https://codecov.io/gh/SciML/RespecializeParams.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/SciML/RespecializeParams.jl)
[![CI](https://github.com/SciML/RespecializeParams.jl/actions/workflows/Tests.yml/badge.svg?branch=main)](https://github.com/SciML/RespecializeParams.jl/actions/workflows/Tests.yml)

[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor%27s%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)

RespecializeParams.jl provides type-stable opaque parameter containers for SciML
solvers. The goal is to keep `typeof(p)` uniform across underlying payload
types — so a precompiled solver path is shared — while still recovering the
concrete payload type inside `f` for fully specialized inner kernels.

Two containers are exported:

  - `OpaqueParams` for `isbits` payloads (backed by `Vector{UInt8}`; `unpack` is a single `unsafe_load`).
  - `OpaqueRef` for arbitrary payloads (backed by `Ref{Any}`; `unpack` is a pointer load + `::T` assertion).

Both wrappers have a fixed Julia type regardless of the payload, so a solver
dispatching on `typeof(p)` hits the same precompiled code path across
problems whose underlying parameter structs differ. Inside `f`, `unpack` is
type-stable and allocation-free.

## Installation

```julia
using Pkg
Pkg.add("RespecializeParams")
```

## Quick example

```julia
using RespecializeParams, OrdinaryDiffEqTsit5

struct LorenzP
    σ::Float64
    ρ::Float64
    β::Float64
end

struct OpaqueRHS{T, F} <: Function
    f::F
end
OpaqueRHS(::Type{T}, f::F) where {T, F} = OpaqueRHS{T, F}(f)

@inline function (r::OpaqueRHS{T})(du, u, op::OpaqueParams, t) where {T}
    p = unpack(op, T)
    r.f(du, u, p, t)
    return nothing
end

function lorenz_kernel!(du, u, p::LorenzP, t)
    du[1] = p.σ * (u[2] - u[1])
    du[2] = u[1] * (p.ρ - u[3]) - u[2]
    du[3] = u[1] * u[2] - p.β * u[3]
    return nothing
end

prob = ODEProblem(
    OpaqueRHS(LorenzP, lorenz_kernel!),
    [1.0, 0.0, 0.0],
    (0.0, 5.0),
    pack(LorenzP(10.0, 28.0, 8 / 3)),
)

solve(prob, Tsit5())
```

See the [documentation](https://docs.sciml.ai/RespecializeParams/stable/) for
the full API, the non-`isbits` `OpaqueRef` story, and design notes.
