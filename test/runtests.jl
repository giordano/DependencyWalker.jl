using DependencyWalker
using Test
using ObjectFile, FFMPEG_jll

@testset "DependencyWalker.jl" begin
    @show FFMPEG_jll.ffmpeg_path
    io = open(FFMPEG_jll.ffmpeg_path, "r")
    @show readmeta(io)
    close(io)
    ffmpeg_oh = Library(FFMPEG_jll.ffmpeg_path)
    @show ffmpeg_oh
    if Sys.islinux() && Sys.WORD_SIZE == 32
        @test_broken ffmpeg_oh isa Library{<:ObjectHandle}
    else
        @test ffmpeg_oh isa Library{<:ObjectHandle}
    end
    @test Library("this does not exist.foo") isa Library{Missing}
end
