#import "TMFollowersViewController.h"

@interface TMFollowersViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation TMFollowersViewController

@synthesize followersDatabase = _followersDatabase;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Followers";
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(160, 240);
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    [self setupFetchedResultsController];
    [self fetchFollowersDataIntoDocument:self.followersDatabase];
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"followerOf.username = %@", self.username];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.followersDatabase.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)fetchFollowersDataIntoDocument:(UIManagedDocument *)document
{
    self.followers = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url
                                             parameters:nil
                                          requestMethod:TWRequestMethodGET];
    [request setAccount:self.account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (jsonResult != nil) {
                [self.followers addObjectsFromArray:[jsonResult objectForKey:@"users"]];
                [document.managedObjectContext performBlock:^{
                    User *user = [User userWithUsername:self.username name:self.name
                                   inManagedObjectContext:document.managedObjectContext];
                    for (NSDictionary *followers in self.followers) {
                        [User userWithUsername:[followers objectForKey:@"screen_name"] name:[followers objectForKey:@"name"] followerOf:user inManagedObjectContext:document.managedObjectContext];
                    }
                    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
                        if(success)
                            NSLog(@"Document saved successfully");
                        else
                            NSLog(@"Document is not saved");
                    }];
                }];
            }
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = user.name;
    cell.detailTextLabel.text = user.username;
  
    [self.spinner stopAnimating];

    return cell;
}

@end