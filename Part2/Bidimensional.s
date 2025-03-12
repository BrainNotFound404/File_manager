.data
mem: .space 1048579
size_occupied: .space 1024 ;// este un array de long uri in care voi retine cat spatiu ocupa fiecare file din mem
N: .long 1024
i: .long 0
j: .long 0
q: .long 0
k: .long 0
nr_operatii: .space 4
nr_fisiere_add: .space 4
operatie: .space 4
ID: .space 4
size: .space 4
read_input_format: .asciz "%d"
output_print_mem: .asciz "%d: ((%d, %d), (%d, %d))\n"
output_GET: .asciz "((%d, %d), (%d, %d))\n"

debug_text: .asciz "Am ajuns aici!\n"

.text
    print_mem:
        pushl %ebp
        mov %esp, %ebp

        pushl i
        pushl j

        movl $0, i
        for_print_mem_line:
        movl i, %ecx
        cmp N, %ecx
        jae end_for_print_mem_line

            movl $0, j
            for_print_mem_col:
            movl j, %ecx
            cmp N, %ecx
            jae end_for_print_mem_col

                movl N, %eax
                mull i
                addl j, %eax
                lea mem, %edi
                xorl %ebx, %ebx
                movb (%edi, %eax, 1), %bl ;// fac mem + N * i + j, iar asa accesez mem[i][j]
                cmp $0, %bl ;// 
                je print_mem_is_nul

                ;// daca am ajuns aici, atunci mem[i][j] != 0
                    lea size_occupied, %edi
                    movl (%edi, %ebx, 4), %eax ;// in eax este acum size_occupied[mem[i][j]] ;// ebx este mem[i][j]
                    addl j, %eax ;// eax = j + size_occupied[mem[i][j]]
                    subl $1, %eax ;// eax = j + size_occupied[mem[i][j]] - 1
                    pushl %eax
                    pushl i
                    pushl j
                    pushl i

                    lea mem, %edi ;// acum o sa accesez mem[i][j] iar
                    movl N, %eax
                    mull i
                    addl j, %eax
                    xorl %ebx, %ebx ;// ma asigur ca in ebx e 0 intainte sa bag in bl ceva
                    movb (%edi, %eax, 1), %bl
                    pushl %ebx ;// am dat push la mem[i][j]
                    pushl $output_print_mem

                    call printf

                    popl %eax
                    popl %eax
                    popl %eax
                    popl %eax
                    popl %eax
                    popl %eax

                    pushl $0
                    call fflush
                    popl %eax

                    movl j, %ecx ;// acum vreau sa fac j += size_occupied[mem[i][j]] - 1
                    subl $1, %ecx
                    lea mem, %edi ;// acum o sa accesez mem[i][j] iar
                    movl N, %eax
                    mull i
                    addl j, %eax
                    xorl %ebx, %ebx ;// ma asigur ca in ebx e 0 intainte sa bag in bl ceva
                    movb (%edi, %eax, 1), %bl ;// acum am in ebx mem[i][j]

                    lea size_occupied, %edi
                    movl (%edi, %ebx, 4), %eax ;// am pus in al size_occupied[mem[i][j]], deci am in eax asta
                    addl %eax, %ecx
                    movl %ecx, j


                print_mem_is_nul:

            movl j, %ecx
            addl $1, %ecx
            movl %ecx, j
            jmp for_print_mem_col
            end_for_print_mem_col:

        movl i, %ecx
        addl $1, %ecx
        movl %ecx, i
        jmp for_print_mem_line
        end_for_print_mem_line:

        popl j
        popl i
        popl %ebp
        ret
    ADD:
        pushl %ebp
        mov %esp, %ebp
        ;// 8(%ebp) este ID, iar 12(%ebp) este size
        pushl i
        pushl j
        pushl $0 ;// va fi start_line_index si va fi  adresat cu -12(%ebp)
        pushl $0 ;// va fi start_col_index si va fi  adresat cu -16(%ebp)
        movl 12(%ebp), %eax
        addl $7, %eax
        xorl %edx, %edx
        movl $8, %ecx
        div %ecx
        pushl %eax ;// am dat push la bytes_needed = (size + 7) / 8, -20(%ebp)
        pushl $0 ;// is_enough_space, va fi -24(%ebp)
        pushl $0 ;// already_in_mem, va fi adresat cu -28(%ebp)

            movl $0, i
            for_ADD_linie1: ;// for(int i = 0; i < N; i++)
            movl i, %ecx
            cmp N, %ecx
            jae end_for_ADD_linie1

                movl $0, j
                for_ADD_col1: ;// for(int j = 0; j < N; j++)
                movl j, %ecx
                cmp N, %ecx
                jae end_for_ADD_col1

                    lea mem, %edi ;// fac mem[i][j]
                    movl N, %eax
                    mull i
                    addl j, %eax
                    xorl %ebx, %ebx
                    movb (%edi, %eax, 1), %bl ;// am in bl mem[i][j]
                    cmp 8(%ebp), %ebx ;// if mem[i][j] == ID
                    jne ADD_is_not_in_memory
                    ;// daca am ajuns aici, atunci mem[i][j] == ID
                    movl $1, -28(%ebp)
                    jmp end_for_ADD_linie1

                    ADD_is_not_in_memory:

                movl j, %ecx
                addl $1, %ecx
                movl %ecx, j
                jmp for_ADD_col1
                end_for_ADD_col1:


            movl i, %ecx
            addl $1, %ecx
            movl %ecx, i
            jmp for_ADD_linie1
            end_for_ADD_linie1:

            movl -28(%ebp), %eax ;// eax = already_in_mem
            cmp $0, %eax
            jne ADD_was_already_in_mem
            ;// daca am ajuns aici, atunci ID ul pe care vrem sa il adaugam nu este in memorie deja

                movl $0, i
                for_ADD_linie2: ;// for(int i = 0; i < N; i++)
                movl i, %ecx
                cmp N, %ecx
                jae end_for_ADD_linie2

                    movl i, %ecx
                    movl %ecx, -12(%ebp) ;// start_line_index = i

                    movl $0, j
                    for_ADD_col2: ;// for(int j = 0; j < N; j++)
                    movl j, %ecx
                    cmp N, %ecx
                    jae end_for_ADD_col2

                        movl j, %ecx
                        movl %ecx, -16(%ebp) ;// start_col_index = j
                        while_ADD_mem_i_j_nul:
                        ;// avem 2 conditii de iesire din while
                        cmp N, %ecx
                        jae end_while_ADD_mem_i_j_nul ;// while j < N
                        
                        movl N, %eax
                        mull i
                        addl j, %eax
                        movb (%edi, %eax, 1), %bl
                        cmp $0, %bl
                        jne end_while_ADD_mem_i_j_nul ;// while mem[i][j] == 0 (in bl este mem[i][j])

                            movl j, %eax
                            subl -16(%ebp), %eax ;// eax = j - start_col_index
                            addl $1, %eax ;// eax++
                            cmp -20(%ebp), %eax
                            jne ADD_not_enough_space
                            ;// daca suntem aici, atunci am gasit indeajuns de mult spatiu incat sa adaugam fisierul
                            movl $1, -24(%ebp) ;// is_enough_space = 1
                            jmp end_for_ADD_linie2 ;// ies din toate loop-urile

                            ADD_not_enough_space:

                        movl j, %ecx
                        addl $1, %ecx
                        movl %ecx, j
                        jmp while_ADD_mem_i_j_nul
                        end_while_ADD_mem_i_j_nul:


                    movl j, %ecx
                    addl $1, %ecx
                    movl %ecx, j
                    jmp for_ADD_col2
                    end_for_ADD_col2:



                movl i, %ecx
                addl $1, %ecx
                movl %ecx, i
                jmp for_ADD_linie2
                end_for_ADD_linie2:

            ADD_was_already_in_mem:

            

            movl -24(%ebp), %eax
            cmp $0, %eax
            je ADD_was_not_enough_space
            ;// daca suntem aici, atunci is_enough_space = 1
            lea size_occupied, %edi
            movl 8(%ebp), %eax ;// eax = ID
            movl -20(%ebp), %ebx ;// ebx = bytes_needed
            movl %ebx, (%edi, %eax, 4) ;// size_occupied[ID] = bytes_needed

            movl -16(%ebp), %ecx
            movl %ecx, j
            for_ADD_file_in_mem: ;// for(int j = start_col_index; j < start_col_index + bytes_needed; j++) 
            movl j, %ecx
            movl -16(%ebp), %eax
            addl -20(%ebp), %eax ;// eax = start_col_index + bytes_needed
            cmp %eax, %ecx
            jae end_for_ADD_file_in_mem 

                lea mem, %edi
                movl N, %eax
                mull -12(%ebp)
                addl j, %eax ;// eax = N * start_line_index + j, pentru a accesa mem[start_line_index][j]
                movl 8(%ebp), %ebx
                movb %bl, (%edi, %eax, 1)

            movl j, %ecx
            addl $1, %ecx
            movl %ecx, j
            jmp for_ADD_file_in_mem
            end_for_ADD_file_in_mem:

            jmp ADD_print
            ADD_was_not_enough_space:
            ;// daca am ajuns aici, atunci nu avem indeajuns de mult spatiu de stocare
                movl $0, -12(%ebp)
                movl $0, -16(%ebp)
                movl $1, -20(%ebp)

            ADD_print:

            movl -16(%ebp), %eax
            addl -20(%ebp), %eax
            subl $1, %eax
            pushl %eax ;// am dat push la start_col_index + bytes_needed - 1
            movl -12(%ebp), %eax
            pushl %eax ;// am dat push la start_line_index
            movl -16(%ebp), %eax
            pushl %eax ;// am dat push la start_col_index
            movl -12(%ebp), %eax
            pushl %eax ;// am dat push la start_line_index
            movl 8(%ebp), %eax
            pushl %eax ;// am dat push la ID
            pushl $output_print_mem

            call printf 
            
            popl %eax
            popl %eax
            popl %eax
            popl %eax
            popl %eax
            popl %eax

            pushl $0
            call fflush
            popl %eax

        exit_ADD:
        popl %eax
        popl %eax
        popl %eax
        popl %eax
        popl %eax
        popl j
        popl i
        popl %ebp
        ret
    GET:
        pushl %ebp
        mov %esp, %ebp
        pushl i
        pushl j

            movl $0, i
            for_GET_line:
            movl i, %ecx
            cmp N, %ecx
            jae end_for_GET_line

                movl $0, j
                for_GET_col:
                movl j, %ecx
                cmp N, %ecx
                jae end_for_GET_col

                    lea mem, %edi
                    movl N, %eax
                    mull i
                    addl j, %eax
                    xorl %ebx, %ebx
                    movb (%edi, %eax, 1), %bl
                    cmp 8(%ebp), %ebx ;// if mem[i][j] == ID
                    jne GET_not_wanted_file
                    ;// daca am ajuns aici, atunci mem[i][j] == ID
                    lea size_occupied, %edi
                    movl 8(%ebp), %eax
                    movl j, %ebx
                    addl (%edi, %eax, 4), %ebx
                    subl $1, %ebx
                    pushl %ebx ;// am dat push la j + size_occupied[ID] - 1
                    pushl i
                    pushl j
                    pushl i
                    pushl $output_GET

                    call printf

                    popl %eax
                    popl %eax
                    popl %eax
                    popl %eax
                    popl %eax

                    pushl $0
                    call fflush
                    popl %eax

                    jmp exit_GET

                    GET_not_wanted_file:

                movl j, %ecx
                addl $1, %ecx
                movl %ecx, j
                jmp for_GET_col
                end_for_GET_col:

            movl i, %ecx
            addl $1, %ecx
            movl %ecx, i
            jmp for_GET_line
            end_for_GET_line:

            pushl $0
            pushl $0
            pushl $0
            pushl $0
            pushl $output_GET

            call printf

            popl %eax
            popl %eax
            popl %eax
            popl %eax
            popl %eax

            pushl $0
            call fflush
            popl %eax

        exit_GET:
        popl j
        popl i
        popl %ebp
        ret
    DELETE:
        pushl %ebp
        mov %esp, %ebp
        pushl i
        pushl j

            movl $0, i
            for_DELETE_line:
            movl i, %ecx
            cmp N, %ecx
            jae end_for_DELETE_line

                movl $0, j
                for_DELETE_col:
                movl j, %ecx
                cmp N, %ecx
                jae end_for_DELETE_col

                    lea mem, %edi
                    movl N, %eax
                    mull i
                    addl j, %eax
                    xorl %ebx, %ebx
                    movb (%edi, %eax, 1), %bl
                    cmp 8(%ebp), %ebx ;// cmp ID cu mem[i][j]
                    jne DELETE_not_wanted_file
                    ;// daca am ajuns aici, atunci mem[i][j] == ID
                    movb $0, (%edi, %eax, 1)

                    DELETE_not_wanted_file:

                movl j, %ecx
                addl $1, %ecx
                movl %ecx, j
                jmp for_DELETE_col
                end_for_DELETE_col:

            movl i, %ecx
            addl $1, %ecx
            movl %ecx, i
            jmp for_DELETE_line
            end_for_DELETE_line:

        exit_DELETE:
        popl j
        popl i
        popl %ebp
        ret

    DEFRAGMENTATION:
    pushl %ebp
    mov %esp, %ebp
    pushl i
    pushl j
    pushl $0 ;// last_occupied_pos -12(%ebp)
    pushl $0 ;// moved_ID -16(%ebp)
    pushl $0 ;// cant_move -20(%ebp)

        movl $0, i
        for_DEFRAGMENTATION_linie1:
        movl i, %ecx
        cmp N, %ecx
        jae end_for_DEFRAGMENTATION_linie1

            movl $0, j
            for_DEFRAGMENTATION_col1:
            movl j, %ecx
            movl N, %eax
            subl $1, %eax
            cmp %eax, %ecx
            jae end_for_DEFRAGMENTATION_col1

                lea mem, %edi
                movl N, %eax
                mull i
                addl j, %eax
                movb (%edi, %eax, 1), %bl
                cmp $0, %bl
                jne DEFRAGMENTATION_is_not_nul

                    movl j, %ecx
                    addl $1, %ecx
                    movl %ecx, q
                    for_DEFRAGMENTATION_part1:
                    movl q, %ecx
                    cmp N, %ecx
                    jae end_for_DEFRAGMENTATION_part1

                        movl N, %eax
                        mull i
                        addl q, %eax
                        movl $0, %ebx
                        cmp (%edi, %eax, 1), %ebx
                        je DEFRAGMENTATION_was_nul
                            subl q, %eax ;// acum eax este N * i
                            movb q(%edi, %eax, 1), %bl
                            movb %bl, j(%edi, %eax, 1)
                            movb $0, q(%edi, %eax, 1)
                            jmp end_for_DEFRAGMENTATION_part1

                        DEFRAGMENTATION_was_nul:

                        movl N, %eax
                        mull i
                        addl j, %eax
                        movl $0, %ebx
                        cmp (%edi, %eax, 1), %ebx
                        jne end_for_DEFRAGMENTATION_part1 ;// daca dupa ce am inlocuit in teorie elementul nul cu un element nenul este in continuare nul, atunci nu am mai gasit elemente nenule pe linia curenta, deci opresc for ul
                        ;// daca am ajuns aici, atunci am gasit un element nenul cu care sa inlocuiesc elementul nul
                        movl j, %ecx
                        movl %ecx, -12(%ebp)
                        

                    movl q, %ecx
                    addl $1, %ecx
                    movl %ecx, q
                    jmp for_DEFRAGMENTATION_part1
                    end_for_DEFRAGMENTATION_part1:

                DEFRAGMENTATION_is_not_nul:


            movl j, %ecx
            addl $1, %ecx
            movl %ecx, j
            jmp for_DEFRAGMENTATION_col1
            end_for_DEFRAGMENTATION_col1:

            movl $0, -16(%ebp)



            movl i, %eax
            addl $1, %eax
            cmp N, %eax
            jae DEFRAGMENTATION_dont_do_linie2

            movl %eax, q
            for_DEFRAGMENTATION_linie2:
            movl q, %ecx
            cmp N, %ecx
            jae end_for_DEFRAGMENTATION_linie2

                movl $0, j
                for_DEFRAGMENTATION_col2:
                movl j, %ecx
                cmp N, %ecx
                jae end_for_DEFRAGMENTATION_col2

                    lea mem, %edi
                    movl N, %eax
                    mull q
                    addl j, %eax
                    movl $0, %ebx
                    cmp (%edi, %eax, 1), %ebx
                    jne DEFRAGMENTATION_is_not_nul2
                        xorl %ebx, %ebx
                        movb (%edi, %eax, 1), %bl ;// ebx = mem[q][j]
                        lea size_occupied, %edi
                        movl (%edi, %ebx, 4), %eax ;// eax = size_occupied[mem[q][j]]
                        movl N, %edx
                        subl $1, %edx
                        subl -12(%ebp), %edx ;// edx = N - 1 - last_occupied_pos
                        cmp %eax, %edx
                        jb DEFRAGMENTATION_is_not_enough_space
                        ;// daca am ajuns aici, atunci size_occupied[mem[q][j]] <= N - 1 - last_occupied_pos
                        lea mem, %edi
                        movl N, %eax
                        mull q
                        addl j, %eax
                        xorl %ebx, %ebx
                        movb (%edi, %eax, 1), %bl
                        movl %ebx, -16(%ebp) ;// moved_ID = mem[q][j]

                        call DELETE

                        movl -12(%ebp), %eax ;// eax = last_occupied_pos
                        addl $1, %eax ;// eax++
                        movl %eax, k
                        for_DEFRAGMENTATION_part2:
                        movl k, %ecx
                        lea size_occupied, %edi
                        movl -16(%ebp), %eax ;// eax = moved_ID
                        movl (%edi, %eax, 4), %ebx ;// ebx = size_occupied[moved_ID]
                        addl -12(%ebp), %ebx;// ebx += last_occupied_pos
                        addl $1, %ebx ;// ebx ++
                        cmp %ebx, %ecx
                        jae end_for_DEFRAGMENTATION_part2

                            lea mem, %edi
                            movl N, %eax
                            mull i
                            addl k, %eax
                            movl -16(%ebp), %ebx ;// ebx = moved_ID
                            movb %bl, (%edi, %eax, 1) ;// mem[i][k] = moved_ID

                        movl k, %ecx
                        addl $1, %ecx
                        movl %ecx, k
                        jmp for_DEFRAGMENTATION_part2
                        end_for_DEFRAGMENTATION_part2:

                        movl k, %ebx
                        subl $1, %ebx
                        movl %ebx, -12(%ebp) ;// last_occupied_pos = k - 1

                        jmp DEFRAGMENTATION_is_not_nul2

                        DEFRAGMENTATION_is_not_enough_space:
                        ;// daca am ajuns aici, am intrat pe else, adica size_occupied[mem[q][j]] > N - 1 - last_occupied_pos
                        movl $1, -20(%ebp) ;// cant_move = 1
                        jmp end_for_DEFRAGMENTATION_linie2

                    DEFRAGMENTATION_is_not_nul2:

                movl j, %ecx
                addl $1, %ecx
                movl %ecx, j
                jmp for_DEFRAGMENTATION_col2
                end_for_DEFRAGMENTATION_col2:

            movl q, %ecx
            addl $1, %ecx
            movl %ecx, q
            jmp for_DEFRAGMENTATION_linie2
            end_for_DEFRAGMENTATION_linie2:

            DEFRAGMENTATION_dont_do_linie2:

        movl i, %ecx
        addl $1, %ecx
        movl %ecx, i
        jmp for_DEFRAGMENTATION_linie1
        end_for_DEFRAGMENTATION_linie1:

        call printf
    
    popl %eax
    popl %eax
    popl %eax
    popl %eax
    popl %eax
    popl j
    popl i
    popl %ebp
    ret

.global main
main:
    pushl $nr_operatii
    pushl $read_input_format
    call scanf
    popl %eax
    popl %eax


    movl $0, i

    for_nr_operatii:
        movl i, %ecx
        cmp nr_operatii, %ecx
        je end_for_nr_operatii

        ;// citim operatia pe care trebuie sa o efectuam
        pushl $operatie
        pushl $read_input_format
        call scanf
        popl %eax
        popl %eax

        if_operatie:
            is_ADD:
            movl operatie, %eax
            cmp $1, %eax
            jne was_not_ADD
            ;// ajung aici doar daca operatia este ADD
                pushl $nr_fisiere_add
                pushl $read_input_format
                call scanf
                popl %eax
                popl %eax

                movl $0, j

                for_nr_fisiere_add:
                movl j, %ecx
                cmp nr_fisiere_add, %ecx
                je end_for_nr_fisiere_add

                    ;// citim ID
                    pushl $ID
                    pushl $read_input_format
                    call scanf
                    popl %eax
                    popl %eax

                    ;// citim size
                    pushl $size
                    pushl $read_input_format
                    call scanf
                    popl %eax
                    popl %eax

                    pushl size
                    pushl ID
                    call ADD
                    popl %eax
                    popl %eax

                movl j, %ecx
                addl $1, %ecx
                movl %ecx, j
                jmp for_nr_fisiere_add
                end_for_nr_fisiere_add:

            jmp end_if_operatie ;// fac asta DOAR daca am intrat pe cazul curent si nu mai e nevoie sa le verific pe celelalte
            was_not_ADD:

            is_GET:
            movl operatie, %eax
            cmp $2, %eax
            jne was_not_GET

            pushl $ID
            pushl $read_input_format
            call scanf
            popl %eax
            popl %eax

            pushl ID
            call GET
            popl %eax

            jmp end_if_operatie ;// fac asta DOAR daca am intrat pe cazul curent si nu mai e nevoie sa le verific pe celelalte
            was_not_GET:

            is_DELETE:
            movl operatie, %eax
            cmp $3, %eax
            jne was_not_DELETE

            pushl $ID
            pushl $read_input_format
            call scanf
            popl %eax
            popl %eax

            pushl ID
            call DELETE
            popl %eax

            call print_mem

            jmp end_if_operatie ;// fac asta DOAR daca am intrat pe cazul curent si nu mai e nevoie sa le verific pe celelalte
            was_not_DELETE:

            is_DEFRAGMENTATION:
            ;// Daca am ajuns aici, atunci operatie este DEFRAGMENTATION

            call DEFRAGMENTATION

        end_if_operatie:

        movl i, %ecx
        addl $1, %ecx
        movl %ecx, i
        jmp for_nr_operatii
    end_for_nr_operatii:

    ;// debug
    ;//lea mem, %edi
    ;//movl $0, i
    ;//for_afisare_mem:
    ;//movl i, %ecx
    ;//cmp $220, %ecx
    ;//jae end_for_afisare_mem

        ;//movl i, %ecx
        ;//movl $0, %eax
        ;//movb (%edi, %ecx, 1), %al
        ;//pushl %eax
        ;//pushl $testing_output
        ;//call printf
        ;//popl %eax
        ;//popl %eax
        ;//pushl $0
        ;//call fflush
        ;//popl %eax

    ;//movl i, %ecx
    ;//addl $1, %ecx
    ;//movl %ecx, i
    ;//jmp for_afisare_mem
    ;//end_for_afisare_mem:
    ;//debug

    exit_main:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

