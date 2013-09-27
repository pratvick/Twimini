#import "FriendsListViewController.h"

@interface FriendsListViewController()

- (void)fetchData;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation FriendsListViewController

@synthesize account = _account;
@synthesize friends = _friends;
@synthesize friendIds = _friendIds;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _friends = [[NSMutableArray alloc] init];
        [self fetchData];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"Friends";
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(160, 240);
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    [self fetchData];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Data management
- (void)fetchData
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url
                                             parameters:nil
                                          requestMethod:TWRequestMethodGET];
    [request setAccount:self.account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (jsonResult != nil)
            {
                [self.friends addObjectsFromArray:[jsonResult objectForKey:@"users"]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
            else {
                NSLog(@"Could not parse your friends list");
            }
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    id friend = [self.friends objectAtIndex:[indexPath row]];
    cell.textLabel.text = [friend objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", [friend objectForKey:@"screen_name"]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [friend objectForKey:@"profile_image_url"]]];
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    [self.spinner stopAnimating];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end