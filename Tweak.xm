#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <Foundation/Foundation.h>
#import "LLNView.h"

static NSString * const kPID = @"com.lengleng.liquidnotice";
static NSMutableDictionary *gOriginalIMPs;

static id Pref(NSString *key, id fallback) {
    id v=CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, (__bridge CFStringRef)kPID));
    return v ?: fallback;
}

static NSString *StringFromObject(id obj, NSArray<NSString *> *keys) {
    for(NSString *key in keys){ @try { id v=[obj valueForKey:key]; if([v isKindOfClass:NSString.class] && ((NSString *)v).length) return v; } @catch(__unused id e){} }
    return @"";
}

static UIImage *ImageFromObject(id obj, NSArray<NSString *> *keys) {
    for(NSString *key in keys){ @try { id v=[obj valueForKey:key]; if([v isKindOfClass:UIImage.class]) return v; if([v isKindOfClass:NSString.class]) { UIImage *im=[UIImage imageWithContentsOfFile:v]; if(im) return im; } } @catch(__unused id e){} }
    return nil;
}

static void ShowMessage(id wrap) {
    if(![Pref(@"enabled",@YES) boolValue]) return;
    NSString *name=StringFromObject(wrap,@[@"m_nsPushContactName",@"m_nsFromUsr",@"m_nsChatName",@"m_nsNickName"]);
    NSString *content=StringFromObject(wrap,@[@"m_nsContent",@"m_nsMsgContent",@"m_nsPushContent"]);
    if(content.length>180) content=[content substringToIndex:180];
    UIImage *avatar=ImageFromObject(wrap,@[@"m_avatarImage",@"m_nsAvatarPath",@"m_nsHeadImgPath"]);
    [[LLNView shared] showName:name content:content badge:1 avatar:avatar];
}

// CMessageMgr is intentionally discovered at runtime because WeChat changes its binary class layout.
static void (*origAsyncOnAddMsg)(id,SEL,id,id);
static void hookAsyncOnAddMsg(id self, SEL _cmd, id msg, id wrap) {
    if(origAsyncOnAddMsg) origAsyncOnAddMsg(self,_cmd,msg,wrap);
    ShowMessage(wrap ?: msg);
}

static void HookCMessageMgr(void) {
    Class cls=NSClassFromString(@"CMessageMgr"); if(!cls) return;
    SEL sel=NSSelectorFromString(@"AsyncOnAddMsg:MsgWrap:"); Method m=class_getInstanceMethod(cls,sel); if(!m) return;
    static dispatch_once_t once; dispatch_once(&once, ^{ origAsyncOnAddMsg=(void(*)(id,SEL,id,id))method_getImplementation(m); method_setImplementation(m,(IMP)hookAsyncOnAddMsg); });
}

static void (*origWillPresent)(id,SEL,UNUserNotificationCenter*,UNNotification*,void(^)(UNNotificationPresentationOptions));
static void hookWillPresent(id self, SEL _cmd, UNUserNotificationCenter *center, UNNotification *note, void (^completion)(UNNotificationPresentationOptions)) {
    UNNotificationRequest *r=note.request; NSString *title=r.content.title; NSString *body=r.content.body;
    if(title.length || body.length) [[LLNView shared] showName:title.length?title:@"微信消息" content:body badge:1 avatar:nil];
    if(origWillPresent) origWillPresent(self,_cmd,center,note,completion); else if(completion) completion(UNNotificationPresentationOptionBanner|UNNotificationPresentationOptionSound);
}

static void HookNotificationDelegate(void) {
    UNUserNotificationCenter *c=UNUserNotificationCenter.currentNotificationCenter; id d=c.delegate; if(!d) return;
    Class cls=object_getClass(d); SEL sel=@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:); Method m=class_getInstanceMethod(cls,sel); if(!m) return;
    static dispatch_once_t once; dispatch_once(&once, ^{ origWillPresent=(void(*)(id,SEL,UNUserNotificationCenter*,UNNotification*,void(^)(UNNotificationPresentationOptions)))method_getImplementation(m); method_setImplementation(m,(IMP)hookWillPresent); });
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(![NSBundle.mainBundle.bundleIdentifier.lowercaseString containsString:@"wechat"]) return;
        HookCMessageMgr(); HookNotificationDelegate();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ HookCMessageMgr(); HookNotificationDelegate(); });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(8*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ HookCMessageMgr(); HookNotificationDelegate(); });
    });
}
