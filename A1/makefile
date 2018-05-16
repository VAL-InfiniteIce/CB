
TARGET_1 = teststack
OBJ_1    = stack.o teststack.o

TARGET_2 = testsyntree
OBJ_2    = syntree.o testsyntree.o

CC     = gcc
CFLAGS = -std=c99 -Wall -pedantic

%.o: %.c %.h
	$(CC) $(CFLAGS) $< -c

all: $(TARGET_1) $(TARGET_2)

$(TARGET_1): $(OBJ_1)
	$(CC) $(CFLAGS) $^ -o $@

$(TARGET_2): $(OBJ_2)
	$(CC) $(CFLAGS) $^ -o $@

clean:
	$(RM) $(RMFLAGS) $(TARGET_1) $(OBJ_1) $(TARGET_2) $(OBJ_2)
