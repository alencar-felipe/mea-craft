MEMORY
{
    rom (rx)    : ORIGIN = 0x00000000, LENGTH = 4096
    ram (rwx)   : ORIGIN = 0x10000000, LENGTH = 65536
}

ENTRY(bootldr)

__heap_size = 1024;
__stack_size = 1024;

SECTIONS
{   
    .init :
    {   
        *(.init)
    } > rom 

    .text :
    {
        *(.text*)
    } > ram

    .rodata :
    {
        *(.rodata*)
    } > ram

    .data :
    {
        *(.data)
    } > ram

    .bss :
    {
        . = ALIGN(4);
        _sbss = .;

        *(.bss)
    
        . = ALIGN(4);
        _ebss = .;
    } > ram

    .stack :
    {
        . = ALIGN(4);
        _sstack = .;

        . = . + __stack_size;

        . = ALIGN(4);
        _estack = .;
    } > ram

    .heap :
    {
        . = ALIGN(4);
        _sheap = .;

        . = . + __heap_size;

        . = ALIGN(4);
        _eheap = .;
    } > ram  
}