.data
mem: .space 1027
i: .space 4
j: .space 4
nr_operatii: .space 4
nr_fisiere_add: .space 4
operatie: .space 4
ID: .space 4
size: .space 4
read_input_format: .asciz "%d"
output_print_mem: .asciz "%d: (%d, %d)\n"
output_GET: .asciz "(%d, %d)\n"

testing_output: .asciz "%d\n"
debug_text: .asciz "Am ajuns aici\n"
output_stiva_text: .asciz "start index = %d\nbytes needed = %d\nis enough space = %d\n"
element_text: .asciz "indicele curent (i): %d\n elementul curent: %d\n"
debug_text2: .asciz "start index = %d\nfinish index = %d\n"

.text
    print_mem:
        pushl %ebp
        mov %esp, %ebp

        lea mem, %edi
        ;// retinem iteratorul pentru a i reda valoarea lui curenta la finalul procedurii
        pushl i
        pushl $0 ;// va fi start_index, va fi adresat cu -8(%ebp)

        movl $0, i
        for_print_mem:
        movl i, %ecx
        cmp $1024, %ecx
        jae end_for_print_mem

            movl i, %ecx
            movb (%edi, %ecx, 1), %al
            cmp $0, %al ;// if mem[i] == 0; nu intru in if
            je print_mem_not_part_of_file
            ;// daca am intrat aici, mem[i] != 0
            movl i, %eax ;// eax = i
            movl %eax, -8(%ebp) ;// start_index = i

            while_print_mem_part_of_same_file:
            movl i, %ecx
            ;// vom avea 2 conditii de iesire din while
            cmp $1024, %ecx
            jae end_while_print_mem_part_of_same_file ;// aici e prima: i < 1024

            movb 1(%edi, %ecx, 1), %al
            cmp (%edi, %ecx, 1), %al ;// asta e a doua: mem[i] == mem[i + 1]
            jne end_while_print_mem_part_of_same_file

            movl i, %ecx
            addl $1, %ecx
            movl %ecx, i
            jmp while_print_mem_part_of_same_file

            end_while_print_mem_part_of_same_file:

            pushl i
            movl -8(%ebp), %eax ;// eax = start_index
            pushl %eax  ;// push start_index
            movl i, %ecx
            movl $0, %eax ;// golesc ax si ah
            movb (%edi, %ecx, 1), %al ;// eax = 0x000000ii, unde ii este ultimul byte si inseamna mem[i]
            pushl %eax ;// push mem[i]
            pushl $output_print_mem
            call printf
            popl %eax
            popl %eax
            popl %eax
            popl %eax

            pushl $0
            call fflush
            popl %eax

            print_mem_not_part_of_file:

        movl i, %ecx
        addl $1, %ecx
        movl %ecx, i
        jmp for_print_mem
        end_for_print_mem:

        popl %eax
        popl i
        popl %ebp
        ret
    ADD:
        pushl %ebp
        mov %esp, %ebp

        ;// 8(%ebp) va fi ID
        ;// 12(%ebp) va fi size

        ;// retinem iteratorii pentru a le reda valoarea lor curenta la finalul procedurii
        pushl i
        pushl j
        pushl $0 ;//start_index, va fi adresat cu -12(%ebp)

        ;//creez variabila bytes_needed
        movl $0, %edx
        movl 12(%ebp), %eax
        movl $8, %ebx
        div %ebx
        cmp $0, %edx
        je skip_adding_1_to_bytes_needed
        addl $1, %eax
        skip_adding_1_to_bytes_needed:

        pushl %eax ;// am dat push la bytes needed, va fi adresata cu -16(%ebp)
        pushl $0 ;// dau push la variabila is_enough_space. Va fi adresata cu -20(%ebp)

        lea mem, %edi

        movl $0, i
        for_ADD:
            movl i, %ecx
            cmp $1024, %ecx
            jae end_for_ADD

            movl i, %eax
            movl %eax, -12(%ebp) ;// start_index = i

            while_mem_i_nul:
                movl i, %ecx
                movb $0, %al 
                ;// avem 2 conditii care trebuie indeplinite pentru a continua loop ul

                cmp $1024, %ecx
                jae end_while_mem_i_nul ;// if i >= 1024, ies din loop, altfel continui (adica i < 1024)

                cmp %al, (%edi, %ecx, 1) ;// if mem[i] == 0, continui loop ul
                jne end_while_mem_i_nul

                ;// definesc in eax i - start_index + 1
                movl i, %eax
                subl -12(%ebp), %eax
                addl $1, %eax

                cmp -16(%ebp), %eax ;// if i - start_index + 1 != bytes_needed
                jne is_not_enough_space

                movl $1, -20(%ebp) ;// is_enough_space = 1
                jmp end_while_mem_i_nul ;// break

                is_not_enough_space:

                ;// iterare prin loop
                movl i, %ecx
                addl $1, %ecx
                movl %ecx, i
                jmp while_mem_i_nul
            end_while_mem_i_nul:

            movl $0, %eax
            cmp %eax, -20(%ebp) ;// if is_enough_space == 0, nu iesim din loop
            je is_not_enough_space2

            jmp end_for_ADD ;// daca am ajuns aici, atunci is_enough_space este 1, deci avem spatiu pentru  stocarea fisierului, deci dam break

            is_not_enough_space2:

            movl i, %ecx
            addl $1, %ecx
            movl %ecx, i
            jmp for_ADD
        end_for_ADD:

        movl $0, %eax
        cmp %eax, -20(%ebp) ;// if is_enough_space == 0, nu adaug fisierul pt ca n am unde
        je is_not_enough_space3

        ;// daca suntem  aici, avem loc de adaugat fisierul

        movl -12(%ebp), %eax ;// eax = start_index
        movl %eax, i ;// i = start_index

        for_ADD_file:
            movl -12(%ebp), %eax ;// eax = start_index
            addl -16(%ebp), %eax ;// eax = start_index + bytes_needed
            movl i, %ecx
            cmp %ecx, %eax ;// if i == start_index + bytes_needed, iesim din loop
            je end_for_ADD_file

                movl i, %ebx
                mov 8(%ebp), %al ;// 8(%ebp) este ID, iar elementele din mem sunt bytes, deci mut ID in al care are 1 byte
                movb %al, (%edi, %ebx, 1) ;// movb = mov byte; mem[i] = ID
            
            movl i, %ecx
            addl $1, %ecx
            movl %ecx, i
            jmp for_ADD_file
        end_for_ADD_file:
        jmp afisare_file_added ;// daca am adaugat fisierul in mem, nu vreau sa intru pe cazul in care nu am spatiu de stocare, asa ca sar direct la afisare
        is_not_enough_space3:

        movl $0, -12(%ebp) ;// start_index = 0
        movl $1, -16(%ebp) ;// bytes_needed = 1 ca sa se anuleze cu -1 de la afisare, pentru a afisa fd: (0,0) daca nu am putut adauga fisierul

        afisare_file_added:

        movl -12(%ebp), %eax ;// eax = start_index
        addl -16(%ebp), %eax ;// eax += bytes_needed
        subl $1, %eax ;// eax -= 1
        pushl %eax ;// adaug start_index + bytes_needed - 1 pe stiva pt printf

        movl -12(%ebp), %eax ;// eax = start_index
        pushl %eax ;// dau push la start_index

        movl 8(%ebp), %eax ;// eax = ID
        pushl %eax ;// dau push la ID

        pushl $output_print_mem ;// dau push la adresa string ului: "%d: (%d, %d)\n"

        call printf

        popl %eax ;// 5 push uri pt printf, deci 5 pop uri
        popl %eax
        popl %eax
        popl %eax

        pushl $0
        call fflush ;// pt afisare corecta
        popl %eax

        exit_ADD:
        popl %eax
        popl %eax
        popl %eax
        popl j
        popl i
        popl %ebp
        ret


    GET:
        pushl %ebp
        movl %esp, %ebp
        ;// 8(%ebp) va fi ID

        lea mem, %edi

        pushl i ;// salvez valoarea lui i de dinainte de apelarea programului pentru a o restaura la final
        pushl $0 ;// start_index, va fi -8(%ebp)
        pushl $0 ;// finish_index, va fi -12(%ebp)

        movl $0, i

        for_GET:
        movl i, %ecx
        cmp $1024, %ecx
        jae end_for_GET

            movl i, %eax ;// eax = i
            movl %eax, -8(%ebp) ;// start_index = i

            while_GET_found_file:
            movl i, %ecx
            ;// avem 2 conditii de iesire din while
            cmp $1024, %ecx
            jae end_while_GET_found_file ;// prima conditie: i < 1024

            mov 8(%ebp), %al
            cmp (%edi, %ecx, 1), %al
            jne end_while_GET_found_file ;// a doua conditie: mem[i] != ID; daca se indeplineste, iesim din while

            movl i, %ecx
            addl $1, %ecx
            movl %ecx, i
            jmp while_GET_found_file
            end_while_GET_found_file:

            movl i, %eax
            subl $1, %eax
            movl %eax, -12(%ebp) ;// finish_index = i - 1

            movl -8(%ebp), %eax ;// eax = start_index
            movl -12(%ebp), %ebx
            cmp %ebx, %eax ;// cmp finish_index, start_index
            stop:
            jge GET_not_the_searched_file ;// if start_index >= finish_index, n am gasit fisierul cautat (tehnic, nu pot fi niciodata egale, but w/e)

            ;// daca am ajuns aici, am gasit start si finish index de la fisierul cautat
            jmp end_for_GET ;// dam break

            GET_not_the_searched_file:

        movl i, %ecx
        addl $1, %ecx
        movl %ecx, i
        jmp for_GET
        end_for_GET:

        movl -8(%ebp), %eax ;// eax = start_index
        cmp -12(%ebp), %eax ;// cmp finish_index, start_index
        jbe GET_found_file ;// daca start_index <= finish_index, inseamna ca am gasit fisierul, deci dam jump sa il afisam, altfel intram pe ramura asta, unde afisam (0, 0) (again, tehnic nu au cum sa fie egale start si finish, but w/e)
        ;// daca am ajuns aici, nu am gasit fisierul
        pushl $0
        pushl $0
        pushl $output_GET
        call printf
        popl %eax
        popl %eax
        popl %eax

        pushl $0
        call fflush
        popl %eax
        jmp exit_GET ;// ca sa nu intru pe ramura in care am gasit fisierul, sar direct la exit
        GET_found_file:

        movl -12(%ebp), %eax ;// eax = finish_index
        pushl %eax
        movl -8(%ebp), %eax ;// eax = start_index
        pushl %eax
        pushl $output_GET
        call printf
        popl %eax
        popl %eax
        popl %eax

        pushl $0
        call fflush
        popl %eax

        exit_GET:
        popl %eax
        popl %eax
        popl i
        popl %ebp
        ret
    DELETE:
        pushl %ebp
        movl %esp, %ebp

        ;// 8(%ebp) va fi ID

        lea mem, %edi
        ;//pushl i ;// same drill, introduc i pe stiva ca sa ii restaurez valoarea dupa executarea procedurii

        movl $0, %ecx

        for_DELETE:
        cmp $1024, %ecx
        jae end_for_DELETE

            mov 8(%ebp), %al
            cmp (%edi, %ecx, 1), %al 
            jne DELETE_not_the_searched_file ;// if mem[i] != ID
            ;// daca sunt aici, mem[i] == ID
            movb $0, (%edi, %ecx, 1)
            DELETE_not_the_searched_file:

        addl $1, %ecx
        jmp for_DELETE
        end_for_DELETE:

        ;//popl i

        call print_mem

        popl %ebp
        ret


    DEFRAGMENTATION:
        pushl %ebp
        movl %esp, %ebp

        lea mem, %edi
        pushl i
        pushl j

        movl $0, i
        for_DEFRAGMENTATION:
        movl i, %ecx
        cmp $1023, %ecx
        jae end_for_DEFRAGMENTATION

            movb $0, %al
            movl i, %ecx
            cmp (%edi, %ecx, 1), %al
            jne DEFRAGMENTATION_mem_i_not_nul ;// if mem[i] != 0, trecem peste, ne intereseaza doar 0-urile

                movl i, %ecx
                addl $1, %ecx
                movl %ecx, j ;// j = i + 1
                for_searching_non_nul_element:
                movl j, %ecx
                cmp $1024, %ecx
                jae end_for_searching_non_nul_element

                    movb $0, %al
                    movl j, %ecx
                    cmp (%edi, %ecx, 1), %al
                    je DEFRAGMENTATION_mem_i_is_nul ;// if mem[j] = 0, dam skip
                        movl j, %ecx
                        movb (%edi, %ecx, 1), %al ;// al = mem[j]
                        movl i, %ecx
                        movb %al, (%edi, %ecx, 1) ;// mem[i] = al
                        movl j, %ecx
                        movb $0, (%edi, %ecx, 1) ;// mem[j] = 0
                        jmp end_for_searching_non_nul_element ;// break

                    DEFRAGMENTATION_mem_i_is_nul:

                movl j, %ecx
                addl $1, %ecx
                movl %ecx, j
                jmp for_searching_non_nul_element
                end_for_searching_non_nul_element:

                movl i, %ecx
                movb $0, %al
                cmp (%edi, %ecx, 1), %al
                jne DEFRAGMENTATION_dont_break ;// if mem[i] = 0 dupa ce am incercat sa il interschimbam cu un element nenul din memorie, inseamna ca nu am mai gasit un element nenul in memorie, deci nu are sens sa mai parcurgem

                    jmp end_for_DEFRAGMENTATION ;// break

                DEFRAGMENTATION_dont_break:

            DEFRAGMENTATION_mem_i_not_nul:

        movl i, %ecx
        addl $1, %ecx
        movl %ecx, i
        jmp for_DEFRAGMENTATION
        end_for_DEFRAGMENTATION:

        call print_mem

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
    