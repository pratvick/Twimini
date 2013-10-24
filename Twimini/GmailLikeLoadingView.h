#import <UIKit/UIKit.h>

@interface GmailLikeLoadingView : UIView
-(void)startAnimating;
-(void)stopAnimating;
@property (nonatomic) BOOL isAnimating;

@end
