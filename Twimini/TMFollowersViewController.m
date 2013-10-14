#import "TMFollowersViewController.h"

@interface TMFollowersViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation TMFollowersViewController

@synthesize followersDatabase = _followersDatabase;

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.title = @"Followers";
  /*
  self.spinner = [[UIActivityIndicatorView alloc]
                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.spinner.center = CGPointMake(160, 240);
  [self.view addSubview:self.spinner];
  [self.spinner startAnimating];
   */
  [self setupFetchedResultsController];
  [self fetchFollowersDataIntoDocument:self.followersDatabase];
}

- (void)setupFetchedResultsController {
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
  request.predicate = [NSPredicate predicateWithFormat:@"username != %@ AND followerOf.username = %@", self.username, self.username];
  request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"username"
                                                                                   ascending:YES
                                                                                    selector:@selector(localizedCaseInsensitiveCompare:)]];
  
  self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                   initWithFetchRequest:request
                                   managedObjectContext:self.followersDatabase.managedObjectContext
                                   sectionNameKeyPath:nil
                                   cacheName:nil];
}

- (void)fetchFollowersDataIntoDocument:(UIManagedDocument *)document {
  self.followers = [[NSMutableArray alloc] init];
  NSURL *url = [NSURL URLWithString:FETCH_FOLLOWERS_URL];
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
        [self.followers addObjectsFromArray:[jsonResult objectForKey:@"users"]];
        [document.managedObjectContext performBlock:^{
          User *user = [User userWithUsername:self.username
                                         name:nil
                                     imageURL:nil
                                   followerOf:Nil
                                     friendOf:Nil
                       inManagedObjectContext:document.managedObjectContext];
          for (NSDictionary *followers in self.followers) {
            [User userWithUsername:[followers objectForKey:@"screen_name"]
                              name:[followers objectForKey:@"name"]
                          imageURL:[followers objectForKey:@"profile_image_url"]
                        followerOf:user
                          friendOf:Nil
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
  
  User *follower = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.name.text = follower.name;
  cell.username.text = follower.username;
  
  NSURL *url = [NSURL URLWithString:follower.imageURL];
  UIImage *image = [self.imageCache objectForKey:url];

  if(image) {
    cell.imageView.image = image;
  }
  else {
    dispatch_queue_t imageLoader = dispatch_queue_create("imageLoader", NULL);
    dispatch_async(imageLoader, ^{
      NSData *imageData = [NSData dataWithContentsOfURL:url];
      if(imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        [self.imageCache setObject:image forKey:url];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = [UIImage imageWithData:imageData];
      });
    });
  }
  
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