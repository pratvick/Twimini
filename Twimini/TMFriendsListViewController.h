#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "Constants.h"

@interface TMFriendsListViewController : UITableViewController

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSMutableArray *friends;

@end
