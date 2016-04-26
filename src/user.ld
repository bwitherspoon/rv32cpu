ENTRY(main)

SECTIONS
{
    . = 0x400;
    .text : { *(.text) }
    . = 0x1000;
    .data : { *(.data) }
    .bss  : { *(.bss) }
}
