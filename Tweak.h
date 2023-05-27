#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@interface _UIBackdropView : UIView
-(id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3 ;
-(id)initWithSettings:(id)arg1 ;
-(id)initWithStyle:(long long)arg1 ;
- (void)setBlurFilterWithRadius:(float)arg1 blurQuality:(id)arg2 blurHardEdges:(int)arg3;
- (void)setBlurFilterWithRadius:(float)arg1 blurQuality:(id)arg2;
- (void)setBlurHardEdges:(int)arg1;
- (void)setBlurQuality:(id)arg1;
- (void)setBlurRadius:(float)arg1;
- (void)setBlurRadiusSetOnce:(BOOL)arg1;
- (void)setBlursBackground:(BOOL)arg1;
- (void)setBlursWithHardEdges:(BOOL)arg1;
@end

@interface _UIBackdropViewSettings : NSObject
@property (assign,getter=isEnabled,nonatomic) BOOL enabled;
@property (assign,nonatomic) double blurRadius;
@property (nonatomic,copy) NSString * blurQuality;
@property (assign,nonatomic) BOOL usesBackdropEffectView;
-(id)initWithDefaultValues;
+(id)settingsForStyle:(long long)arg1 ;
@end

@interface SBDisplayItem : NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier;
@end

@interface SBPBDisplayItem : NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier;
@end

@interface SBPBAppLayout : NSObject
@property (nonatomic) SBPBDisplayItem *primaryDisplayItem;
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;
@end

@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
@end

@interface SBMainSwitcherControllerCoordinator: UIViewController
+ (id)sharedInstance;
-(id)recentAppLayouts;
-(void)_deleteAppLayoutsMatchingBundleIdentifier:(id)arg1 ;
-(void)_deleteAppLayout:(id)arg1 forReason:(long long)arg2;
@end

@interface SBMainSwitcherViewController: UIViewController
+ (id)sharedInstance;
-(id)recentAppLayouts;
-(void)_deleteAppLayoutsMatchingBundleIdentifier:(id)arg1 ;
-(void)_deleteAppLayout:(id)arg1 forReason:(long long)arg2;
@end

@interface SBAppLayout:NSObject
@property (nonatomic) NSString *continuousExposeIdentifier;
@property (nonatomic,copy) NSDictionary * rolesToLayoutItemsMap;
- (SBPBAppLayout *)protobufRepresentation;
-(id)allItems;
@end

@interface SBAppSwitcherScrollView : UIScrollView
@property (nonatomic, strong) UIButton *closeAllButton;
@property (nonatomic, strong) _UIBackdropViewSettings *blurViewSettings;
@property (nonatomic, strong) _UIBackdropView *blurView;
- (void)closeAll;
- (void)addButton;
- (void)addBlurToButton;
-(void)lockUnlockApp;
- (void)emptyArrayCloseAttempt;
@end

@interface CloseAllManager : NSObject
-(void)clearApp:(SBAppLayout *)item switcher:(id)switcher excludeList:(NSArray *)excluded;
@end
