#import <UIKit/UIKit.h>
#import <UIKit/UIRefreshControl.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TMTweetComposeViewController.h"
#import "TMCoreDataTableViewController.h"
#import "TMTweetComposeViewController.h"
#import "TMFriendsListViewController.h"
#import "TMFollowersViewController.h"
#import "TMHomeViewController.h"
#import "Tweet+Data.h"
#import "User+Info.h"
#import "Constants.h"
#import "TweetCell.h"
#import "UIView+Explode.h"

@interface TMProfileViewController : TMCoreDataTableViewController <TMTweetComposeViewControllerDelegate>

@property (nonatomic, strong) ACAccount *account;
@property (nonatomic, strong) UIManagedDocument *tweetDatabase;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSCache *imageCache;

@end
