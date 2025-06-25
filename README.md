# DependencyWalker

[![Build Status](https://travis-ci.com/giordano/DependencyWalker.jl.svg?branch=master)](https://travis-ci.com/giordano/DependencyWalker.jl)

## Introduction

Walk through the dependencies of a shared library loaded in
[Julia](https://julialang.org/), similarly to what [Dependency
Walker](https://en.wikipedia.org/wiki/Dependency_Walker) does with shared
libraries on your system.

## Installation

This package is registered, so you can install it by entering the package
manager mode in the REPL with the `]` key and running the command

```
add DependencyWalker
```

## Usage

The package exports a single function, `Library`, which takes as only argument
the path to the shared library:

```julia
julia> using DependencyWalker, LibSSH2_jll

julia> LibSSH2_jll.libssh2_path # Path to the libssh2 library
"/home/user/.julia/artifacts/26c7d3a6c17151277018b133ab0034e93ddc3d1e/lib/libssh2.so"

julia> Library(LibSSH2_jll.libssh2_path)
◼ /home/user/.julia/artifacts/26c7d3a6c17151277018b133ab0034e93ddc3d1e/lib/libssh2.so
  ◼ /usr/bin/../lib/julia/libmbedtls.so.12
    ◼ /usr/bin/../lib/julia/libmbedx509.so.0
      ◼ /usr/bin/../lib/libc.so.6
        ◼ /lib64/ld-linux-x86-64.so.2
      ◼ /usr/bin/../lib/julia/libmbedcrypto.so.3
        ◼ /usr/bin/../lib/libc.so.6
          ◼ /lib64/ld-linux-x86-64.so.2
    ◼ /usr/bin/../lib/libc.so.6
      ◼ /lib64/ld-linux-x86-64.so.2
    ◼ /usr/bin/../lib/julia/libmbedcrypto.so.3
      ◼ /usr/bin/../lib/libc.so.6
        ◼ /lib64/ld-linux-x86-64.so.2
  ◼ /usr/bin/../lib/julia/libmbedx509.so.0
    ◼ /usr/bin/../lib/libc.so.6
      ◼ /lib64/ld-linux-x86-64.so.2
    ◼ /usr/bin/../lib/julia/libmbedcrypto.so.3
      ◼ /usr/bin/../lib/libc.so.6
        ◼ /lib64/ld-linux-x86-64.so.2
  ◼ /usr/bin/../lib/libc.so.6
    ◼ /lib64/ld-linux-x86-64.so.2
  ◼ /usr/bin/../lib/julia/libmbedcrypto.so.3
    ◼ /usr/bin/../lib/libc.so.6
      ◼ /lib64/ld-linux-x86-64.so.2
```

## License

The `DependencyWalker.jl` package is licensed under the MIT "Expat" License.
The original author is Mosè Giordano.
