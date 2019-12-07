using DependencyWalker
using Test
using Pango_jll

@testset "DependencyWalker.jl" begin
    @test Library(Pango_jll.libpango_path) isa Library
end
