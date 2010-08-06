/* (C)opyright MMVI Anselm R. Garbe <garbeam at gmail dot com>
 * See LICENSE file for license details.
 */

// lsu - list urgent windows, by chris2
// cc -Wall -Os -o lsu lsu.c -L/usr/X11R6/lib -lX11 -DVERSION='"1.0"'

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

static char buf[1024];
static Atom netwmname;
static Display *dpy;
static Window root;

static void
getname(Window w) {
	char **list = NULL;
	int n;
	XTextProperty prop;

	prop.nitems = 0;
	buf[0] = 0;
	XGetTextProperty(dpy, w, &prop, netwmname);
	if(!prop.nitems)
		XGetWMName(dpy, w, &prop);
	if(!prop.nitems)
		return;
	if(prop.encoding == XA_STRING)
		strncpy(buf, (char *)prop.value, sizeof(buf));
	else {
		if(XmbTextPropertyToTextList(dpy, &prop, &list, &n) >= Success
				&& n > 0 && *list)
		{
			strncpy(buf, *list, sizeof(buf));
			XFreeStringList(list);
		}
	}
	XFree(prop.value);
}

int
main(int argc, char *argv[]) {
	unsigned int i, num;
	Window *wins, d1, d2;
	XWindowAttributes wa;
        XWMHints *hints;

	if((argc > 1) && !strncmp(argv[1], "-v", 3)) {
		fputs("lsu-"VERSION", (C)opyright MMVI Anselm R. Garbe\n", stdout);
		exit(EXIT_SUCCESS);
	}
	if(!(dpy = XOpenDisplay(0))) {
		fputs("lsu: cannot open display\n", stderr);
		exit(EXIT_FAILURE);
	}
	root = RootWindow(dpy, DefaultScreen(dpy));
	netwmname = XInternAtom(dpy, "_NET_WM_NAME", False);
	if(XQueryTree(dpy, root, &d1, &d2, &wins, &num)) {
		for(i = 0; i < num; i++) {
			if(!XGetWindowAttributes(dpy, wins[i], &wa))
				continue;
			if(wa.override_redirect)
				continue;
                        hints = XGetWMHints(dpy, wins[i]);
                        if(!(hints && hints->flags & XUrgencyHint))
                        	continue;
                        getname(wins[i]);
                        if (hints)
                        	XFree(hints);
			if(buf[0])
				fprintf(stdout, "%s ", buf);
		}
	}
	if(wins)
		XFree(wins);
	XCloseDisplay(dpy);
	return 0;
}
