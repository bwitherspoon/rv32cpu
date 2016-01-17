ENTRY(_start)

SECTIONS
{
    .text : { *(.text) }
    . = 0x200;
    .ktext : { *(.ktext) }
    . = 0x400;
    .data : { *(.data) }
    .bss : { *(.bss) }
}
