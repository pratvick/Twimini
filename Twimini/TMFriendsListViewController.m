#import "TMFriendsListViewController.h"

@interface TMFriendsListViewController()

- (void)fetchData;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation TMFriendsListViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.title = @"Friends";
  self.spinner = [[UIActivityIndicatorView alloc]
                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.spinner.center = CGPointMake(160, 240);
  [self.view addSubview:self.spinner];
  [self.spinner startAnimating];
  [self fetchData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)fetchData {
  self.friends = [[NSMutableArray alloc] init];
  
  NSURL *url = [NSURL URLWithString:FETCH_FRIENDS_URL];
  TWRequest *request = [[TWRequest alloc] initWithURL:url
                                           parameters:nil
                                        requestMethod:TWRequestMethodGET];
  [request setAccount:self.account];
  [request performRequestWithHandler:^(NSData *responseData,
                                       NSHTTPURLResponse *urlResponse,
                                       NSError *error) {
    if ([urlResponse statusCode] == 200) {
      NSError *jsonError = nil;
      id jsonResult = [NSJSONSerialization
                       JSONObjectWithData:responseData
                       options:0
                       error:&jsonError];
      if (jsonResult != nil){
        [self.friends addObjectsFromArray:[jsonResult objectForKey:@"users"]];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.tableView reloadData];
        });
      }
      else {
        NSLog(@"Could not parse your friends list");
      }
    }
  }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:CellIdentifier];
  }
  
  id friend = [self.friends objectAtIndex:[indexPath row]];
  cell.textLabel.text = [friend objectForKey:@"name"];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@",
                               [friend objectForKey:@"screen_name"]];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",
                                     [friend objectForKey:@"profile_image_url"]]];
  
  dispatch_queue_t imageLoader = dispatch_queue_create("imageLoader", NULL);
  
  dispatch_async(imageLoader, ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    });
  });
  
  [self.spinner stopAnimating];
  
  return cell;
}

@end