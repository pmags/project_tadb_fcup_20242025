CFLAGS = -fPIC -I/usr/include/Yap -I/usr/include/postgresql
LDFLAGS = -shared -lpq -lm
TARGET = yap2c_function.so

all: $(TARGET)

$(TARGET): yap2c_function.o geo_ops.o
	gcc $(LDFLAGS) -o $@ $^

yap2c_function.o: yap2c_function.c geo_ops.h
	gcc $(CFLAGS) -c yap2c_function.c

geo_ops.o: geo_ops.c geo_ops.h
	gcc $(CFLAGS) -c geo_ops.c

clean:
	rm -f *.o *.so
