/* SPDX-License-Identifier: Apache-2.0
 *
 * Minimal semihosted program for CH32V303 (rv32imafc / ilp32f).
 *
 * Exercises semihost I/O via picolibc's printf, which routes output through
 * the RISC-V semihosting ABI to the connected debugger or QEMU session
 * rather than a hardware UART.
 */

#include <stdint.h>
#include <stdio.h>

int main(void) {
    printf("Hello from CH32V303 semihost!\n");
    return 0;
}
