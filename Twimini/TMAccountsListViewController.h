#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "TMProfileViewController.h"
#import "FHSTwitterEngine.h"

@interface TMAccountsListViewController : UITableViewController

@property (strong, nonatomic) ACAccountStore *accountStore; 
@property (strong, nonatomic) NSArray *accounts;
//@property (strong, nonatomic) NSArray *tweets;

@end
