using DependencyWalker
using Test
using ObjectFile, gdk_pixbuf_jll

@testset "DependencyWalker.jl" begin
    pango = Library(gdk_pixbuf_jll.gdk_pixbuf_query_loaders_path)
    @show pango
    if Sys.islinux() && Sys.WORD_SIZE == 32
        @test_broken pango isa Library{<:ObjectHandle}
    else
        @test pango isa Library{<:ObjectHandle}
    end
    @test Library("this does not exist.foo") isa Library{Missing}
end
