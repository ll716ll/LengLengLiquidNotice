#import "LLNView.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const kLLNPID = @"com.lengleng.liquidnotice";

static id LLNPref(NSString *key, id fallback) {
    id v = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, (__bridge CFStringRef)kLLNPID));
    return v ?: fallback;
}

@interface LLNCardView : UIView
@property(nonatomic,strong) UIVisualEffectView *blur;
@property(nonatomic,strong) UIImageView *avatar;
@property(nonatomic,strong) UILabel *badge;
@property(nonatomic,strong) UILabel *name;
@property(nonatomic,strong) UILabel *content;
@property(nonatomic,strong) UILabel *arrow;
@property(nonatomic,strong) UIView *ring;
@end

@implementation LLNCardView
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self=[super initWithFrame:frame])) {
        self.layer.cornerRadius=44;
        self.layer.cornerCurve=kCACornerCurveContinuous;
        self.layer.borderWidth=1.0;
        self.layer.borderColor=[UIColor colorWithWhite:1 alpha:.72].CGColor;
        self.layer.shadowColor=[UIColor blackColor].CGColor;
        self.layer.shadowOpacity=.16;
        self.layer.shadowRadius=18;
        self.layer.shadowOffset=CGSizeMake(0,10);
        self.backgroundColor=[UIColor colorWithWhite:1 alpha:.12];
        UIBlurEffect *be=[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialLight];
        self.blur=[[UIVisualEffectView alloc] initWithEffect:be];
        self.blur.frame=self.bounds; self.blur.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.blur.layer.cornerRadius=44; self.blur.layer.cornerCurve=kCACornerCurveContinuous; self.blur.clipsToBounds=YES;
        [self addSubview:self.blur];

        self.ring=[[UIView alloc] initWithFrame:CGRectMake(14,10,72,72)];
        self.ring.layer.cornerRadius=36; self.ring.layer.cornerCurve=kCACornerCurveContinuous;
        self.ring.layer.borderWidth=5;
        self.ring.layer.borderColor=[UIColor colorWithWhite:1 alpha:.95].CGColor;
        self.ring.layer.shadowOpacity=.12; self.ring.layer.shadowRadius=8; self.ring.layer.shadowOffset=CGSizeZero;
        [self.blur.contentView addSubview:self.ring];

        self.avatar=[[UIImageView alloc] initWithFrame:CGRectMake(19,15,62,62)];
        self.avatar.layer.cornerRadius=31; self.avatar.clipsToBounds=YES; self.avatar.contentMode=UIViewContentModeScaleAspectFill;
        [self.blur.contentView addSubview:self.avatar];

        self.badge=[[UILabel alloc] initWithFrame:CGRectMake(69,-2,30,30)];
        self.badge.backgroundColor=[UIColor colorWithRed:.98 green:.12 blue:.17 alpha:1];
        self.badge.textColor=UIColor.whiteColor; self.badge.font=[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        self.badge.textAlignment=NSTextAlignmentCenter; self.badge.layer.cornerRadius=15; self.badge.clipsToBounds=YES;
        [self.blur.contentView addSubview:self.badge];

        self.name=[[UILabel alloc] initWithFrame:CGRectMake(111,18,frame.size.width-165,28)];
        self.name.font=[UIFont systemFontOfSize:22 weight:UIFontWeightMedium]; self.name.textColor=UIColor.blackColor;
        [self.blur.contentView addSubview:self.name];

        self.content=[[UILabel alloc] initWithFrame:CGRectMake(111,48,frame.size.width-165,28)];
        self.content.font=[UIFont systemFontOfSize:17 weight:UIFontWeightRegular]; self.content.textColor=[UIColor colorWithWhite:.25 alpha:.9];
        [self.blur.contentView addSubview:self.content];

        self.arrow=[[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-45,25,28,38)];
        self.arrow.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
        self.arrow.text=@"›"; self.arrow.font=[UIFont systemFontOfSize:44 weight:UIFontWeightLight]; self.arrow.textColor=[UIColor colorWithWhite:.38 alpha:.9]; self.arrow.textAlignment=NSTextAlignmentCenter;
        [self.blur.contentView addSubview:self.arrow];
    }
    return self;
}
@end

@interface LLNView ()
@property(nonatomic,strong) UIWindow *window;
@property(nonatomic,strong) LLNCardView *card;
@property(nonatomic,strong) NSTimer *timer;
@end

@implementation LLNView
+ (instancetype)shared { static LLNView *x; static dispatch_once_t once; dispatch_once(&once, ^{x=[self new];}); return x; }

- (UIWindow *)activeWindow {
    if (@available(iOS 13.0,*)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState==UISceneActivationStateForegroundActive && [scene isKindOfClass:UIWindowScene.class]) {
                UIWindowScene *ws=(UIWindowScene *)scene;
                for (UIWindow *w in ws.windows) if (!w.hidden && w.alpha>0 && w.windowLevel==UIWindowLevelNormal) return w;
                return ws.windows.firstObject;
            }
        }
    }
    return UIApplication.sharedApplication.keyWindow;
}

- (void)showName:(NSString *)name content:(NSString *)content badge:(NSInteger)badge avatar:(UIImage *)avatar {
    if (![LLNPref(@"enabled", @YES) boolValue]) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *base=[self activeWindow]; if(!base) return;
        UIWindowScene *scene=(UIWindowScene *)base.windowScene;
        if (!self.window) {
            self.window=[[UIWindow alloc] initWithWindowScene:scene];
            self.window.backgroundColor=UIColor.clearColor;
            self.window.windowLevel=UIWindowLevelStatusBar+1;
            self.window.userInteractionEnabled=YES;
            self.window.hidden=NO;
        } else if (scene && self.window.windowScene!=scene) self.window.windowScene=scene;
        self.window.frame=scene?scene.coordinateSpace.bounds:UIScreen.mainScreen.bounds;
        if(!self.card) { self.card=[[LLNCardView alloc] initWithFrame:CGRectMake(22, 116, self.window.bounds.size.width-44, 88)]; [self.window addSubview:self.card]; }
        self.card.frame=CGRectMake(22, 116, self.window.bounds.size.width-44, 88);
        self.card.name.text=name.length?name:@"微信消息";
        self.card.content.text=[LLNPref(@"showContent", @YES) boolValue] ? (content.length?content:@"新消息") : @"";
        BOOL showAvatar=[LLNPref(@"showAvatar", @YES) boolValue]; self.card.avatar.hidden=!showAvatar; self.card.ring.hidden=!showAvatar;
        if(showAvatar) self.card.avatar.image=avatar ?: [self defaultAvatar];
        BOOL showBadge=[LLNPref(@"showBadge", @YES) boolValue]; self.card.badge.hidden=!showBadge;
        self.card.badge.text=badge>99?@"99+":(badge>0?[NSString stringWithFormat:@"%ld",(long)badge]:@"1");
        self.card.alpha=0; self.card.transform=CGAffineTransformMakeTranslation(0,-18);
        [self.timer invalidate];
        [UIView animateWithDuration:.42 delay:0 usingSpringWithDamping:.78 initialSpringVelocity:.2 options:UIViewAnimationOptionCurveEaseOut animations:^{self.card.alpha=1; self.card.transform=CGAffineTransformIdentity;} completion:nil];
        NSTimeInterval duration=[LLNPref(@"duration", @3) doubleValue]; if(duration<1) duration=3;
        self.timer=[NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(hide) userInfo:nil repeats:NO];
    });
}

- (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{ if(!self.card) return; [UIView animateWithDuration:.28 animations:^{self.card.alpha=0; self.card.transform=CGAffineTransformMakeTranslation(0,-14);} completion:^(__unused BOOL f){ self.window.hidden=YES; }]; });
}

- (UIImage *)defaultAvatar {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(80,80),YES,0); [[UIColor colorWithRed:.12 green:.78 blue:.32 alpha:1] setFill]; UIRectFill(CGRectMake(0,0,80,80));
    NSDictionary *a=@{NSFontAttributeName:[UIFont systemFontOfSize:42 weight:UIFontWeightBold],NSForegroundColorAttributeName:UIColor.whiteColor}; [@"微" drawAtPoint:CGPointMake(18,15) withAttributes:a]; UIImage *im=UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext(); return im;
}
@end
