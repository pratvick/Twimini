#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TMTweetComposeViewController.h"
#import "CoreDataTableViewController.h"
#import "TMFriendsListViewController.h"
#import "TMFollowersViewController.h"
#import "Constants.h"
#import "Tweet+Data.h"
#import "TweetCell.h"
#import <UIKit/UIRefreshControl.h>

@interface TMHomeViewController : CoreDataTableViewController

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSArray *timeline;
@property (strong, nonatomic) NSString *maxId;
@property (strong, nonatomic) NSString *previousMaxId;
@property (strong, nonatomic) UIManagedDocument *newsFeedDatabase;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *name;

@end
