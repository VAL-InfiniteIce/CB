TARGET = minako
LFILES = minako-lexic.l
CFILES = minako-syntax.c

CC     = gcc
LEX    = flex
CFLAGS = -std=c99 -Wall -pedantic
LFLAGS = -t

%.c: %.l
	$(LEX) $(LFLAGS) $< > $@
%.o: %.c %.h
	$(CC) $(CFLAGS) $< -c
%.o: %.c
	$(CC) $(CFLAGS) $< -c

all: $(TARGET)

$(TARGET): $(LFILES:%.l=%.o) $(CFILES:%.c=%.o)
	$(CC) $(CFLAGS) $^ -o $@

clean:
	$(RM) $(RMFLAGS) $(TARGET) $(LFILES:%.l=%.o) $(CFILES:%.c=%.o) $(LFILES:%.l=%.c)
