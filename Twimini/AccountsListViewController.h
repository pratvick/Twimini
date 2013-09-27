#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface AccountsListViewController : UITableViewController

@property (strong, nonatomic) ACAccountStore *accountStore; 
@property (strong, nonatomic) NSArray *accounts;

@end
