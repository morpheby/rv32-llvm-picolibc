/* SPDX-License-Identifier: Apache-2.0
 *
 * Minimal semihosted C++ program – mirrors semihost_ch32v303/main.c but
 * exercises C++ language features:
 *  - Class with constructor and operator overloading
 *  - constexpr / [[nodiscard]]
 *
 * Output is routed through the RISC-V semihosting ABI to the connected
 * debugger or QEMU session rather than a hardware UART.
 *
 * Deliberately avoids STL and exceptions so the same source compiles under
 * both the no-exn/no-rtti and exn+rtti toolchain variants.
 */

#include <cstdint>
#include <cstdio>

class Counter {
    std::uint32_t value_;
public:
    explicit constexpr Counter(std::uint32_t v = 0U) noexcept : value_{v} {}
    constexpr Counter &operator++() noexcept { ++value_; return *this; }
    [[nodiscard]] constexpr std::uint32_t get() const noexcept { return value_; }
};

int main() {
    Counter c{40U};
    ++c;
    ++c;
    std::printf("Hello from C++ semihost! count=%u\n", static_cast<unsigned>(c.get()));
    return 0;
}
