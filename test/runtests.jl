using DependencyWalker
using Test
using ObjectFile, Pango_jll

@testset "DependencyWalker.jl" begin
    pango = Library(Pango_jll.libpango_path)
    @show pango
    @test pango isa Library{<:ObjectHandle}
    @test Library("this does not exist.foo") isa Library{Missing}
end
