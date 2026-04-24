/* SPDX-License-Identifier: Apache-2.0
 *
 * Minimal bare-metal program used to verify that the toolchain and picolibc
 * sysroot are usable.  The program exercises:
 *  - Standard integer types from <stdint.h>  (picolibc header resolution)
 *  - A simple memory write (generates real code that the compiler cannot elide)
 *
 * This source is intentionally free of OS/hosted dependencies so that it can
 * be compiled against the bare-metal sysroot without startup files or a
 * linker script.
 */

#include <stdint.h>

volatile uint32_t result;

int main(void) {
    result = UINT32_C(42);
    return 0;
}
