// Declaring our Variables that will be used throughout the program
static NSInteger statusBarStyle, screenRoundness, appswitcherRoundness;
static BOOL wantsHomeBar, wantsKeyboardDock, wantsRoundedAppSwitcher, wantsReduceRows, wantsCCGrabber, wantsOriginalButtons, wantsBottomInset, wantsRoundedCorners;

// Telling the iPhone that we want the fluid gestures
%hook BSPlatform
- (NSInteger)homeButtonType {
	return 2;
}
%end

// Removing the toggles on the lock screen
%hook SBDashBoardQuickActionsViewController	
-(BOOL)hasFlashlight {
	return NO;
}
-(BOOL)hasCamera {
	return NO;
}
%end

// If regular status bar or iPhone X statusbar fix control center from crashing
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    if(statusBarStyle == 0 || statusBarStyle == 2) {
        return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
    } else {
        return %orig;
    }
}
%end

// All the hooks for the iPhone X statusbar
%group StatusBarX

%hook UIStatusBar_Base
+ (Class)_implementationClass {
    return NSClassFromString(@"UIStatusBar_Modern");
}
+ (void)_setImplementationClass:(Class)arg1 {
    return %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end

@interface CCUIHeaderPocketView : UIView		
@end		

// Part of FUGap - stops the giltchy bluring effect from happening in the control center
%hook CCUIHeaderPocketView
-(void)setBackgroundAlpha:(double)arg1 {
    arg1 = 0.0;
    %orig;
}
%end
%end

// All the hooks for the iPad Statusbar
%group StatusBariPad

%hook UIStatusBar_Base
+ (Class)_implementationClass {
    return NSClassFromString(@"UIStatusBar_Modern");
}
+ (void)_setImplementationClass:(Class)arg1 {
    %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end

%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
}
%end

%hook UIStatusBarWindow
+ (void)setStatusBar:(Class)arg1 {
    %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end

// Fixes status bar glitch after closing control center
%hook CCUIHeaderPocketView
- (void)layoutSubviews {
    %orig;
    CGRect _frame = self.frame;
    _frame.origin.y = -24;
    self.frame = _frame;
}
%end

// Part of FUGap - stops the giltchy bluring effect from happening in the control center
%hook CCUIHeaderPocketView
-(void)setBackgroundAlpha:(double)arg1 {
    arg1 = 0.0;
    %orig;
}
%end
%end

%group hideHomeBar

%hook MTLumaDodgePillView
- (id)initWithFrame:(struct CGRect)arg1 {
	return NULL;
}
%end
%end

%group KeyboardDock

// iPhone X keyboard. Automatically adjusts the sized depending if Barmoji is installed
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    if (NSClassFromString(@"BarmojiCollectionView"))  orig.bottom = 60;
    else  orig.bottom = 40;
    return orig;
}
%end

@interface UIKeyboardDockView : UIView
@end

//Moves the emoji and dictation icon on the keyboard. Automatically adjust the location depending if Barmoji is installed
%hook UIKeyboardDockView
- (CGRect)bounds {
    CGRect bounds = %orig;
    if (NSClassFromString(@"BarmojiCollectionView")) {
		bounds.size.height += 4;
	} else {
		bounds.size.height += 15;
	}
    return bounds;
}
%end
%end

// Enables the modern dock + rounded app switcher corners
%group roundedDock

%hook UITraitCollection
- (CGFloat)displayCornerRadius {
	return appswitcherRoundness;
}
%end
%end

// Reduces the number of rows of icons on the home screen
%group reduceRows
%hook SBIconListView
+ (NSUInteger)maxVisibleIconRowsInterfaceOrientation:(UIInterfaceOrientation)orientation {
	NSUInteger orig = %orig;
	return orig-1;
}
%end
%end

// Adds the control center grabber on the coversheet
%group ccGrabber

@interface SBDashBoardTeachableMomentsContainerView : UIView
@property(retain, nonatomic) UIView *controlCenterGrabberView;
@property(retain, nonatomic) UIView *controlCenterGrabberEffectContainerView;
@end

%hook SBDashBoardTeachableMomentsContainerView
- (void)layoutSubviews {
    %orig;
    if(statusBarStyle == 2) {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 73,36,46,2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0,0,46,2.5);
    } else if(statusBarStyle == 1) {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 75.5,24,60.5,2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0,0,60.5,2.5);
    }
}
%end
%end

// Allows for the regular iPhone buttons to be used.
%group originalButtons

%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
    return %orig(1, arg2);
}
%end

%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
    return %orig(1);
}
%end

int applicationDidFinishLaunching;

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    applicationDidFinishLaunching = 2;
    %orig;
}
%end

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray * lockHome = @[@104, @101];
    NSArray * lockVol = @[@104, @102, @103];
    if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2) {
        %orig(lockHome);
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
    if (applicationDidFinishLaunching == 1) {
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
    return %orig(arg1,1,arg3,arg4);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
    return %orig(arg1,1);
}
%end

%hook SBLockHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 buttonActions:(id)arg6 homeButtonType:(long long)arg7 createGestures:(_Bool)arg8 {
    return %orig(arg1,arg2,arg3,arg4,arg5,arg6,1,arg8);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 homeButtonType:(long long)arg6 {
    return %orig(arg1,arg2,arg3,arg4,arg5,1);
}
%end

%hook SBVolumeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 homeButtonType:(long long)arg3 {
    return %orig(arg1,arg2,1);
}
%end
%end

// Adds the bottom inset to the screen. 
%group bottomInset

%hook UITabBar
- (void)layoutSubviews {
    %orig;
    CGRect _frame = self.frame;
    if (_frame.size.height == 49) {
		_frame.size.height = 70;
    	_frame.origin.y = [[UIScreen mainScreen] bounds].size.height - 70;
    }
    self.frame = _frame;
}
%end

%hook UIApplicationSceneSettings
- (UIEdgeInsets)_inferredLayoutMargins {
	return UIEdgeInsetsMake(32,0,0,0); 
}
- (UIEdgeInsets)safeAreaInsetsLandscapeLeft {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = 21;
	return _insets;
}
- (UIEdgeInsets)safeAreaInsetsLandscapeRight {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = 21;
    return _insets;
}
- (UIEdgeInsets)safeAreaInsetsPortrait {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = 21;
    return _insets;
}
- (UIEdgeInsets)safeAreaInsetsPortraitUpsideDown {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = 21;
    return _insets;
}
%end
%end

// Rounded Screen Corners for Lock and Home Screen
%group roundedCorners

@interface _UIRootWindow : UIView
@property (setter=_setContinuousCornerRadius:, nonatomic) double _continuousCornerRadius;
- (double)_continuousCornerRadius;
- (void)_setContinuousCornerRadius:(double)arg1;
@end

%hook _UIRootWindow
- (void)layoutSubviews {
    %orig;
    self._continuousCornerRadius = screenRoundness;
    self.clipsToBounds = YES;
    return;
}
%end
%end

// Preferences.
static void loadPrefs() {
    BOOL isSystem = [NSHomeDirectory() isEqualToString:@"/var/mobile"];
    NSDictionary* globalSettings = nil;
    if(isSystem) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.binksalex.littlexsprefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if(keyList) {
            globalSettings = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, CFSTR("com.binksalex.littlexsprefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
            if(!globalSettings) globalSettings = [NSDictionary new];
            CFRelease(keyList);
        }
    }
    if (!globalSettings) {
        globalSettings = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.binksalex.littlexsprefs.plist"];
    }
    statusBarStyle = (NSInteger)[[globalSettings objectForKey:@"statusBarStyle"]?:@2 integerValue];
    screenRoundness = (NSInteger)[[globalSettings objectForKey:@"screenRoundness"]?:@6 integerValue];
    appswitcherRoundness = (NSInteger)[[globalSettings objectForKey:@"appswitcherRoundness"]?:@6 integerValue];
    wantsHomeBar = (BOOL)[[globalSettings objectForKey:@"homeBar"]?:@FALSE boolValue];
    wantsKeyboardDock = (BOOL)[[globalSettings objectForKey:@"keyboardDock"]?:@TRUE boolValue];
    wantsRoundedAppSwitcher = (BOOL)[[globalSettings objectForKey:@"roundedAppSwitcher"]?:@TRUE boolValue];
    wantsReduceRows = (BOOL)[[globalSettings objectForKey:@"reduceRows"]?:@FALSE boolValue];
    wantsCCGrabber = (BOOL)[[globalSettings objectForKey:@"ccGrabber"]?:@FALSE boolValue];
    wantsOriginalButtons = (BOOL)[[globalSettings objectForKey:@"originalButtons"]?:@FALSE boolValue];
    wantsBottomInset = (BOOL)[[globalSettings objectForKey:@"bottomInset"]?:@FALSE boolValue];
    wantsRoundedCorners = (BOOL)[[globalSettings objectForKey:@"roundedCorners"]?:@FALSE boolValue];
}

%ctor {

    loadPrefs();
    
    // If statments deciding what groups to run
    
	if(statusBarStyle == 1) {
	    %init(StatusBariPad);
	} else if(statusBarStyle == 2) {
            %init(StatusBarX);
	}

	if(!wantsHomeBar) %init(hideHomeBar);

	if(wantsKeyboardDock) %init(KeyboardDock);
	
	if(wantsRoundedAppSwitcher) %init(roundedDock);

	if(wantsReduceRows) %init(reduceRows);

	if(wantsCCGrabber) %init(ccGrabber);

	if(wantsOriginalButtons) %init(originalButtons);

	if(wantsBottomInset) %init(bottomInset);

   	if(wantsRoundedCorners) %init(roundedCorners);

	// Runs everything that is not in a group
	%init(_ungrouped);
}
