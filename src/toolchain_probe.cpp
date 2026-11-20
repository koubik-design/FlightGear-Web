#include <iostream>

int main() {
    std::cout << "FlightGear-Web toolchain probe: OK\n";
    std::cout << "This executable validates Emscripten output only.\n";
#ifdef __EMSCRIPTEN__
    std::cout << "Target: WebAssembly via Emscripten\n";
#else
    std::cout << "Target: native host (Emscripten was not selected)\n";
#endif
    return 0;
}
