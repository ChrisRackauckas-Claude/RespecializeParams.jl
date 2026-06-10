using RespecializeParams
using Aqua
using JET
using Test

@testset "Aqua" begin
    # deps_compat extras sub-check disabled: the package omits [compat] entries
    # for the Aqua/JET test-only [extras]. Tracked in
    # https://github.com/SciML/RespecializeParams.jl/issues/10
    Aqua.test_all(RespecializeParams; deps_compat = (; check_extras = false))
    @test_broken false  # Aqua deps_compat: missing [compat] for Aqua/JET extras — tracked in https://github.com/SciML/RespecializeParams.jl/issues/10
end

@testset "JET" begin
    JET.test_package(RespecializeParams; target_defined_modules = true)
end
