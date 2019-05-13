#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

// Declaring our Variables that will be used throughout the program
static NSInteger statusBarStyle, screenRoundness, appswitcherRoundness, bottomInsetVersion;
static BOOL wantsHomeBar, wantsKeyboardDock, wantsRoundedAppSwitcher, wantsReduceRows, wantsCCGrabber, wantsOriginalButtons, wantsRoundedCorners, wantsPIP, wantsProudLock, jumperCheck = NO, wantsHideSBCC;

// Telling the iPhone that we want the fluid gestures
%hook BSPlatform
- (NSInteger)homeButtonType {
	return 2;
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

// Forces the default keyboard when the iPhone X keyboard is disabled and the new bottom inset is enabled.
%group ForceDefaultKeyboard
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    orig.bottom = 0;
    return orig;
}
%end
%end

// Removing the toggles on the lockscreen.
%hook SBDashBoardQuickActionsViewController	
-(BOOL)hasFlashlight {
	return jumperCheck;
}
-(BOOL)hasCamera {
	return jumperCheck;
}
%end

// Fix the status bar from glitching when using the default status bar by hiding the status bar in the CC.
%group HideSBCC
%hook CCUIStatusBarStyleSnapshot
-(BOOL)isHidden {
    return YES;
}
%end

%hook CCUIModularControlCenterOverlayViewController
- (void)setOverlayStatusBarHidden:(BOOL)arg1 {
    %orig(YES);
}
%end

%hook CCUIOverlayStatusBarPresentationProvider
- (void)_addHeaderContentTransformAnimationToBatch:(id)arg1 transitionState:(id)arg2 {
    %orig(nil, arg2);
}
%end

// Fix control center from crashing on iOS 12.
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}
%end
%end

// Reduce reachability sensitivity.
%hook SBReachabilitySettings
- (void)setSystemWideSwipeDownHeight:(double) systemWideSwipeDownHeight {
    %orig(100);
}
%end

// All the hooks for the iPhone X statusbar.
%group StatusBarX

%hook UIStatusBar_Base
+ (Class)_implementationClass {
    return NSClassFromString(@"UIStatusBar_Modern");
}
+ (void)_setImplementationClass:(Class)arg1 {
    %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
+ (BOOL)forceModern {
	return YES;
}
+ (Class)_statusBarImplementationClass {
	return NSClassFromString(@"UIStatusBar_Modern");
}
%end

%hook UIStatusBarWindow
+ (void)setStatusBar:(Class)arg1 {
    %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end

%hook _UIStatusBar
+ (BOOL)forceSplit {
	return YES;
}
%end

// Fix control center from crashing on iOS 12.
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}
%end

// Fix status bar in YouTube.
@interface YTHeaderContentComboView : UIView
- (UIView*)comboView;
- (UIView*)headerView;
@end

%hook YTHeaderContentComboView
- (void)layoutSubviews {
    %orig;
        CGRect headerViewFrame = [[self headerView] frame];
        headerViewFrame.origin.y += 20;
        [[self headerView] setFrame:headerViewFrame];
        [self setBackgroundColor:[[self headerView] backgroundColor]];
}
%end

%end

// All the hooks for the iPad statusbar.
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
    if(screenRoundness >= 16 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.1")) return NSClassFromString(@"_UIStatusBarVisualProvider_RoundedPad_ForcedCellular");
    else return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
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
    if(screenRoundness >= 16 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.1")) _frame.origin.y = -20;
    else _frame.origin.y = -24;
    self.frame = _frame;
}
%end
%end

// Hide the homebar
%group hideHomeBar
%hook MTLumaDodgePillView
- (id)initWithFrame:(struct CGRect)arg1 {
	return NULL;
}
%end
%end

// iPhone X keyboard.
%group KeyboardDock

// Automatically adjusts the sized depending if Barmoji is installed or not.
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    NSClassFromString(@"BarmojiCollectionView") ? orig.bottom = 80 : orig.bottom = 40;
    return orig;
}
%end

// Moves the emoji and dictation icon on the keyboard. Automatically adjust the location depending if Barmoji is installed or not.
%hook UIKeyboardDockView
- (CGRect)bounds {
    CGRect bounds = %orig;
    NSClassFromString(@"BarmojiCollectionView") ? bounds.origin.y += 2 : bounds.size.height += 15;
    return bounds;
}
%end
%end

// Enables the rounded dock of the iPhone X + rounds up the cards of the app switcher.
%group roundedDock

%hook UITraitCollection
- (CGFloat)displayCornerRadius {
	return appswitcherRoundness;
}
%end
%end

// Reduces the number of rows of icons on the home screen by 1.
%group reduceRows
%hook SBIconListView
+ (NSUInteger)maxVisibleIconRowsInterfaceOrientation:(UIInterfaceOrientation)orientation {
	NSUInteger orig = %orig;
	return orig-1;
}
%end
%end

// Adds the control center grabber on the lockscreen.
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

// Allows you to use the normal iPhone button combination.
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

// System-wide rounded screen corners.
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

// Adds the bottom inset to the screen.
%group InsetX	

extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef);

typedef unsigned long long addr_t;

static addr_t step64(const uint8_t *buf, addr_t start, size_t length, uint32_t what, uint32_t mask) {
	addr_t end = start + length;
	while (start < end) {
		uint32_t x = *(uint32_t *)(buf + start);
		if ((x & mask) == what) {
			return start;
		}
		start += 4;
	}
	return 0;
}

static addr_t find_branch64(const uint8_t *buf, addr_t start, size_t length) {
	return step64(buf, start, length, 0x14000000, 0xFC000000);
}

static addr_t follow_branch64(const uint8_t *buf, addr_t branch) {
	long long w;
	w = *(uint32_t *)(buf + branch) & 0x3FFFFFF;
	w <<= 64 - 26;
	w >>= 64 - 26 - 2;
	return branch + w;
}

static CFPropertyListRef (*orig_MGCopyAnswer_internal)(CFStringRef property, uint32_t *outTypeCode);
CFPropertyListRef new_MGCopyAnswer_internal(CFStringRef property, uint32_t *outTypeCode) {
    CFPropertyListRef r = orig_MGCopyAnswer_internal(property, outTypeCode);
	#define k(string) CFEqual(property, CFSTR(string))
     NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
 if (k("oPeik/9e8lQWMszEjbPzng") || k("ArtworkTraits")) {
        CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)r);
        CFRelease(r);
        CFNumberRef num;
        uint32_t deviceSubType = 0x984;
        num = CFNumberCreate(NULL, kCFNumberIntType, &deviceSubType);
        CFDictionarySetValue(copy, CFSTR("ArtworkDeviceSubType"), num);
        return copy;
    }  else if ((k("8olRm6C1xqr7AJGpLRnpSw") || k("PearlIDCapability")) && [bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        return (__bridge CFPropertyListRef)@YES;
    } else if (k("JwLB44/jEB8aFDpXQ16Tuw") || k("HomeButtonType")) {
        return (__bridge CFPropertyListRef)@2;
    } else if (k("/YYygAofPDbhrwToVsXdeA") || k("HwModelStr")) {
        return (__bridge CFPropertyListRef)@"D22AP";
    } else if (k("Z/dqyWS6OZTRy10UcmUAhw") || k("marketing-name")) {
        return (__bridge CFPropertyListRef)@"iPhone X";
    } else if (k("h9jDsbgj7xIVeIQ8S3/X3Q") || k("ProductType")) {
        return (__bridge CFPropertyListRef)@"iPhone10,3";
    }
	return r;
}
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

// Enables PiP in video player.
%group PIP
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
#define keyy(key_) CFEqual(key, CFSTR(key_))
    if (keyy("nVh/gwNpy7Jv1NOk00CMrw"))
        return YES;
    return %orig;
}
%end

// Adds the padlock to the lockscreen.
%group ProudLock
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
#define keyyy(key_) CFEqual(key, CFSTR(key_))
    if (keyyy("z5G/N9jcMdgPm8UegLwbKg") || keyyy("IsEmulatedDevice"))
        return YES;
    return %orig;
}

#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)
static CGFloat offset = 0;

%hook SBDashBoardViewController
- (void)loadView {
    %orig;
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Jellyfish.dylib"]) {
        CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
        if (screenWidth <= 320) {
            offset = 20;
        } else if (screenWidth <= 375) {
            offset = 35;
        } else {
            offset = 28;
        }
    }
}
%end

%hook SBFLockScreenDateView
- (void)layoutSubviews {
    %orig;
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Jellyfish.dylib"]) {
        UIView* timeView = MSHookIvar<UIView*>(self, "_timeLabel");
        UIView* dateSubtitleView = MSHookIvar<UIView*>(self, "_dateSubtitleView");
        UIView* customSubtitleView = MSHookIvar<UIView*>(self, "_customSubtitleView");
        [timeView setFrame:CGRectSetY(timeView.frame, timeView.frame.origin.y + offset)];
        [dateSubtitleView setFrame:CGRectSetY(dateSubtitleView.frame, dateSubtitleView.frame.origin.y + offset)];
        [customSubtitleView setFrame:CGRectSetY(customSubtitleView.frame, customSubtitleView.frame.origin.y + offset)];
    }
}
%end

%hook SBUIBiometricResource
- (id)init {
	id r = %orig;
	
	MSHookIvar<BOOL>(r, "_hasMesaHardware") = NO;
	MSHookIvar<BOOL>(r, "_hasPearlHardware") = YES;
	
	return r;
}
%end


@interface PKGlyphView : UIView
@end

%hook PKGlyphView
- (void)setHidden:(BOOL)arg1 {
	if ([self.superview isKindOfClass:%c(SBUIPasscodeBiometricAuthenticationView)]) {
		%orig(NO);
		return;
	}
	
	%orig;
}

- (BOOL)hidden {
	if ([self.superview isKindOfClass:%c(SBUIPasscodeBiometricAuthenticationView)]) {
		return NO;
	}
	
	return %orig;
}
%end
%end

// Adds a bottom inset to the camera app.
%group CameraFix

@interface CAMViewfinderView : UIView
- (UIView*)zoomControl;
- (UIView*)bottomBar;
@end

%hook CAMViewfinderView
- (void)layoutSubviews {
    %orig;
    CGRect bottomBarFrame = [[self bottomBar] frame];
    bottomBarFrame.origin.y -= 40;
    [[self bottomBar] setFrame:bottomBarFrame];
    CGRect zoomControlFrame = [[self zoomControl] frame];
    zoomControlFrame.origin.y -= 30;
    [[self zoomControl] setFrame:zoomControlFrame];
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
    if (!globalSettings)
        globalSettings = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.binksalex.littlexsprefs.plist"];
    statusBarStyle = (NSInteger)[[globalSettings objectForKey:@"statusBarStyle"]?:@2 integerValue];
    screenRoundness = (NSInteger)[[globalSettings objectForKey:@"screenRoundness"]?:@6 integerValue];
    appswitcherRoundness = (NSInteger)[[globalSettings objectForKey:@"appswitcherRoundness"]?:@6 integerValue];
    bottomInsetVersion = (NSInteger)[[globalSettings objectForKey:@"bottomInsetVersion"]?:@0 integerValue];
    wantsHomeBar = (BOOL)[[globalSettings objectForKey:@"homeBar"]?:@FALSE boolValue];
    wantsKeyboardDock = (BOOL)[[globalSettings objectForKey:@"keyboardDock"]?:@TRUE boolValue];
    wantsRoundedAppSwitcher = (BOOL)[[globalSettings objectForKey:@"roundedAppSwitcher"]?:@FALSE boolValue];
    wantsReduceRows = (BOOL)[[globalSettings objectForKey:@"reduceRows"]?:@FALSE boolValue];
    wantsCCGrabber = (BOOL)[[globalSettings objectForKey:@"ccGrabber"]?:@FALSE boolValue];
    wantsOriginalButtons = (BOOL)[[globalSettings objectForKey:@"originalButtons"]?:@FALSE boolValue];
    wantsRoundedCorners = (BOOL)[[globalSettings objectForKey:@"roundedCorners"]?:@FALSE boolValue];
    wantsPIP = (BOOL)[[globalSettings objectForKey:@"PIP"]?:@FALSE boolValue];
    wantsProudLock = (BOOL)[[globalSettings objectForKey:@"ProudLock"]?:@FALSE boolValue];
    wantsHideSBCC = (BOOL)[[globalSettings objectForKey:@"HideSBCC"]?:@FALSE boolValue];
}

%ctor {
    @autoreleasepool {
        loadPrefs();
       	jumperCheck = [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.tapsharp.jumper.list"];
	    
        if(statusBarStyle == 1) %init(StatusBariPad) 
	    else if(statusBarStyle == 2) %init(StatusBarX);
   	    else wantsHideSBCC = YES;

	    if(bottomInsetVersion == 2) {
            MSImageRef libGestalt = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
            if (libGestalt) {
                void *MGCopyAnswerFn = MSFindSymbol(libGestalt, "_MGCopyAnswer");
                const uint8_t *MGCopyAnswer_ptr = (const uint8_t *)MGCopyAnswer;
                addr_t branch = find_branch64(MGCopyAnswer_ptr, 0, 8);
                addr_t branch_offset = follow_branch64(MGCopyAnswer_ptr, branch);
                MSHookFunction(((void *)((const uint8_t *)MGCopyAnswerFn + branch_offset)), (void *)new_MGCopyAnswer_internal, (void **)&orig_MGCopyAnswer_internal);
            }
            %init(InsetX);
        } else if(bottomInsetVersion == 1) %init(bottomInset);
        
	    if (wantsHomeBar) %init(CameraFix);
        else %init(hideHomeBar);

        if(wantsKeyboardDock) %init(KeyboardDock);
        else if (bottomInsetVersion == 2) %init(ForceDefaultKeyboard);
        if(wantsRoundedAppSwitcher) %init(roundedDock);
        if(wantsReduceRows) %init(reduceRows);
        if(wantsCCGrabber) %init(ccGrabber);
        if(wantsOriginalButtons) %init(originalButtons);
        if(wantsRoundedCorners) %init(roundedCorners);
        if(wantsPIP) %init(PIP);
        if(wantsProudLock) %init(ProudLock);
        if(wantsHideSBCC && statusBarStyle != 1) %init(HideSBCC);

        %init(_ungrouped);
	}
}
