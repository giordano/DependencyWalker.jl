using DependencyWalker
using Test
using ObjectFile

using Glib_jll
using Pixman_jll
using libpng_jll
using Fontconfig_jll
using FreeType2_jll
using Bzip2_jll
using Xorg_libX11_jll
# using Xorg_libXext_jll
# using Xorg_libXrender_jll
using LZO_jll
using Zlib_jll

using Xorg_libxcb_jll

using Libdl

@show dllist()

println()

@show Library(Xorg_libX11_jll.libX11_path)

println()

@show Library(Xorg_libxcb_jll.libxcb_shm_path)
