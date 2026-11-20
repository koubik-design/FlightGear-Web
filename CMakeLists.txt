cmake_minimum_required(VERSION 3.20)

project(FlightGearWebToolchainProbe
    VERSION 0.1.0
    DESCRIPTION "FlightGear-Web Emscripten toolchain validation"
    LANGUAGES C CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(fgweb_toolchain_probe
    src/toolchain_probe.cpp
)

if(EMSCRIPTEN)
    # Emit a browser-loadable HTML launcher together with its JS/WASM payload.
    set_target_properties(fgweb_toolchain_probe PROPERTIES SUFFIX ".html")
    target_link_options(fgweb_toolchain_probe PRIVATE
        "-sWASM=1"
        "-sALLOW_MEMORY_GROWTH=1"
        "-sEXIT_RUNTIME=1"
    )
else()
    message(STATUS "Configuring a native toolchain probe (not a browser build)")
endif()
