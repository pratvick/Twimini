#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface TMAccountsListViewController : UITableViewController

@property (strong, nonatomic) ACAccountStore *accountStore; 
@property (strong, nonatomic) NSArray *accounts;
//@property (strong, nonatomic) NSArray *tweets;

@end
