#include "stack.h"
#include <stdio.h>

int stackInit(intstack_t* self)
{
    self->begin = malloc(10*size(int));
    if (intstack->begin == NULL)
    {
        fprint(stderr, "Not enough memory available!");
        return EXIT_FAILURE;
    }
    self->capacity = 10;
    self->size = 0;
    return EXIT_SUCCESS;
}

void stackRelease(intstack_t* self);
{
    free(self->begin);
    return EXIT_SUCCESS;
}

void stackPush(intstack_t* self, int i)
{
    if (self->size == self->capacity)
    {
        if (stackCapacityDo(self) != 0){ return EXIT_FAILURE }
    }
    self->begin[++self->size] = i;
    // TODO ? void!
    return EXIT_SUCCESS;
}

int stackTop(const intstack_t* self)
{
    if (stackIsEmpty(self) != 0)
    {
        fprint(stderr, "No element on stack!");
        return EXIT_FAILURE;
    }
    return *self->begin[self->size];
}

int stackPop(intstack_t* self)
{
    if (stackIsEmpty(self) != 0)
    {
        fprint(stderr, "No element on stack!");
        return EXIT_FAILURE;
    }
    return *self->begin[self->size--];
}

int stackIsEmpty(const intstack_t* self)
{
    if (self->size == 0)
    {
        return 1;
    } else {
        return 0;
    }
}

void stackPrint(const intstack_t* self)
{
    int i = 0;
    while (i < self->size)
    {
        fprintf(stdout, %i, self->begin[i]);
    }
}

int stackCapacityDo(intstack_t *self)
{
    int *newPtr = realloc(begin, 2*capacity*size(int));
    if (newPtr = NULL)
    {
        fprint(stderr, "Not enough memory available!");
        return EXIT_FAILURE;
    } else{
        self->begin = newPtr;
        return EXIT_SUCCESS;
    }
}


