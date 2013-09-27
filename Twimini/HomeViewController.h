#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TweetComposeViewController.h"
#import "CoreDataTableViewController.h"

@interface HomeViewController : CoreDataTableViewController <TweetComposeViewControllerDelegate>

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSArray *timeline;
@property (strong, nonatomic) NSString *maxId;
@property (strong, nonatomic) UIManagedDocument *newsFeedDatabase;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *name;

@end
