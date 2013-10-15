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
@property (nonatomic, strong) NSArray *timeline;
@property (nonatomic, strong) NSString *maxId;
@property (nonatomic, strong) UIManagedDocument *newsFeedDatabase;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSString *previousRequestDone;
@property (nonatomic, strong) NSCache *imageCache;

@end
