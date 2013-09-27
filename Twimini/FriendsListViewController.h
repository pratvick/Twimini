#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface FriendsListViewController : UITableViewController

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSArray *friendIds;
@property (strong, nonatomic) NSMutableArray *friends;

@end
