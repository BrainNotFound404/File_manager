.data
i: .space 4
v: .space 4
format_Output: .asciz "%d\n"
.text
.global main
main:
    lea v, %edi
    movl $0, i

    for:
        movl i, %ecx
        cmp $4, %ecx
        je end_for

        mov i, %al
        movl i, %ecx
        movb %al, (%edi, %ecx, 1) ;// edi + ecx * 1

        movl $0, %eax
        movb (%edi, %ecx, 1), %al
        pushl %eax
        pushl $format_Output
        call printf
        popl %eax
        popl %eax

        pushl $0
        call fflush
        popl %eax 

        movl i, %ecx
        addl $1, %ecx
        movl %ecx, i
        jmp for
    end_for:

exit_main:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
    