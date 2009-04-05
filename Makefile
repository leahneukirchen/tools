all: wmdesk wmtitle

wmdesk: wmdesk.c
	gcc -O2 -o wmdesk wmdesk.c -lX11 -L/usr/X11/lib -L/usr/X11R6/lib

wmtitle: wmtitle.c
	gcc -O2 -o wmtitle wmtitle.c -lX11 -L/usr/X11/lib -L/usr/X11R6/lib
