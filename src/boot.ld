ENTRY(_start)

SECTIONS
{
    .isr :
    {
        __isr_start = .;
        *(.isr)
        __isr_end = .;
    }

    . = 0x200;
    .text :
    {
        __text_start = .;
        *(.text)
        __text_end = .;
    }

    __kern_start = 0x400;

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
    __gpio_start = 0x00400000;
    __uart_start = 0x00401000;
}
