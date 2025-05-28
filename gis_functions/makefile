# Compiler and flags
CC = gcc
CFLAGS = -fPIC -I/usr/include/postgresql -I/usr/include/Yap
LDFLAGS = -shared -lpq -lm

# Files
OBJS = geo_ops.o yap2c_function.o
TARGET = yap2c_function.so

all: $(TARGET)

# Object files
geo_ops.o: geo_ops.c
	$(CC) -c $(CFLAGS) geo_ops.c -o geo_ops.o

yap2c_function.o: yap2c_function.c
	$(CC) -c $(CFLAGS) yap2c_function.c -o yap2c_function.o

# Link shared library
$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(OBJS) $(LDFLAGS)

clean:
	rm -f *.o *.so
