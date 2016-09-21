#include <stdlib.h>
#include <limits.h>

void main(void)
{
    while (1)
    {
        int n = rand();

        while (n < INT_MAX)
        {
            n += 1;
        }
    }
}
