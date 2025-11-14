OUTPUT_ARCH( "riscv" )
ENTRY( _entry )

/*
 * NOTE: The dot . is a special variable which means "current location counter".
 * Think of it as a cursor that moves through memory as we place things. 
 */

SECTIONS
{
  /*
   * ensure that entry.S / _entry is at 0x80000000,
   * where qemu's -kernel jumps.
   */
  . = 0x80000000;

  .text : {
    
    kernel/entry.o(_entry) 
    /* This says: "From the file kernel/entry.o, take the _entry section and put it HERE (first thing
    in .text)". At this point, the current memory layout looks something like this:
    Address          Contents
    0x80000000       _entry code from entry.S
    . = 0x80000000 + size_of(_entry)
    */
    *(.text .text.*) 
    /* The * means "from ALL object files". So, this says "Take .text and .text.* sections from EVERY object
    file and place them here". Why .text.*? Some compilers create subsections like .text.main, .text.printf, etc.
    This catches all of them. At this point, the current memory layout looks something like this:
    Address          Contents
    0x80000000       _entry code
    0x80000000+X     All other code from all .o files
    . = 0x80000000 + X + Y
    */
    . = ALIGN(0x1000);
    /* For the rest of the explanation of this file see notes on linker script in your MIT 6.1810 repo*/
    _trampoline = .;
    *(trampsec)
    . = ALIGN(0x1000);
    ASSERT(. - _trampoline == 0x1000, "error: trampoline larger than one page");
    PROVIDE(etext = .);
  }

  .rodata : {
    . = ALIGN(16);
    *(.srodata .srodata.*) /* do not need to distinguish this from .rodata */
    . = ALIGN(16);
    *(.rodata .rodata.*)
  }

  .data : {
    . = ALIGN(16);
    *(.sdata .sdata.*) /* do not need to distinguish this from .data */
    . = ALIGN(16);
    *(.data .data.*)
  }

  .bss : {
    . = ALIGN(16);
    *(.sbss .sbss.*) /* do not need to distinguish this from .bss */
    . = ALIGN(16);
    *(.bss .bss.*)
  }

  PROVIDE(end = .);
}
