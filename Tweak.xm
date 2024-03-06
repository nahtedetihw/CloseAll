#import "Tweak.h"

#define plistPath ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/com.nahtedetihw.closeallapps.plist"] ? @"/var/mobile/Library/Preferences/com.nahtedetihw.closeallapps.plist" : @"/var/jb/var/mobile/Library/Preferences/com.nahtedetihw.closeallapps.plist")

// Add close button to switcher
%hook SBAppSwitcherScrollView
%property (nonatomic, strong) UIButton *closeAllButton;
%property (nonatomic, strong) _UIBackdropViewSettings *blurViewSettings;
%property (nonatomic, strong) _UIBackdropView *blurView;
-(void)didMoveToWindow {
    %orig;
    if (!self.closeAllButton) [self addButton];
}

%new
- (void)addButton {
    if (self.superview) {
        self.closeAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeAllButton.titleEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
        [self.closeAllButton setContentMode:UIViewContentModeCenter];
        [self.closeAllButton addTarget:self action:@selector(closeAll)
                      forControlEvents:UIControlEventTouchUpInside];
        self.closeAllButton.frame = CGRectMake(0,0,55,25);
        self.closeAllButton.layer.masksToBounds = YES;
        self.closeAllButton.layer.cornerRadius = self.closeAllButton.frame.size.height/3;
        [self.closeAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.closeAllButton.backgroundColor = [UIColor clearColor];
        [self.closeAllButton setTitle:@"Close" forState:UIControlStateNormal];
        self.closeAllButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        if (self.closeAllButton) [self addBlurToButton];
        [self.superview insertSubview:self.closeAllButton atIndex:12];
        self.closeAllButton.translatesAutoresizingMaskIntoConstraints = false;
        [self.closeAllButton.widthAnchor constraintEqualToConstant:55].active = true;
        [self.closeAllButton.heightAnchor constraintEqualToConstant:25].active = true;
        [self.closeAllButton.rightAnchor constraintEqualToAnchor:self.superview.rightAnchor constant:-330].active = true;
        [self.closeAllButton.topAnchor constraintEqualToAnchor:self.superview.topAnchor constant:10].active = true;
        
        self.closeAllButton.alpha = 0;
        self.blurView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^ {
            self.closeAllButton.alpha = 1;
            self.blurView.alpha = 1;
        }];
    }
}

// Make sure the button is only visible when the switcher is visible
-(void)setScrollEnabled:(BOOL)arg1 {
    %orig;
    if (arg1 == false) {
        [UIView animateWithDuration:0.3 animations:^ {
            self.closeAllButton.alpha = 0;
            self.blurView.alpha = 0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^ {
            self.closeAllButton.alpha = 1;
            self.blurView.alpha = 1;
        }];
    }
}

// Add a blur behind the close button
%new
- (void)addBlurToButton {
    if (self.superview && self.closeAllButton) {
        self.blurViewSettings = [_UIBackdropViewSettings settingsForStyle:4005];
        self.blurView = [[_UIBackdropView alloc] initWithSettings:self.blurViewSettings];
        self.blurView.frame = self.closeAllButton.bounds;
        self.blurView.layer.masksToBounds = YES;
        self.blurView.layer.cornerRadius = self.closeAllButton.frame.size.height/3;
        [self.superview insertSubview:self.blurView atIndex:11];
        self.blurView.translatesAutoresizingMaskIntoConstraints = false;
        [self.blurView.widthAnchor constraintEqualToConstant:55].active = true;
        [self.blurView.heightAnchor constraintEqualToConstant:25].active = true;
        [self.blurView.rightAnchor constraintEqualToAnchor:self.superview.rightAnchor constant:-330].active = true;
        [self.blurView.topAnchor constraintEqualToAnchor:self.superview.topAnchor constant:10].active = true;
    }
}

// Close all apps
%new
- (void)closeAll {
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        self.closeAllButton.backgroundColor = [UIColor whiteColor];
        [self.closeAllButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
            self.closeAllButton.backgroundColor = [UIColor clearColor];
            [self.closeAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } completion:nil];
    });
    
    CloseAllManager *cm = [[CloseAllManager alloc] init];
    NSMutableDictionary *myMutableDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableArray *keyArray = [myMutableDictionary objectForKey:@"excludedApps"];
    if (@available(iOS 16.0, *)) {
        SBMainSwitcherControllerCoordinator *mainSwitcher16 = [%c(SBMainSwitcherControllerCoordinator) sharedInstance];
        NSArray *items16 = mainSwitcher16.recentAppLayouts;
        NSMutableArray *remainingItems16 = [NSArray arrayWithArray:items16].mutableCopy;
        for (SBAppLayout *item16 in items16) {
            if ([keyArray containsObject:item16.continuousExposeIdentifier]) {
                [remainingItems16 removeObject:item16];
                if (remainingItems16.count == 0) {
                    [self emptyArrayCloseAttempt];
                }
            } else {
                AudioServicesPlaySystemSound(1519);
                [cm clearApp:item16 switcher:mainSwitcher16 excludeList:keyArray];
            }
        }
    } else {
        SBMainSwitcherViewController *mainSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
        NSArray *items = mainSwitcher.recentAppLayouts;
        NSMutableArray *remainingItems = [NSArray arrayWithArray:items].mutableCopy;
        for (SBAppLayout *item in items) {
            SBDisplayItem *displayItem = [[item valueForKey:@"_rolesToLayoutItemsMap"] objectForKey:@1];
            NSString *appIdentifier = displayItem.bundleIdentifier;
            if ([keyArray containsObject:appIdentifier]) {
                [remainingItems removeObject:item];
                if (remainingItems.count == 0) {
                    [self emptyArrayCloseAttempt];
                }
            } else {
                AudioServicesPlaySystemSound(1519);
                [cm clearApp:item switcher:mainSwitcher excludeList:keyArray];
            }
        }
    }
}

// If remaining apps are empty, animate close button to notify user
%new
- (void)emptyArrayCloseAttempt {
    AudioServicesPlaySystemSound(1521);
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation( 5.0f, 0.0f, 0.0f)]];
    anim.autoreverses = YES;
    anim.repeatCount = 2.0f;
    anim.duration = 0.07f;
    [self.closeAllButton.layer addAnimation:anim forKey:@"shake"];
    
    CAKeyframeAnimation *animBlur = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animBlur.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation( 5.0f, 0.0f, 0.0f)]];
    animBlur.autoreverses = YES;
    animBlur.repeatCount = 2.0f;
    animBlur.duration = 0.07f;
    [self.blurView.layer addAnimation:anim forKey:@"shakeBlur"];
    
}
%end

@interface SBSwitcherAppSuggestionViewController : UIViewController
@end

// Remove suggestions in App Switcher
%hook SBSwitcherAppSuggestionViewController
- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    self.view.hidden = YES;
}

- (void)viewDidLoad {
    %orig;
    self.view.hidden = YES;
}
%end

@interface SBReusableSnapshotItemContainer : UIView
@property (nonatomic, retain) UIView *lockImageContainerView;
@property (nonatomic, retain) UIImageView *lockImageView;
@property (nonatomic) SBAppLayout *appLayout;
@property (nonatomic) CGFloat killingProgress;
@property (nonatomic) UIView *contentView;
- (void)lockUnlockApp:(SBAppLayout *)appLayout;
- (void)removeLock;
- (void)addLock;
- (void)updateLock;
@end


// Add lock icon to card
%hook SBReusableSnapshotItemContainer
%property (nonatomic, retain) UIView *lockImageContainerView;
%property (nonatomic, retain) UIImageView *lockImageView;
-(void)setContentView:(id)arg1 {
    %orig;
    self.lockImageContainerView = [[UIView alloc] init];
    self.lockImageContainerView.frame = CGRectMake(0,0,35,35);
    self.lockImageContainerView.hidden = NO;
    self.lockImageContainerView.clipsToBounds = NO;
    self.lockImageContainerView.layer.masksToBounds = YES;
    self.lockImageContainerView.layer.cornerRadius = self.lockImageContainerView.frame.size.height/2;
    self.lockImageContainerView.backgroundColor = [UIColor systemIndigoColor];
    self.lockImageContainerView.alpha = 1;
    self.lockImageContainerView.layer.shadowRadius = 5;
    self.lockImageContainerView.layer.shadowOpacity = 0.3;
    self.lockImageContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    [self insertSubview:self.lockImageContainerView atIndex:99998];
    self.lockImageContainerView.translatesAutoresizingMaskIntoConstraints = false;
    [self.lockImageContainerView.widthAnchor constraintEqualToConstant:35].active = true;
    [self.lockImageContainerView.heightAnchor constraintEqualToConstant:35].active = true;
    [self.lockImageContainerView.topAnchor constraintEqualToAnchor:self.topAnchor constant:-47].active = true;
    [self.lockImageContainerView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:30].active = true;
    
    self.lockImageView = [[UIImageView alloc] init];
    self.lockImageView.frame = CGRectMake(0,0,20,20);
    self.lockImageView.tintColor = [UIColor whiteColor];
    self.lockImageView.hidden = NO;
    self.lockImageView.clipsToBounds = NO;
    self.lockImageView.alpha = 1;
    self.lockImageView.image = [UIImage systemImageNamed:@"lock.fill"];
    [self.lockImageContainerView addSubview:self.lockImageView];
    self.lockImageView.translatesAutoresizingMaskIntoConstraints = false;
    [self.lockImageView.widthAnchor constraintEqualToConstant:20].active = true;
    [self.lockImageView.heightAnchor constraintEqualToConstant:20].active = true;
    [self.lockImageView.centerXAnchor constraintEqualToAnchor:self.lockImageContainerView.centerXAnchor constant:0].active = true;
    [self.lockImageView.centerYAnchor constraintEqualToAnchor:self.lockImageContainerView.centerYAnchor constant:0].active = true;
    
    [self updateLock];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLock) name:@"CloseAllSwitcherNowPlayingChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLock) name:@"CloseAllSwitcherAppeared" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLock) name:@"CloseAllSwitcherDisappeared" object:nil];
}

- (void)layoutSubviews {
    %orig;
    [self updateLock];
}

- (void)prepareForReuse {
    %orig;
    self.clipsToBounds = NO;
    [self updateLock];
}

-(void)_updateSnapshotViewWithAppLayout:(SBAppLayout *)appLayout {
    %orig;
    [self updateLock];
}

// Update the lock to show/hide when an app is locked/unlocked
%new
- (void)updateLock {
    NSMutableDictionary *myMutableDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableArray *keyArray = [myMutableDictionary objectForKey:@"excludedApps"];
    NSString *nowPlayingIdentifier = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];
    if (@available(iOS 16.0, *)) {
        if ([keyArray containsObject:self.appLayout.continuousExposeIdentifier] || [self.appLayout.continuousExposeIdentifier isEqual:nowPlayingIdentifier]) {
            [self addLock];
        } else {
            [self removeLock];
        }
    } else {
        SBDisplayItem *displayItem = [[self.appLayout valueForKey:@"_rolesToLayoutItemsMap"] objectForKey:@1];
        NSString *appIdentifier = displayItem.bundleIdentifier;
        if ([keyArray containsObject:appIdentifier] || [appIdentifier isEqual:nowPlayingIdentifier]) {
            [self addLock];
        } else {
            [self removeLock];
        }
    }
}

// Swipe down to lock/unlock
- (void)_updateTransformForCurrentHighlight {
    %orig;
    if (self.killingProgress <= -0.2) {
        [self lockUnlockApp:self.appLayout];
    }
}

%new
- (void)lockUnlockApp:(SBAppLayout *)appLayout {
    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [gen prepare];
    [gen impactOccurred];
    
    NSMutableDictionary *myMutableDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableArray *keyArray = [myMutableDictionary objectForKey:@"excludedApps"];
    NSString *nowPlayingIdentifier = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];
    if (@available(iOS 16.0, *)) {
        if ([keyArray containsObject:appLayout.continuousExposeIdentifier] || [appLayout.continuousExposeIdentifier isEqual:nowPlayingIdentifier]) {
            [keyArray removeObject:appLayout.continuousExposeIdentifier];
            [self removeLock];
        } else {
            [keyArray addObject:appLayout.continuousExposeIdentifier];
            [self addLock];
        }
    } else {
        SBDisplayItem *displayItem = [[appLayout valueForKey:@"_rolesToLayoutItemsMap"] objectForKey:@1];
        NSString *appIdentifier = displayItem.bundleIdentifier;
        if ([keyArray containsObject:appIdentifier] || [appIdentifier isEqual:nowPlayingIdentifier]) {
            [keyArray removeObject:appIdentifier];
            [self removeLock];
        } else {
            [keyArray addObject:appIdentifier];
            [self addLock];
        }
    }
    [myMutableDictionary setObject:keyArray forKey:@"excludedApps"];
    [myMutableDictionary writeToFile:plistPath atomically:YES];
}

%new
- (void)addLock {
    self.lockImageContainerView.hidden = NO;
    self.lockImageView.hidden = NO;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        self.lockImageContainerView.alpha = 1;
        self.lockImageView.alpha = 1;
        self.lockImageView.image = [UIImage systemImageNamed:@"lock.fill"];
    } completion:nil];
}

%new
- (void)removeLock {
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        self.lockImageView.image = [UIImage systemImageNamed:@"lock.open.fill"];
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.3 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:nil animations:^{
        self.lockImageContainerView.alpha = 0;
        self.lockImageView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.lockImageContainerView.hidden = YES;
            self.lockImageView.hidden = YES;
        }
    }];
}
%end

// Prevent lock from showing when transitioning to icon with floating dock
%hook SBMainSwitcherViewController
-(void)layoutStateTransitionCoordinator:(id)arg1 transitionDidBeginWithTransitionContext:(id)arg2 {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseAllSwitcherDisappeared" object:nil];
}

-(void)switcherContentController:(id)arg1 layoutStateTransitionDidEndWithTransitionContext:(id)arg2 {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseAllSwitcherAppeared" object:nil];
}
%end

%hook SBMainSwitcherControllerCoordinator
-(void)layoutStateTransitionCoordinator:(id)arg1 transitionDidBeginWithTransitionContext:(id)arg2 {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseAllSwitcherDisappeared" object:nil];
}

-(void)switcherContentController:(id)arg1 layoutStateTransitionDidEndWithTransitionContext:(id)arg2 {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseAllSwitcherAppeared" object:nil];
}
%end

// Notify when now playing app changes
%hook SBMediaController
-(void)_setNowPlayingApplication:(id)arg1 {
    %orig;
    if (arg1 != nil) [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseAllSwitcherNowPlayingChanged" object:nil];
}
%end


// Set scale of card smaller and move icon/title over to fit the lock
%hook SBAppSwitcherSettings
- (double)deckSwitcherPageScale {
    double origValue = %orig;
    if ([UIScreen mainScreen].nativeBounds.size.width <= 750) return origValue * 0.87;
    return origValue * 0.97;
}

-(double)spacingBetweenLeadingEdgeAndIcon {
    double spacing = %orig;
    spacing = spacing+30;
    return spacing;
}
%end
