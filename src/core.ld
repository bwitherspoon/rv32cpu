OUTPUT_ARCH("riscv")

ENTRY(_start)

GROUP(-lc -lnosys -lgcc)

SECTIONS
{
    .loader :
    {
        *(.vector)
        *(.loader)
    }

    . = 0x00000400;
    _ftext = .;

    .text :
    {
        *(.text)
        *(.text.*)
    }

    .init :
    {
        KEEP(*(.init))
    }

    .fini :
    {
        KEEP(*(.fini))
    }

    PROVIDE(etext = .);
    _etext = .;

    . = 0x1000;
    _fdata = .;

    .data :
    {
        *(.data)
        *(.data.*)
    }

    . = ALIGN(4);
    _gp = .;

    PROVIDE(edata = .);
    _edata = .;

    _fbss = .;
    .bss :
    {
        *(.bss)
        *(.bss.*)
    }

    PROVIDE(end = .);
    _end = ALIGN(4);

    _stack = 0x2000;
    _gpio = 0x400000;
    _uart = 0x401000;
}
