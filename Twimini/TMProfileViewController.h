#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TMTweetComposeViewController.h"
#import "CoreDataTableViewController.h"
#import "TMTweetComposeViewController.h"
#import "TMFriendsListViewController.h"
#import "TMFollowersViewController.h"
#import "TMHomeViewController.h"
#import "Tweet.h"
#import "User.h"
#import "Tweet+Data.h"
#import "User+Info.h"
#import "Constants.h"
#import "TweetCell.h"
#import <UIKit/UIRefreshControl.h>

@interface TMProfileViewController : CoreDataTableViewController <TMTweetComposeViewControllerDelegate>

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) NSString *maxId;
@property (strong, nonatomic) NSString *previousMaxId;
@property (nonatomic, strong) UIManagedDocument *tweetDatabase;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageURL;

@end
