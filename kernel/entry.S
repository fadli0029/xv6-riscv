        # qemu -kernel loads the kernel at 0x80000000
        # and causes each hart (i.e. CPU) to jump there.
        # kernel.ld causes the following code to
        # be placed at 0x80000000.
.section .text
.global _entry
_entry:
        # Goal: Give each CPU its own stack

        # Step 1: Get base address of stack area
        la sp, stack0           # sp = address of stack0

        # Step 2: Calculate stack size (4KB = 4096 bytes)
        li a0, 1024*4           # a0 = 4096

        # Step 3: Find out which CPU we are
        csrr a1, mhartid        # a1 = CPU ID (0, 1, 2, or 3)

        # Step 4: Calculate offset for this CPU
        addi a1, a1, 1          # a1 = CPU ID + 1 (so: 1, 2, 3, or 4)
        mul a0, a0, a1          # a0 = 4096 * (CPU ID + 1)

        # Step 5: Set stack pointer for this CPU
        add sp, sp, a0          # sp = stack0 + offset

        # Now each CPU has its own stack!
        call start
spin:
        j spin    # Jump back to spin label = infinite loop
