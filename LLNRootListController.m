#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface LLNRootListController : PSListController
@end

@implementation LLNRootListController
- (instancetype)init { self=[super init]; if(self){ self.title=@"液态玻璃消息通知"; } return self; }
- (NSArray *)specifiers { if(!_specifiers) _specifiers=[self loadSpecifiersFromPlistName:@"Root" target:self]; return _specifiers; }
- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSDictionary *defaults=@{ @"enabled":@YES, @"showAvatar":@YES, @"showBadge":@YES, @"showContent":@YES, @"duration":@3 };
    id v=[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.lengleng.liquidnotice"][specifier.properties[@"key"]];
    return v ?: defaults[specifier.properties[@"key"]];
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key=specifier.properties[@"key"];
    NSMutableDictionary *d=[[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.lengleng.liquidnotice"] mutableCopy] ?: [NSMutableDictionary dictionary];
    if(value) d[key]=value; else [d removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:d forName:@"com.lengleng.liquidnotice"];
    CFPreferencesAppSynchronize(CFSTR("com.lengleng.liquidnotice"));
}
@end
