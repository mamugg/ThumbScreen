#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

// Wrappers dlsym vers les symboles privés de DFRFoundation.framework
// (pas de extern : le linker ne peut pas résoudre ces symboles à link-time)
void DFRElementSetControlStripPresenceForIdentifier(NSString *identifier, BOOL present);
void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL shows);

@interface NSTouchBarItem (DFRAdditions)
+ (void)addSystemTrayItem:(NSTouchBarItem *)item;
+ (void)removeSystemTrayItem:(NSTouchBarItem *)item;
@end

@interface NSTouchBar (DFRAdditions)
+ (void)presentSystemModalTouchBar:(NSTouchBar *)touchBar
        systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier;
+ (void)dismissSystemModalTouchBar:(NSTouchBar *)touchBar;
@end

NS_ASSUME_NONNULL_END
