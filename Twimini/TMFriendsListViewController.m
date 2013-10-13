#import "TMFriendsListViewController.h"

@interface TMFriendsListViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation TMFriendsListViewController

@synthesize friendsDatabase = _friendsDatabase;

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.title = @"Friends";
  /*
   self.spinner = [[UIActivityIndicatorView alloc]
   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   self.spinner.center = CGPointMake(160, 240);
   [self.view addSubview:self.spinner];
   [self.spinner startAnimating];
   */
  [self setupFetchedResultsController];
  [self fetchFriendsDataIntoDocument:self.friendsDatabase];
}

- (void)setupFetchedResultsController {
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
  request.predicate = [NSPredicate predicateWithFormat:@"username != %@ AND friendOf.username = %@", self.username, self.username];
  request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"username"
                                                                                   ascending:YES
                                                                                    selector:@selector(localizedCaseInsensitiveCompare:)]];
  
  self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                   initWithFetchRequest:request
                                   managedObjectContext:self.friendsDatabase.managedObjectContext
                                   sectionNameKeyPath:nil
                                   cacheName:nil];
}

- (void)fetchFriendsDataIntoDocument:(UIManagedDocument *)document {
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
      id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData
                                                      options:0
                                                        error:&jsonError];
      //[self.spinner stopAnimating];
      if (jsonResult != nil) {
        [self.friends addObjectsFromArray:[jsonResult objectForKey:@"users"]];
        [document.managedObjectContext performBlock:^{
          User *user = [User userWithUsername:self.username
                                         name:nil
                                     imageURL:nil
                                   followerOf:Nil
                                     friendOf:Nil
                       inManagedObjectContext:document.managedObjectContext];
          for (NSDictionary *friends in self.friends) {
            [User userWithUsername:[friends objectForKey:@"screen_name"]
                              name:[friends objectForKey:@"name"]
                          imageURL:[friends objectForKey:@"profile_image_url"]
                        followerOf:Nil
                          friendOf:user
            inManagedObjectContext:document.managedObjectContext];
          }
          [document saveToURL:document.fileURL
             forSaveOperation:UIDocumentSaveForOverwriting
            completionHandler:^(BOOL success) {
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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"UserCell";
  
  UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
  }
  
  User *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.name.text = friend.name;
  cell.username.text = friend.username;
  
  NSURL *url = [NSURL URLWithString:friend.imageURL];
  
  dispatch_queue_t imageLoader = dispatch_queue_create("imageLoader", NULL);
  dispatch_async(imageLoader, ^{
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    dispatch_async(dispatch_get_main_queue(), ^{
      UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
      cell.imageView.image = [UIImage imageWithData:imageData];
    });
  });
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  NSString *title = user.name;
  CGFloat maxWidth = self.tableView.bounds.size.width - 74;
  CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:16]
                       constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat cellHeight = ceil(titleSize.height + 37.0);
  
  return cellHeight;
}

@end