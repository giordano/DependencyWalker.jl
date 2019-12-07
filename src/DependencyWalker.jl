module DependencyWalker

using ObjectFile, Crayons
import Libdl

export Library

struct Library{OH<:Union{ObjectHandle,Missing}}
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
        missing
    end
    lib = Library(path, oh, level, dependency_tree(oh, level))
    isopen(io) && close(io)
    return lib
end

Library(path::String, nil::Missing, level::Int) =
    Library{Missing}(path, nil, level, [])

Library(path::AbstractString, handle, level) =
    Library(String(path), handle, level)

function dependency_tree(oh::ObjectHandle, level::Int; dlext::String = Libdl.dlext)
    # Get the list of needed libraries
    deps_names = keys(find_libraries(oh))
    # Get list of already dlopen'ed libraries
    open_dls = Libdl.dllist()
    # Initialise list of dependencies
    deps = Library[]
    for dep in deps_names
        split_dep = split(dep, '.')
        # Get rid of the soversion.  TODO: this is only for GNU/Linux and
        # FreeBSD, no idea what we have to do for the other operating systems.
        idx = findlast(isequal(dlext), split_dep)
        if !isnothing(idx)
            dep = join(split_dep[1:idx], '.')
        end
        # Get the first dlopen'ed library matching the needed library, if any
        idx = findfirst(d -> occursin(dep, basename(d)), open_dls)
        if isnothing(idx)
            # Push a missing library to the list
            push!(deps, Library(dep, missing, level + 1))
        else
            # Push the found library to the list
            push!(deps, Library(open_dls[idx], level + 1))
        end
    end
    return deps
end

dependency_tree(::Missing, level) = Library[]

reduce_hash(x::UInt64) = Base.hash_64_32(x)
reduce_hash(x::UInt32) = x

function Base.show(io::IO, lib::Library{<:ObjectHandle})
    print(io, Crayon(foreground = reduce_hash(hash(lib.path))),
          repeat("  ", lib.level), "* ", lib.path)
    for dep in lib.deps
        println(io)
        show(io, dep)
    end
end

Base.show(io::IO, lib::Library{Missing}) =
    printstyled(io, repeat("  ", lib.level), "* ", lib.path, " (NOT FOUND)", color = :yellow)

end # module
