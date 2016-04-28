ENTRY(_start)

SECTIONS
{
    .boot :
    {
        __boot_start = .;
        *(.boot)
        __boot_end = .;
    }

    . = 0x200;
    .kern :
    {
        __kern_start = .;
        *(.kern)
        __kern_end = .;
    }

    . = 0x400;
    .text :
    {
        __text_start = .;
        *(.text)
        __text_end = .;
    }

    . = 0x1000;
    .data :
    {
        __data_start = .;
        *(.data)
        __data_end = .;
    }

    .bss :
    {
        __bss_start = .;
        *(.bss)
        __bss_end = .;
    }

    __heap_start = .;
    __stack_start = 0x2000;
    __gpio_start = 0x40000000;
    __uart_start = 0x40001000;
}
