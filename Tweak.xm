#import "SBHeaders.h"
#import "version.h"

#define kPrefsAppID 					CFSTR("applebetas.ios.tweaks.countdown")
#define kSettingsChangedNotification 	CFSTR("applebetas.ios.tweaks.countdown.changed")

#define kDefaultEventName           @"My event"
#define kDefaultEventDateString 	@""
#define kDefaultCountdownFormat     1
#define kDefaultEventPassedWording  2

#define MODERN_LS IS_IOS_OR_NEWER(iOS_10_0)
#define NEEDS_ANIMATED_ARGUMENT IS_IOS_BETWEEN(iOS_8_0, iOS_8_4)


static BOOL enabled;
static NSString *eventName;
static NSDate *eventDate;
static BOOL allowCountUp;
static int countdownFormat;
static int eventPassedWording;
static NSTimer *updateTimer;

@interface SBUICallToActionLabel (CountdownUtils)
-(void)CD_LSActivated:(NSNotification *)notification;
-(void)CD_LSDeactivated:(NSNotification *)notification;
-(void)CD_LSUpdateText;
@end

@interface SBLockScreenView (CountdownUtils)
-(void)CD_LSUpdateText;
@end

static void loadPreferences() {
    CFPreferencesAppSynchronize(kPrefsAppID);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    enabled = !CFPreferencesCopyAppValue(CFSTR("Enabled"), kPrefsAppID) ? YES : [CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("Enabled"), kPrefsAppID)) boolValue];
    eventName = !CFPreferencesCopyAppValue(CFSTR("EventName"), kPrefsAppID) ? kDefaultEventName : CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("EventName"), kPrefsAppID));
    eventDate = !CFPreferencesCopyAppValue(CFSTR("EventDate"), kPrefsAppID) ? [NSDate date] : [dateFormatter dateFromString:CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("EventDate"), kPrefsAppID))];
    countdownFormat = !CFPreferencesCopyAppValue(CFSTR("CountdownFormat"), kPrefsAppID) ? kDefaultCountdownFormat : [CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("CountdownFormat"), kPrefsAppID)) intValue];
    allowCountUp = !CFPreferencesCopyAppValue(CFSTR("AllowCountUp"), kPrefsAppID) ? YES : [CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("AllowCountUp"), kPrefsAppID)) boolValue];
    eventPassedWording = !CFPreferencesCopyAppValue(CFSTR("CountUpWording"), kPrefsAppID) ? kDefaultEventPassedWording : [CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("CountUpWording"), kPrefsAppID)) intValue];
}

static void prefsCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPreferences();
}

static NSString *getPassedText() {
    if(eventPassedWording == 1) {
        return @"Started";
    } else if(eventPassedWording == 2) {
        return @"Passed";
    }
    return @"Finished";
}

static NSString *formatCountdownInside() {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date] toDate:eventDate options:nil];
    NSInteger days = ABS([comp day]);
    if(countdownFormat != 4) {
        return [NSString stringWithFormat:@"%ld day%@", (long)days, (days == 1 ? @"" : @"s")];
    }
    return [NSString stringWithFormat:@"%ldd", (long)days];
}

static NSString *formatPassed() {
    if(countdownFormat == 1) {
        return [NSString stringWithFormat:@"%@ has %@", eventName, [getPassedText() lowercaseString]];
    } else if(countdownFormat == 2) {
        return [NSString stringWithFormat:@"%@ %@", eventName, [getPassedText() lowercaseString]];
    }
    return [NSString stringWithFormat:@"%@: %@", eventName, getPassedText()];
}

static NSString *formatNormalCountdown() {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date] toDate:eventDate options:nil];
    NSInteger days = ABS([comp day]);
    if(countdownFormat == 3 || countdownFormat == 4) {
        return [NSString stringWithFormat:@"%@: %@", eventName, formatCountdownInside()];
    } else if(countdownFormat == 1) {
        return [NSString stringWithFormat:@"There %@ %@ left until %@", (days == 1 ? @"is" : @"are"), formatCountdownInside(), eventName];
    } else {
        return [NSString stringWithFormat:@"%@ left until %@", formatCountdownInside(), eventName];
    }
}

static NSString *formatPassedCountdown() {
    if(countdownFormat == 3 || countdownFormat == 4) {
        return [NSString stringWithFormat:@"%@: %@ ago", eventName, formatCountdownInside()];
    } else {
        return [NSString stringWithFormat:@"%@ %@ %@ ago", eventName, [getPassedText() lowercaseString], formatCountdownInside()];
    }
}

static NSString *countdownString() {
    if ([eventDate timeIntervalSinceNow] < 0.0) {
        if(allowCountUp) {
            return formatPassedCountdown();
        } else {
            return formatPassed();
        }
    }
    return formatNormalCountdown();
}

%group iOS10

%hook SBDashBoardPageViewBase

-(void)didMoveToWindow {
    %orig;
    if (!self.window) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CountdownLockScreenDeactivatedNotification" object:nil];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CountdownLockScreenActivatedNotification" object:nil];
}

%end

%hook SBUICallToActionLabel

- (void)didMoveToWindow {
    %log;
    %orig;
    if(!self.window) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(CD_LSActivated:)
                                                 name:@"CountdownLockScreenActivatedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(CD_LSDeactivated:)
                                                 name:@"CountdownLockScreenDeactivatedNotification"
                                               object:nil];
    if(updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:15
                                                   target:self
                                                 selector:@selector(CD_LSUpdateText)
                                                 userInfo:nil
                                                  repeats:YES];
}

%new
-(void)CD_LSActivated:(NSNotification *)notification {
    %log;
    [self CD_LSUpdateText];
}

%new
-(void)CD_LSDeactivated:(NSNotification *)notification {
    %log;
    if(updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

%new
-(void)CD_LSUpdateText {
    %log;
    if([%c(SBLockScreenManager) sharedInstance].isLockScreenVisible) {
    	[self setText:countdownString()];
    } else if(updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

-(void)dealloc {
    %log;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    %orig;
}

- (void)setText:(id)text {
    %log;
    if (enabled) {
        text = countdownString();
    }
    %orig;
}

- (void)setText:(id)text forLanguage:(id)language animated:(BOOL)animated {
    %log;
    if (enabled) {
        text = countdownString();
    }
    %orig;
}

%end

%end

%group iOS9

%hook SBLockScreenView

-(void)didMoveToWindow {
    %orig;
    if (!self.window) {
        if(updateTimer) {
            [updateTimer invalidate];
            updateTimer = nil;
        }
        return;
    }
    
    [self CD_LSUpdateText];
    if(updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:15
                                                   target:self
                                                 selector:@selector(CD_LSUpdateText)
                                                 userInfo:nil
                                                  repeats:YES];
}

%new
-(void)CD_LSUpdateText {
    %log;
    if([%c(SBLockScreenManager) sharedInstance].isUILocked) {
        if(!NEEDS_ANIMATED_ARGUMENT) {
            [self setCustomSlideToUnlockText:countdownString()];
        } else {
            [self setCustomSlideToUnlockText:countdownString() animated:YES];
        }
    } else if(updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

-(void)dealloc {
    %log;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    %orig;
}

-(void)setCustomSlideToUnlockText:(NSString *)text {
    %log;
    if (enabled) {
        text = countdownString();
    }
    %orig;
}

-(void)setCustomSlideToUnlockText:(NSString *)text animated:(BOOL)arg2 {
    %log;
    if (enabled) {
        text = countdownString();
    }
    %orig;
}

%end

%end

//------------------------------------------------------------------------------


%ctor {
    @autoreleasepool {
        loadPreferences();
        
        if(MODERN_LS) {
            %init(iOS10);
        } else {
            %init(iOS9)
        }
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        (CFNotificationCallback)prefsCallback,
                                        kSettingsChangedNotification,
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately
                                        );
    }
}
