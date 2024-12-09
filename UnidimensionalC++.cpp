#include <cstdio>

using namespace std;

int mem[1000];

void print_mem() {
    int start_index, finish_index;
    for(int i = 0; i < 999; i++) {
        if(mem[i] != mem[i + 1]) {
            if(mem[i] && )
            start_index = i;
        }
    }
}

void ADD(int ID, int size) {
    int empty_bytes = 0, bytes_needed = size / 8 + (size % 8 == 0 ? 0 : 1), start_index, finish_index = 0, is_enough_space = 0;
    for(int i = 0; i < 1000; i++) {
        start_index = i;
        while(mem[i] == 0) {
            if(i - start_index + 1 == bytes_needed)
                is_enough_space = 1;
                finish_index = i;
                break;
            i++;
        }
        if(is_enough_space)
            break;
    }
    for(int i = start_index; i <= finish_index; i++) {
        mem[i] = ID;
    }

}

void GET(int ID) {
    int start_index = 0, finish_index = 0;
    for(int i = 0; i < 1000; i++) {
        start_index = i;
        while(mem[i] == ID) {
            finish_index = i;
            i++;
        }
    }
    if(finish_index == 0) {
        printf("(%d, %d)\n", 0, 0);
    }
    else {
        printf("(%d, %d)\n", start_index, finish_index);
    }
}

void DELETE(int ID) {

}

void DEFRAGMENTATION() {

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

    return 0;
}