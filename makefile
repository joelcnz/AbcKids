all: base.obj current.obj input.obj keyhandling.obj keys.obj main.obj media.obj texthandling.obj world.obj
	dmd -ofbin\debug\abc5 bin\debug\abc.res -debug -debug=TDD base.obj current.obj input.obj keyhandling.obj keys.obj main.obj media.obj texthandling.obj world.obj

base.obj: base.d
	dmd -c base.d

current.obj: current.d
	dmd -c current.d

input.obj: input.d
	dmd -c input.d

keyhandling.obj: keyhandling.d
	dmd -c keyhandling.d

keys.obj: keys.d
	dmd -c keys.d

main.obj: main.d
	dmd -c main.d

media.obj: media.d
	dmd -c media.d

texthandling.obj: texthandling.d
	dmd -c texthandling.d

world.obj: world.d
	dmd -c world.d

html:
	dmd -c -D main.d media.d base.d current.d input.d keyhandling.d keys.d texthandling.d
	copy *.html bin\debug\html
	del *.html

execute:
	cls
	copy test.exe bin\debug
	del test.exe
	cd bin\debug
	test.exe
	cd ..\..

clean:
	del *.obj
