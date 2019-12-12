using SymEngine_jll

# @testset "DependencyWalker.jl" begin
#     @show SymEngine_jll.libsymengine_path
#     io = open(SymEngine_jll.libsymengine_path, "r")
#     @show readmeta(io)
#     close(io)
#     libsymengine_oh = Library(SymEngine_jll.libsymengine_path)
#     @show libsymengine_oh
#     # if Sys.islinux() && Sys.WORD_SIZE == 32
#     #     @test_broken libsymengine_oh isa Library{<:ObjectHandle}
#     # else
#     #     @test libsymengine_oh isa Library{<:ObjectHandle}
#     # end
#     # @test Library("this does not exist.foo") isa Library{Missing}
# end
