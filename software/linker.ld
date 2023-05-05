MEMORY
{
    ram (rwx) : ORIGIN = 0x00000000, LENGTH = 32K
}

ENTRY(_start)

SECTIONS
{
    .text :
    {
        *(.text)
    } > ram

    .rodata :
    {
        *(.rodata)
    } > ram

    .data :
    {
        *(.data)
    } > ram

    .bss :
    {
        *(.bss)
    } > ram
}