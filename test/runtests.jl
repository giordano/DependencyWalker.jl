using DependencyWalker
using Test
using ObjectFile, Pango_jll

@testset "DependencyWalker.jl" begin
    @test Library(Pango_jll.libpango_path) isa Library{<:ObjectHandle}
    @test Library("this does not exist.foo") isa Library{Missing}
end
