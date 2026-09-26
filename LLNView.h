#import <UIKit/UIKit.h>

@interface LLNView : NSObject
+ (instancetype)shared;
- (void)showName:(NSString *)name content:(NSString *)content badge:(NSInteger)badge avatar:(UIImage *)avatar;
@end
