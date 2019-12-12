using BinaryProvider
@show BinaryProvider.platform_key_abi()
if VERSION >= v"1.3"
    using Pkg
    @show Pkg.BinaryPlatforms.platform_key_abi()
end

@info "Before loading SymEngine_jll..."
using SymEngine_jll
@info "After loading SymEngine_jll..."

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
