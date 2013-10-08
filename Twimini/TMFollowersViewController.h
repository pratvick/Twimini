#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "CoreDataTableViewController.h"
#import "User+Info.h"
#import "User.h"
#import "Constants.h"

@interface TMFollowersViewController : CoreDataTableViewController

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSMutableArray *followers;
@property (strong, nonatomic) UIManagedDocument *followersDatabase;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *name;

@end
