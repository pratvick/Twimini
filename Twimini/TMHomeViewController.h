#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TMTweetComposeViewController.h"
#import "TMCoreDataTableViewController.h"
#import "TMFriendsListViewController.h"
#import "TMFollowersViewController.h"
#import "Constants.h"
#import "Tweet+Data.h"
#import "TweetCell.h"
#import <UIKit/UIRefreshControl.h>

@interface TMHomeViewController : TMCoreDataTableViewController

@property (nonatomic, strong) ACAccount *account;
@property (nonatomic, strong) UIManagedDocument *newsFeedDatabase;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSCache *imageCache;

@end
