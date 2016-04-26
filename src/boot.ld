ENTRY(init)

SECTIONS
{
    .init : { *(.init) }
    .text : { *(.text) }
    . = 0x200;
    .kern : { *(.kern) }
    . = 0x400;
    .user : { *(.user) }
    . = 0x1000;
    .data : { *(.data) }
    .bss  : { *(.bss) }
}
