module DependencyWalker

using ObjectFile
import Libdl

export Library

struct Library{OH<:Union{ObjectHandle,Missing}}
    path::String
    handle::OH
    level::Int
    deps::Vector{Library}
end

function Library(path::String, level::Int = 0)
    oh = try
        readmeta(open(path, "r"))
    catch
        nothing
    end
    if isnothing(oh)
        return Library(path, missing, level)
    else
        return Library(path, oh, level, dependency_tree(oh, level))
    end
end

Library(path::String, nil::Missing, level::Int) =
    Library{Missing}(path, nil, level, [])

Library(path::AbstractString, handle, level) =
    Library(String(path), handle, level)

function dependency_tree(oh, level)
    # Get the list of needed libraries
    deps_names = keys(find_libraries(oh))
    # Get list of already dlopen'ed libraries
    open_dls = Libdl.dllist()
    # Initialise list of dependencies
    deps = Library[]
    for dep in deps_names
        # Get the first dlopen'ed library matching the needed library, if any
        idx = findfirst(d -> dep == basename(d), open_dls)
        if isnothing(idx)
            # Push a missing library to the list
            push!(deps, Library(dep, missing, level + 1))
        else
            # Return the found library to the list
            push!(deps, Library(open_dls[idx], level + 1))
        end
    end
    return deps
end

function Base.show(io::IO, lib::Library{<:ObjectHandle})
    println(io, repeat("  ", lib.level), "* ", lib.path)
    for dep in lib.deps
        show(io, dep)
    end
end

Base.show(io::IO, lib::Library{Missing}) =
    printstyled(io, repeat("  ", lib.level), "* ", lib.path, " (NOT FOUND)\n", color = :yellow)

end # module
