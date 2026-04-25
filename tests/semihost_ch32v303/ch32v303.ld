/* Linker script for CH32V303 (rv32imafc) semihost builds.
 *
 * Defines the physical memory map of the CH32V303 and delegates all
 * section layout to picolibc's standard linker script (picolibc.ld),
 * which is installed in the multilib sysroot lib directory.
 *
 * Memory map (CH32V303xC / CH32V303xE):
 *   Flash: 256 KB at 0x08000000
 *   SRAM:   64 KB at 0x20000000
 */

MEMORY
{
    flash (rx)  : ORIGIN = 0x08000000, LENGTH = 256K
    ram   (rwx) : ORIGIN = 0x20000000, LENGTH = 64K
}

INCLUDE picolibc.ld
