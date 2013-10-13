#import "TMProfileViewController.h"

@interface TMProfileViewController()

@end

@implementation TMProfileViewController

@synthesize tweetDatabase = _tweetDatabase;

- (void)composeTweet {
  TMTweetComposeViewController *tweetComposeViewController = [[TMTweetComposeViewController alloc]
                                                              init];
  tweetComposeViewController.account = self.account;
  tweetComposeViewController.tweetComposeDelegate = self;
  [self presentViewController:tweetComposeViewController animated:YES completion:nil];
}

- (void)tweetComposeViewController:(TMTweetComposeViewController *)controller
               didFinishWithResult:(TweetComposeResult)result {
  [self dismissViewControllerAnimated:YES completion:nil];
  [self fetchTweetDataIntoDocument:self.tweetDatabase];
}

- (void)getFriends {
  TMFriendsListViewController *friendsListViewController = [[TMFriendsListViewController alloc]
                                                            init];
  friendsListViewController.account = self.account;
  friendsListViewController.username = self.username;
  friendsListViewController.friendsDatabase = self.tweetDatabase;
  [self.navigationController pushViewController:friendsListViewController animated:TRUE];
}

- (void)getHome {
  TMHomeViewController *homeViewController = [[TMHomeViewController alloc] init];
  homeViewController.account = self.account;
  homeViewController.name = self.name;
  homeViewController.username = self.username;
  homeViewController.newsFeedDatabase = self.tweetDatabase;
  [self.navigationController pushViewController:homeViewController animated:TRUE];
}

-(void)getFollowers {
  TMFollowersViewController *followersViewController = [[TMFollowersViewController alloc] init];
  followersViewController.account = self.account;
  followersViewController.username = self.username;
  followersViewController.followersDatabase = self.tweetDatabase;
  [self.navigationController pushViewController:followersViewController animated:TRUE];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull to Refresh"];
  [refreshControl addTarget:self action:@selector(refresh)
           forControlEvents:UIControlEventValueChanged];
  self.refreshControl = refreshControl;
  
  UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                           target:self
                                                                           action:@selector(composeTweet)];
  
  UIImage *image = [UIImage imageNamed:@"friends.png"];
  UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithImage:image
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(getFriends)];
  
  UIImage *followersImage = [UIImage imageNamed:@"friends@2x.png"];
  UIBarButtonItem *followers = [[UIBarButtonItem alloc] initWithImage:followersImage
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(getFollowers)];
  
  UIImage *homeImage = [UIImage imageNamed:@"home.png"];
  UIBarButtonItem *home = [[UIBarButtonItem alloc] initWithImage:homeImage
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(getHome)];
  
  self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:friends,
                                             compose,
                                             followers,
                                             home,
                                             nil];
}

- (void)setupFetchedResultsController {
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
  request.predicate = [NSPredicate predicateWithFormat:@"whoWrote.username = %@", self.account.username];
  request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp"
                                                                                   ascending:NO
                                                                                    selector:nil]];
  
  self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                   initWithFetchRequest:request
                                   managedObjectContext:self.tweetDatabase.managedObjectContext
                                   sectionNameKeyPath:nil
                                   cacheName:nil];
}

- (void)fetchTweetDataIntoDocument:(UIManagedDocument *)document {
  self.tweets = [[NSArray alloc] init];
  NSString *urlString = nil;
  
  urlString = [[NSString alloc] initWithFormat:@"%@", FETCH_USER_PROFILE_URL];
  NSURL *url = [NSURL URLWithString:urlString];
  
  TWRequest *request = [[TWRequest alloc] initWithURL:url
                                           parameters:nil
                                        requestMethod:TWRequestMethodGET];
  [request setAccount:self.account];
  [request performRequestWithHandler:^(NSData *responseData,
                                       NSHTTPURLResponse *urlResponse,
                                       NSError *error) {
    if ([urlResponse statusCode] == 200) {
      NSError *jsonError = nil;
      NSArray *jsonResult = [NSJSONSerialization JSONObjectWithData:responseData
                                                            options:0
                                                              error:&jsonError];
      if (jsonResult != nil) {
        self.tweets = jsonResult;
        [document.managedObjectContext performBlock:^{
          for (NSDictionary *tweetInfo in self.tweets) {
            NSString *Id = [tweetInfo objectForKey:@"id"];
            if(self.maxId < Id)
              self.maxId = Id;
            self.username = [[tweetInfo objectForKey:@"user"] objectForKey:@"screen_name"];
            self.name = [[tweetInfo objectForKey:@"user"] objectForKey:@"name"];
            self.imageURL = [[tweetInfo objectForKey:@"user"] objectForKey:@"profile_image_url"];
            [Tweet tweetWithInfo:tweetInfo
          inManagedObjectContext:document.managedObjectContext];
          }
          [document saveToURL:document.fileURL
             forSaveOperation:UIDocumentSaveForOverwriting
            completionHandler:^(BOOL success){
              if(success)
                NSLog(@"Document saved successfully");
              else
                NSLog(@"Document is not saved");
            }];
        }];
      }
      else
        NSLog(@"Could not parse your timeline: %@", [jsonError localizedDescription]);
    }
    else
      NSLog(@"The response received an unexpected status code of %d", urlResponse.statusCode);
  }];
}

- (void)fetchPreviousTweetDataIntoDocument:(UIManagedDocument *)document {
  self.tweets = [[NSArray alloc] init];
  NSString *urlString = nil;
  
  if(self.maxId > self.previousMaxId){
    self.previousMaxId = self.maxId;
    urlString = [[NSString alloc] initWithFormat:@"%@?max_id=%@", FETCH_USER_PROFILE_URL, self.maxId];
    
    NSURL *url = [NSURL URLWithString:urlString];
    TWRequest *request = [[TWRequest alloc] initWithURL:url
                                             parameters:nil
                                          requestMethod:TWRequestMethodGET];
    [request setAccount:self.account];
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) {
      if ([urlResponse statusCode] == 200) {
        NSError *jsonError = nil;
        NSArray *jsonResult = [NSJSONSerialization JSONObjectWithData:responseData
                                                              options:0
                                                                error:&jsonError];
        if (jsonResult != nil) {
          self.tweets = jsonResult;
          [document.managedObjectContext performBlock:^{
            for (NSDictionary *tweetInfo in self.tweets) {
              NSString *Id = [tweetInfo objectForKey:@"id"];
              if(self.maxId < Id)
                self.maxId = Id;
              self.username = [[tweetInfo objectForKey:@"user"] objectForKey:@"screen_name"];
              self.name = [[tweetInfo objectForKey:@"user"] objectForKey:@"name"];
              self.imageURL = [[tweetInfo objectForKey:@"user"] objectForKey:@"profile_image_url"];
              [Tweet tweetWithInfo:tweetInfo
            inManagedObjectContext:document.managedObjectContext];
            }
            [document saveToURL:document.fileURL
               forSaveOperation:UIDocumentSaveForOverwriting
              completionHandler:^(BOOL success){
                if(success)
                  NSLog(@"Document saved successfully");
                else
                  NSLog(@"Document is not saved");
              }];
          }];
        }
        else
          NSLog(@"Could not parse your timeline: %@", [jsonError localizedDescription]);
      }
      else
        NSLog(@"The response received an unexpected status code of %d", urlResponse.statusCode);
    }];
  }
}

- (void)useDocument {
  if (![[NSFileManager defaultManager] fileExistsAtPath:[self.tweetDatabase.fileURL path]]) {
    [self.tweetDatabase saveToURL:self.tweetDatabase.fileURL
                 forSaveOperation:UIDocumentSaveForCreating
                completionHandler:^(BOOL success) {
                  if(success){
                    [self setupFetchedResultsController];
                    [self fetchTweetDataIntoDocument:self.tweetDatabase];
                  }
                }];
  } else if (self.tweetDatabase.documentState == UIDocumentStateClosed) {
    [self.tweetDatabase openWithCompletionHandler:^(BOOL success) {
      if(success){
        [self setupFetchedResultsController];
        [self fetchTweetDataIntoDocument:self.tweetDatabase];
      }
    }];
  } else {
    [self setupFetchedResultsController];
    [self fetchTweetDataIntoDocument:self.tweetDatabase];
  }
}

- (void)setTweetDatabase:(UIManagedDocument *)tweetDatabase {
  if (_tweetDatabase != tweetDatabase) {
    _tweetDatabase = tweetDatabase;
    [self useDocument];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!self.tweetDatabase) {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask]lastObject];
    url = [url URLByAppendingPathComponent:@"Twitter Database"];
    self.tweetDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"TweetCell";
  
  TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
  }
  
  Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.textLabel.text = tweet.text;
  cell.detailTextLabel.text = tweet.whoWrote.username;
  cell.timeLabel.text = [tweet.timestamp stringValue];
  
  NSURL *url = [NSURL URLWithString:tweet.whoWrote.imageURL];
  
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
  Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  NSString *title = tweet.text;
  CGFloat maxWidth = self.tableView.bounds.size.width - 74;
  CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:16]
                       constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat cellHeight = ceil(titleSize.height + 37.0);
  
  return cellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
  CGPoint offset = scroll.contentOffset;
  CGRect bounds = scroll.bounds;
  CGSize size = scroll.contentSize;
  UIEdgeInsets inset = scroll.contentInset;
  float y = offset.y + bounds.size.height - inset.bottom;
  float h = size.height;
  
  float reload_distance = 10;
  
  if(y > h + reload_distance) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
      [self fetchPreviousTweetDataIntoDocument:self.tweetDatabase];
    });
  }
}

- (void)refresh {
  [self.refreshControl beginRefreshing];
  dispatch_queue_t refreshQueue = dispatch_queue_create("refreshQueue", NULL);
  dispatch_async(refreshQueue,^{
    [self fetchTweetDataIntoDocument:self.tweetDatabase];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing"];
      
      NSDateFormatter *formattedDate = [[NSDateFormatter alloc]init];
      [formattedDate setDateFormat:@"MMM d, h:mm a"];
      NSString *lastupdated = [NSString stringWithFormat:@"Last Updated on %@",
                               [formattedDate stringFromDate:[NSDate date]]];
      
      self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:lastupdated];
      [self.refreshControl endRefreshing];
    });
  });
}

@end