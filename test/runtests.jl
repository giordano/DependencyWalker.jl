using DependencyWalker
using Test
using ObjectFile
using Libdl

using libass_jll
using libfdk_aac_jll
using FriBidi_jll
using FreeType2_jll
using LAME_jll
using libvorbis_jll
using Ogg_jll
using x264_jll
using x265_jll
using Bzip2_jll
using Zlib_jll
using OpenSSL_jll
using Opus_jll

try
    using FFMPEG_jll
catch
    nothing
end

@testset "DependencyWalker.jl" begin
    @info "Libraries in dllist():"
    for lib in Libdl.dllist()
        println("  ", lib)
    end

    if Sys.iswindows()
        libfile = expanduser(raw"C:\Users\appveyor\.julia\artifacts\800e7ecd8f7c4fe43e25c4084893e049ebe1c934\bin\avcodec-58.dll")
        pango = Library(libfile)
        @show pango
    else
        pango = Library(FFMPEG_jll.libavcodec_path)
        @show pango
    end


    @test Library("this does not exist.foo") isa Library{Missing}
end
