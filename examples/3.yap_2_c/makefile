all:
	gcc -fPIC -shared -o c2postgres_yap.so c2postgres_yap.c -lpq -I/usr/include/postgresql -I/usr/include/Yap
	gcc -fPIC -shared -o hello_world.so hello_world.c -lpq -I/usr/include/postgresql -I/usr/include/Yap

clean:
	rm -f *.so
