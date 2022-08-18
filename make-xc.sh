#!/bin/bash

set -o errexit -o pipefail -o noclobber -o nounset

! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

LONGOPTS="help,prefix:,build-prefix:,with-default-msvcrt:"
OPTS="h"
! PARSED=$(getopt --options="$OPTS" --longoptions="$LONGOPTS" --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi

eval set -- "$PARSED"

print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --prefix=<DIR>                          Install cross-compiler in <DIR>"
    echo "                                          Defaults to /opt/xmingw"
    echo ""
    echo "  --build-prefix=<DIR>                    Build cross-compiler in <DIR>"
    echo "                                          Defaults to $HOME/mingw-build"
    echo ""
    echo "  --with-default-msvcrt=msvcrt-os|ucrt    Which C runtime to link to"
    echo "                                          Defaults to msvcrt-os"
}

MINGW_BUILD_ROOT="$HOME/mingw-build"
MINGW_ROOT='/mingw'
XC_ROOT='/opt/xmingw'
MSVCRT='msvcrt-os'

while true; do
    case $1 in
        -h|--help)
            shift
            print_usage
            exit 1
            ;;
        --prefix)
            XC_ROOT="$2"
            shift 2
            ;;
        --build-prefix)
            MINGW_BUILD_ROOT="$2"
            shift 2
            ;;
        --with-default-msvcrt)
            case $2 in
                msvcrt-os)
                    ;;
                ucrt)
                    ;;
                *)
                    echo "Invalid C runtime specified"
                    exit 1
                    ;;
            esac
            MSVCRT=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid argument"
            exit 3
            ;;
    esac
done

if [[ $# -ne 0 ]]; then
    print_usage
    exit 1
fi

echo "Bulding at:               $MINGW_BUILD_ROOT"
echo "Installing to:            $XC_ROOT"
echo "Default MSVC runtime:     $MSVCRT"

export MINGW_BUILD_ROOT
export XC_ROOT
export MINGW_ROOT
export MSVCRT

# shellcheck source=./src/build-host
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/src/build-host"

build_host_gmp && \
build_host_mpfr && \
build_host_mpc && \
build_host_zstd && \
build_host_isl && \
build_host_icu && \
source "$SCRIPT_ROOT/src/build-xc" && \
build_xc_binutils && \
build_xc_gcc && \
build_xc_gendef && \
build_xc_pkg_config
