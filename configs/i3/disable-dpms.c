#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/extensions/dpms.h>

int main(void) {
    Display *dpy = XOpenDisplay(NULL);
    if (!dpy) {
        fprintf(stderr, "cannot open display\n");
        return 1;
    }
    int event_base = 0, error_base = 0;
    if (!DPMSQueryExtension(dpy, &event_base, &error_base)) {
        fprintf(stderr, "DPMS not available\n");
        XCloseDisplay(dpy);
        return 1;
    }

    CARD16 level = 0;
    BOOL state = False;
    DPMSInfo(dpy, &level, &state);
    CARD16 standby = 0, suspend = 0, off = 0;
    DPMSGetTimeouts(dpy, &standby, &suspend, &off);
    printf("before: enabled=%d level=%u timeouts=%u/%u/%u\n",
           (int)state, (unsigned)level, (unsigned)standby, (unsigned)suspend, (unsigned)off);

    int timeout = 0, interval = 0, prefer = 0, allow = 0;
    XGetScreenSaver(dpy, &timeout, &interval, &prefer, &allow);
    printf("before screensaver timeout=%d\n", timeout);

    DPMSForceLevel(dpy, DPMSModeOn);
    DPMSDisable(dpy);
    DPMSSetTimeouts(dpy, 0, 0, 0);
    XSetScreenSaver(dpy, 0, 0, prefer, allow);
    XSync(dpy, False);

    DPMSInfo(dpy, &level, &state);
    DPMSGetTimeouts(dpy, &standby, &suspend, &off);
    XGetScreenSaver(dpy, &timeout, &interval, &prefer, &allow);
    printf("after: enabled=%d level=%u timeouts=%u/%u/%u screensaver=%d\n",
           (int)state, (unsigned)level, (unsigned)standby, (unsigned)suspend, (unsigned)off, timeout);

    XCloseDisplay(dpy);
    return 0;
}
