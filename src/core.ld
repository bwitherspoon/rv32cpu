ENTRY(_start)

SECTIONS
{
    .text : { *(.text) }
    . = 0x200;
    .ktext : { *(.ktext) }
    . = 0x1000;
    .data : { *(.data) }
    .bss : { *(.bss) }
}
