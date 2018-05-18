/*
 * Memory usage: 2 * n * sizeof(int) + O(1)
 *
 * For 1_000_000 families, with 32-bit int (likely), that's 8 MB.
 */
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#define NFAMILIES 1000000

struct family {
    int girls;
    bool boy;
};

typedef struct family* village_t;

bool one_in(int n) {
    return rand() % n == 0;
}

village_t create_village(size_t nfamilies)
{
    village_t result = calloc(nfamilies, sizeof(struct family));
    if (! result) {
        perror("villages");
        exit(1);
    }

    for (size_t i = 0; i < nfamilies; ++i) {
        if (!one_in(4)) { // wants first child
            do {
                if (one_in(2)) { // child is boy
                    result[i].boy = true;
                    break;
                } else {
                    ++result[i].girls;
                }
            } while (one_in(4));
        }
    }

    return result;
}

void destroy_village(village_t village)
{
    free(village);
}

int count_children(village_t village, size_t nfamilies)
{
    int result = 0;

    for (size_t i = 0; i < nfamilies; ++i) {
        result += village[i].girls + village[i].boy;
    }

    return result;
}

double avg_children_per_family(village_t village, size_t nfamilies)
{
    return count_children(village, nfamilies) / (double)nfamilies;
}

int main()
{
    village_t village = create_village(NFAMILIES);
    printf("%f\n", avg_children_per_family(village, NFAMILIES));
    destroy_village(village);
}
