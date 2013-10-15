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

@interface TMProfileViewController : TMCoreDataTableViewController <TMTweetComposeViewControllerDelegate>

@property (nonatomic, strong) ACAccount *account;
@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) NSString *maxId;
@property (nonatomic, strong) UIManagedDocument *tweetDatabase;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *previousRequestDone;

@end
