Various scripts for cross-compiling for x64 MinGW

`src/build-*` files contain bash script functions for the following purposes:

* `src/build-host` contains scripts for building required host software

* `src/build-xc` contains scripts for building a cross-compiler

* `src/build-target` contains scripts for building target stuff

Some built\_target\_\* stuff currently requires to be built on WSL2, because of it executing windows binaries or otherwise interacting with the target system.

Build order is a TODO

List of prerequisites is a TODO

`src/download-sources` is a script which downloads all the required software and patches it

`src/env-*` files contain environment variables which define target directories, CFLAGS, etc.

`misc` directory contain pkg-config files, custom Makefiles, configuration files and other things.

First of all, `/mingw` directory (or symlink to a directory) of the following structure should exist:

(`/x -> /y` means 'x' must be a symlink to the directory named 'y')

    /mingw/
    /mingw/lib/
    /mingw/lib64 -> /mingw/lib
    /mingw/x86_64-w64-mingw32/
    /mingw/mingw -> /mingw/x86_64-w64-mingw32

Yes, I know that `/mingw/mingw` sounds weird, but that's it. GCC requires it. 

Maybe this could be fixed. I'll need to take a deeper look at GCC configuration options.

In case of WSL2, /mingw should be a symlink to `C:\MinGW`.
````powershell
New-Item -ItemType  Directory -Path 'C:\' -Name 'MinGW'
Set-Location 'C:\MinGW'
New-Item -ItemType Directory -Name 'lib'
New-Item -ItemType Junction -Name 'lib64' -Target '.\lib'
New-Item -ItemType Directory -Name 'x86_64-w64-mingw32'
New-Item -ItemType Junction -Name 'mingw' -Target '.\x86_64-w64-mingw32'
````
(then inside WSL2)
````bash
sudo ln -sf /mnt/c/MinGW /mingw
````