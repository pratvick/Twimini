#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TMCoreDataTableViewController.h"
#import "User+Info.h"
#import "User.h"
#import "Constants.h"
#import "UserCell.h"

@interface TMFriendsListViewController : TMCoreDataTableViewController

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) UIManagedDocument *friendsDatabase;
@property (strong, nonatomic) NSString *username;
@property (nonatomic, strong) NSCache *imageCache;

@end
