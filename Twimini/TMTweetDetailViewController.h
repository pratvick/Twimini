#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TMProfileViewController.h"
#import "User.h"

@interface TMTweetDetailViewController : UIViewController

@property (strong, nonatomic) Tweet *tweet;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;

@end
