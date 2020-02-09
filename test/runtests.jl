using DependencyWalker
using Test
using ObjectFile, Pkg.BinaryPlatforms
using SuiteSparse_jll

# @show platform_key_abi()

# if Sys.iswindows()
#     if haskey(ENV, "TRAVIS")
#         @show Library(raw"C:\Users\travis\.julia\artifacts\e177c77afc4dbd274277508bd5d069731bbe517e\bin\libspqr.dll")
#     else
#         @show Library(raw"C:\Users\appveyor\.julia\artifacts\e082284e0a29a950b24a5a1817e7eef7247ccb7c\bin\libspqr.dll")
#     end
# end

# @testset "DependencyWalker.jl" begin
#     pango = Library(Pango_jll.libpango_path)
#     @show pango
#     if Sys.islinux() && Sys.WORD_SIZE == 32
#         @test_broken pango isa Library{<:ObjectHandle}
#     else
#         @test pango isa Library{<:ObjectHandle}
#     end
#     @test Library("this does not exist.foo") isa Library{Missing}
# end
