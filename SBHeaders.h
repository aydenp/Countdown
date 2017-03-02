@interface SBUICallToActionLabel : UIView
-(void)setText:(NSString *)arg1 ;
@end

@interface SBLockScreenManager : NSObject
+(SBLockScreenManager *)sharedInstance;
-(BOOL)isLockScreenVisible;
-(BOOL)isUILocked;
@end

@interface SBLockScreenView: UIView
-(void)setCustomSlideToUnlockText:(id)arg1;
-(void)setCustomSlideToUnlockText:(NSString *)text animated:(BOOL)arg2;
@end

@interface SBDashBoardPageViewBase: UIView
@end
