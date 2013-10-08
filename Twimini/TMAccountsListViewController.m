#import "TMAccountsListViewController.h"

@interface TMAccountsListViewController () // <FHSTwitterEngineAccessTokenDelegate>

- (void)fetchData;

@end

@implementation TMAccountsListViewController

/*
- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}
*/

- (void)viewDidLoad {
    [self fetchData];
    /*
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"2arkQ9UTBOa79fdcgaig" andSecret:@"X5N00w9MsEgXTj59hJpAfSgBMLpFD73vXhq0ZtnQA"];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    */
}

- (void)fetchData {
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [self.accountStore
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:nil
                                            completion:^(BOOL granted, NSError *error){
                                                if (granted) {
                                                    self.accounts = [self.accountStore
                                                                     accountsWithAccountType:accountType];
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.tableView reloadData];
                                                    });
                                                }else
                                                {
                                                    NSLog(@"No access granted");
                                                }
                                            }];
    /*
    [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:self 
                                                                 withCompletion:^(BOOL success) {
        NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
        [[FHSTwitterEngine sharedEngine] getHomeTimelineWithSuccessBlock:^(BOOL success, id json){
            self.tweets = json;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } count:20];
    }];
    */
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Accounts List";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    ACAccount *account = [self.accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = account.username;
    cell.detailTextLabel.text = account.description;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Account"]) {
        TMProfileViewController *profileViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ACAccount *account = [self.accounts objectAtIndex:indexPath.row];
        profileViewController.account = account;
    }
}

@end
