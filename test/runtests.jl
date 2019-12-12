using DependencyWalker
using Test
using ObjectFile, Pango_jll

@testset "DependencyWalker.jl" begin
    @show readmeta(open(Pango_jll.libpango_path, "r"))
    pango = Library(Pango_jll.libpango_path)
    @show pango
    if Sys.islinux() && Sys.WORD_SIZE == 32
        @test_broken pango isa Library{<:ObjectHandle}
    else
        @test pango isa Library{<:ObjectHandle}
    end
    @test Library("this does not exist.foo") isa Library{Missing}
end
