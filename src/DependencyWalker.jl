module DependencyWalker

using ObjectFile, Crayons
import Libdl

export Library

struct Library{OH<:Union{ObjectHandle,Missing,Nothing}}
    path::String
    handle::OH
    level::Int
    deps::Vector{Library}
end

function Library(path::String, level::Int = 0)
    if !isfile(path)
        # TODO: should check also if it can be opened?
        return Library(path, missing, level, Library[])
    end
    io = open(path, "r")
    oh = try
        readmeta(io)
    catch
        close(io)
        nothing
    end
    oh_new, deps = dependency_tree(oh, level)
    isopen(io) && close(io)
    return Library(path, oh_new, level, deps)
end

Library(path::String, oh::T, level::Int) where {T<:Union{Missing,Nothing}} =
    Library{T}(path, oh, level, Library[])

Library(path::AbstractString, handle, level) =
    Library(String(path), handle, level)

# Check if `lib` matches `open_lib`, one of the libraries currently loaded in
# the system.  The condition to ignore the case is not quite accurate as this is
# a file-system property rather than an OS one, but in most cases this is
# correct.
@static if Sys.iswindows() || Sys.isapple()
    is_library_open(lib, open_lib) = occursin(lowercase(lib), lowercase(open_lib))
else
    is_library_open(lib, open_lib) = occursin(lib, open_lib)
end

function dependency_tree(oh::ObjectHandle, level::Int; dlext::String = Libdl.dlext)
    # Initialise list of dependencies
    deps = Library[]
    # Get the list of needed libraries
    deps_names = try
        keys(find_libraries(oh))
    catch
        # We've got an error while looking for the libraries.
        return nothing, deps
    end
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
            push!(deps, Library(dep, missing, level + 1))
        else
            # Push the found library to the list
            push!(deps, Library(open_dls[idx], level + 1))
        end
    end
    return oh, deps
end

dependency_tree(oh::Union{Nothing,Missing}, level) = (oh, Library[])

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

end # module
