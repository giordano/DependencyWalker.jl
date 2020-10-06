module DependencyWalker

using ObjectFile, Crayons
import Libdl

export Library

struct Library{OH<:Union{ObjectHandle,Missing,Nothing}}
    path::String
    handle_type::Type{OH}
    level::Int
    deps::Vector{Library}
end

function Library(path::String, level::Int = 0)
    if !isfile(path)
        # TODO: should check also if it can be opened?
        return Library(path, Missing, level, Library[])
    end
    io = open(path, "r")
    oh, deps_names = try
        oh = readmeta(io)
        # Get the list of needed libraries
        oh, keys(find_libraries(oh))
    catch
        nothing, []
    end
    close(io)
    deps = dependency_tree(deps_names, level)
    return Library(path, typeof(oh), level, deps)
end

Library(path::String, oht::Type{T}, level::Int) where {T<:Union{Missing,Nothing}} =
    Library{T}(path, oht, level, Library[])

Library(path::AbstractString, oht, level) =
    Library(String(path), oht, level)

# Check if `lib` matches `open_lib`, one of the libraries currently loaded in
# the system.  The condition to ignore the case is not quite accurate as this is
# a file-system property rather than an OS one, but in most cases this is
# correct.
@static if Sys.iswindows() || Sys.isapple()
    is_library_open(lib, open_lib) = occursin(lowercase(lib), lowercase(open_lib))
else
    is_library_open(lib, open_lib) = occursin(lib, open_lib)
end

function dependency_tree(deps_names, level::Int; dlext::String = Libdl.dlext)
    # Initialise list of dependencies
    deps = Library[]
    # Get list of already dlopen'ed libraries
    open_dls = Libdl.dllist()
    for dep in deps_names
        if Sys.iswindows() && occursin(r"^api-ms-win-.*\.dll"i, dep)
            # Skipp all "api-ms-win-*" libraries on Windows
            continue
        end
        split_dep = split(dep, '.')
        # Get rid of the soversion.  TODO: this is only for GNU/Linux and
        # FreeBSD, no idea what we have to do for the other operating systems.
        idx = findlast(isequal(dlext), split_dep)
        if !isnothing(idx)
            dep = join(split_dep[1:idx], '.')
        end
        # Get the first dlopen'ed library matching the needed library, if any
        idx = findfirst(d -> is_library_open(dep, d), open_dls)
        if isnothing(idx)
            # Push a missing library to the list
            push!(deps, Library(dep, Missing, level + 1))
        else
            # Push the found library to the list
            push!(deps, Library(open_dls[idx], level + 1))
        end
    end
    return deps
end

reduce_hash(x::UInt64) = Base.hash_64_32(x)
reduce_hash(x::UInt32) = x

function Base.show(io::IO, lib::Library{T}) where {T}
    if T === Missing
        symbol = "✗"
        extra_info = " (NOT FOUND)"
    elseif T === Nothing
        symbol = "❓"
        extra_info = " (COULD NOT READ METADATA)"
    else
        symbol = "◼"
        extra_info = ""
    end
    print(io, repeat("  ", lib.level), Crayon(foreground = reduce_hash(hash(lib.path))), symbol,
          Crayon(reset=true), " ", lib.path, Crayon(foreground = :yellow), "$(extra_info)")
    for dep in lib.deps
        println(io)
        show(io, dep)
    end
end

"""
DependencyWalker lets you walk through the dependencies of a shared library loaded in Julia.

The package exports a single function, `Library`, which takes as only argument the path to the shared library:

```
julia> using DependencyWalker, LibSSH2_jll

julia> LibSSH2_jll.libssh2_path # Path to the libssh2 library
"/home/user/.julia/artifacts/26c7d3a6c17151277018b133ab0034e93ddc3d1e/lib/libssh2.so"

julia> Library(LibSSH2_jll.libssh2_path)
◼ /home/user/.julia/artifacts/26c7d3a6c17151277018b133ab0034e93ddc3d1e/lib/libssh2.so
  ◼ /usr/bin/../lib/julia/libmbedtls.so.12
    ◼ /usr/bin/../lib/julia/libmbedx509.so.0
...
```
"""
DependencyWalker

end # module
