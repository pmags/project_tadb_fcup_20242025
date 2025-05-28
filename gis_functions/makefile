

all:
	gcc -fPIC -I/usr/include/Yap -I/usr/include/postgresql -c geo_ops.c
	gcc -fPIC -I/usr/include/Yap -I/usr/include/postgresql -c yap2c_function.c
	gcc -shared -o yap2c_function.so geo_ops.o yap2c_function.o -lpq -lm

clean:
	rm -f *.o *.so