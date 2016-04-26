ENTRY(main)

SECTIONS
{
    .text : { *(.text) }
    . = 0x1000;
    .data : { *(.data) }
    .bss  : { *(.bss) }
}
