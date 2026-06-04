#import "DFRBridge.h"
#import <dlfcn.h>

static void *sDFRHandle = NULL;

// Charge DFRFoundation avant main() et conserve le handle pour dlsym.
// RTLD_DEFAULT résoudrait nos propres symboles en premier → récursion infinie.
__attribute__((constructor))
static void loadDFRFoundation(void) {
    const char *path =
        "/System/Library/PrivateFrameworks/DFRFoundation.framework/DFRFoundation";
    sDFRHandle = dlopen(path, RTLD_LAZY | RTLD_GLOBAL);
    if (!sDFRHandle) {
        NSLog(@"[ThumbScreen] Impossible de charger DFRFoundation: %s", dlerror());
    }
}

void DFRElementSetControlStripPresenceForIdentifier(NSString *identifier, BOOL present) {
    typedef void (*Fn)(NSString *, BOOL);
    static Fn fn = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        fn = (Fn)dlsym(sDFRHandle, "DFRElementSetControlStripPresenceForIdentifier");
        if (!fn) NSLog(@"[ThumbScreen] dlsym DFRElementSetControlStripPresenceForIdentifier: %s", dlerror());
    });
    if (fn) fn(identifier, present);
}

void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL shows) {
    typedef void (*Fn)(BOOL);
    static Fn fn = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        fn = (Fn)dlsym(sDFRHandle, "DFRSystemModalShowsCloseBoxWhenFrontMost");
    });
    if (fn) fn(shows);
}
