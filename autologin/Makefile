all: AutoLogin.exe

AutoLogin.exe:
	winegcc -o AutoLogin.exe AutoLogin.c -luser32
	mv AutoLogin.exe.so AutoLogin.exe

clean:
	rm AutoLogin.exe
