#include<stdio.h>

const int N = 8;
int mem[N][N], size_occupied[256];

void debug_print() {
    for(int i = 0; i < N; i++) {
        for(int j = 0; j < N; j++)
            printf("%d, ", mem[i][j]);
        printf("\n");
    }
}

void print_mem() {
    for(int i = 0; i < N; i++) {
        for(int j = 0; j < N; j++) {
            if(mem[i][j]) {
                printf("%d: ((%d, %d), (%d, %d))\n", mem[i][j], i, j, i, j + size_occupied[mem[i][j]] - 1);
                j += size_occupied[mem[i][j]] - 1;
            }      
        }
    }
}

void ADD(int ID, int size) {
    int bytes_needed = (size + 7) / 8, start_col_index, start_line_index, is_enough_space = 0, already_in_mem = 0;
    for(int i = 0; i < N; i++) {
        for(int j = 0; j < N; j++) {
            if(mem[i][j] == ID) {
                already_in_mem = 1;
                break;
            }
        }
        if(already_in_mem)
            break;
    }

    if(!already_in_mem) {
        for(int i = 0; i < N; i++) {
            start_line_index = i;
            for(int j = 0; j < N; j++) {
                start_col_index = j;
                while(j < N && mem[i][j] == 0) {
                    if(j - start_col_index + 1 == bytes_needed) {
                        is_enough_space = 1;
                        break;
                    }
                    j++;
                }

                if(is_enough_space)
                    break;
            }
            if(is_enough_space)
                break;
        }
    }
    if(is_enough_space) {
        size_occupied[ID] = bytes_needed;

        for(int j = start_col_index; j < start_col_index + bytes_needed; j++) 
            mem[start_line_index][j] = ID;
    }
    else {
        start_line_index = 0;
        start_col_index = 0;
        bytes_needed = 1;
    }

    printf("%d: ((%d, %d), (%d, %d))\n", ID, start_line_index, start_col_index, start_line_index, start_col_index + bytes_needed - 1);
    
}

void GET(int ID) {
    for(int i = 0; i < N; i++) {
        for(int j = 0; j < N; j++) {
            if(mem[i][j] == ID) {
                printf("((%d, %d), (%d, %d))\n", i, j, i, j + size_occupied[ID] - 1);
                return;
            }
        }
    }
    printf("((%d, %d), (%d, %d))\n", 0, 0, 0, 0);
}

void DELETE(int ID) {
    for(int i = 0; i < N; i++) {
        for(int j = 0; j < N; j++) {
            if(mem[i][j] == ID)
                mem[i][j] = 0;
        }
    }
}

void DEFRAGMENTATION() {
    int last_occupied_pos, moved_ID, cant_move = 0, k;
    for(int i = 0; i < N; i++) {
        for(int j = 0; j < N - 1; j++) {
            if(!mem[i][j]) {
                for(int q = j + 1; q < N; q++) {
                    if(mem[i][q]) {
                        mem[i][j] = mem[i][q];
                        mem[i][q] = 0;
                        break;
                    }
                }
                if(!mem[i][j])
                    break;
                else
                    last_occupied_pos = j;
            }
        }

        moved_ID = 0;

        for(int q = i + 1; q < N; q++) {
            for(int j = 0; j < N; j++) {
                if(!mem[q][j]) {
                    if(size_occupied[mem[q][j]] <= N - 1 - last_occupied_pos) {
                        moved_ID = mem[q][j];
                        DELETE(moved_ID);
                        for(k = last_occupied_pos + 1; k < last_occupied_pos + 1 + size_occupied[moved_ID]; k++) {
                            mem[i][k] = moved_ID;
                        }
                        last_occupied_pos = k - 1;
                    }
                    else {
                        cant_move = 1;
                        break;
                    }
                }
            }
            if(cant_move)
                break;  
        }
        
    }
    print_mem();
}

int main() {
    int nr_total_operatii, operatie, nr_fisiere_ADD, ID, size;

    debug_print();

    scanf("%d", &nr_total_operatii);

    while(nr_total_operatii--) {
        scanf("%d", &operatie);

        if(operatie == 1) {
            scanf("%d", &nr_fisiere_ADD);
            while(nr_fisiere_ADD--) {
                scanf("%d", &ID);
                scanf("%d", &size);
                ADD(ID, size);

            }
            debug_print();
            //print_mem();
        }

        if(operatie == 2) {
            scanf("%d", &ID);
            GET(ID);
        }

        if(operatie == 3) {
            scanf("%d", &ID);
            DELETE(ID);
            print_mem();
            debug_print();
        }

        if(operatie == 4) {
            DEFRAGMENTATION();
            debug_print();
        }

    }
    return 0;
}