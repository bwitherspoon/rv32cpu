ENTRY(_start)

SECTIONS
{
    .text : { *(.text) }
    . = 0x200;
    .kern : { *(.kern) }
    .data : { *(.data) }
    .bss : { *(.bss) }
}
