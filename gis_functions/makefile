

all:
	gcc -fPIC -shared -o geo_ops.o geo_ops.c -lpq -I/usr/include/postgresql -I/usr/include/Yap

yap2c_function.o: yap2c_function.c
	
	gcc -fPIC -c yap2c_function.c geo_ops.c -I/usr/include/Yap -I/usr/include/postgresql
	gcc -shared -o yap2c_function.so yap2c_function.o geo_ops.o -lpq -lm


clean:
	rm -f *.so
