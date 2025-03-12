#include <cstdio>

using namespace std;

int mem[1024];

void print_mem() {
    int start_index;
    for(int i = 0; i < 1024; i++) {
        if(mem[i]) {
            start_index = i;
            while(i < 1023 && mem[i] == mem[i + 1]) {
                i++;
            }
                
            printf("%d: (%d, %d)\n", mem[i], start_index, i);
        }
        
    }
}

void ADD(int ID, int size) {
    int bytes_needed = (size + 7) / 8, start_index, is_enough_space = 0;
    for(int i = 0; i < 1024; i++) {
        start_index = i;
        while(mem[i] == 0 && i < 1024) {
            if(i - start_index + 1 == bytes_needed) {
                is_enough_space = 1;
                break;
            }
            i++;
        }
        if(is_enough_space)
            break;
    }
    if(is_enough_space) {
        for(int i = start_index; i < start_index + bytes_needed; i++) {
            mem[i] = ID;
        }
    }
    else {
        start_index = 0;
        bytes_needed = 1;
    }

    printf("%d: (%d, %d)\n", ID, start_index, start_index + bytes_needed - 1);
    

}

void GET(int ID) {
    int start_index = 0, finish_index;
    for(int i = 0; i < 1024; i++) {
        start_index = i;
        while(i < 1024 && mem[i] == ID) {
            i++;
        }
        finish_index = i - 1;
        if(start_index < finish_index)
            break;

    }
    if(start_index > finish_index) {
        printf("(%d, %d)\n", 0, 0);
    }
    else {
        printf("(%d, %d)\n", start_index, finish_index);
    }
}

void DELETE(int ID) {
    for(int i = 0; i < 1024; i++) {
        if(mem[i] == ID)
            mem[i] = 0;
    }

    print_mem();
}

void DEFRAGMENTATION() {
    for(int i = 0; i < 1023; i++) {
        if(!mem[i]) {
            for(int j = i + 1; j < 1024; j++) {
                if(mem[j]) {
                    mem[i] = mem[j];
                    mem[j] = 0;
                    break;
                }
            }
            if(!mem[i])
                break;
        }
    }
    print_mem();
}

int main() {
    int nr_total_operatii, operatie, nr_fisiere_ADD, ID, size;

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
            //print_mem();
        }

        if(operatie == 2) {
            scanf("%d", &ID);
            GET(ID);
        }

        if(operatie == 3) {
            scanf("%d", &ID);
            DELETE(ID);
        }

        if(operatie == 4) {
            DEFRAGMENTATION();
        }

    }
    print_mem();

    return 0;
}