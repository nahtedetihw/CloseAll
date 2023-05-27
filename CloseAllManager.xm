#import "Tweak.h"

@implementation CloseAllManager
-(void)clearApp:(SBAppLayout *)item switcher:(SBMainSwitcherControllerCoordinator *)switcher excludeList:(NSArray *)excluded {
    NSString *bundleID;

    NSArray *arr = [item allItems];
    SBDisplayItem *itemz = arr[0];
    bundleID = itemz.bundleIdentifier;

    NSString *nowPlayingID = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];

    if (bundleID != NULL && ![excluded containsObject:bundleID] && ![bundleID isEqualToString: nowPlayingID]) {
        if (@available(iOS 16.0, *)) {
            if ([NSStringFromClass([switcher class]) isEqualToString:@"SBMainSwitcherControllerCoordinator"]) [switcher _deleteAppLayoutsMatchingBundleIdentifier:bundleID];
        } else {
            if ([NSStringFromClass([switcher class]) isEqualToString:@"SBMainSwitcherViewController"]) [switcher _deleteAppLayoutsMatchingBundleIdentifier:bundleID];
        }
    }
}
@end
