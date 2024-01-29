# === General variables ===

OBJDIR = .
SRCDIR = .
INCDIR = .
OUTDIR = .

PROGRAM = dct
CC = gcc
LD = gcc
CCFLAGS = -Wall -Wextra -O0 -I $(INCDIR)
LDFLAGS =
LDLIBS = -lm

# === Files to compile ===

OBJECTS = $(OBJDIR)/dct.o\
          $(OBJDIR)/main.o\


# === Make rules ===

all: $(PROGRAM)

## Compile source files
$(OBJDIR)/%.o : $(SRCDIR)/%.c
	$(CC) $(CCFLAGS) -c -o $(OBJDIR)/$*.o $< 

## Link object files to build the compiler
$(PROGRAM): $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) $(LDLIBS) -o $(OUTDIR)/$(PROGRAM)

clean:
	-rm -rf $(OBJECTS) $(OUTDIR)/$(PROGRAM) 

