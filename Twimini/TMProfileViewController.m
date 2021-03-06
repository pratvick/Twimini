#import "TMProfileViewController.h"

@interface TMProfileViewController()

@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) NSString *maxId;
@property (nonatomic, strong) NSString *previousRequestDone;
@property (nonatomic, strong) GmailLikeLoadingView *loadingView;

@end

@implementation TMProfileViewController

@synthesize tweetDatabase = _tweetDatabase;

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!self.tweetDatabase) {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask]lastObject];
    url = [url URLByAppendingPathComponent:@"Twitter Database"];
    self.tweetDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
  }
}

- (void)flipViewsFromView:initialView toView:finalView {
  [UIView transitionFromView:initialView
                      toView:finalView
                    duration:1
                     options:UIViewAnimationOptionTransitionFlipFromBottom
                  completion:nil];
}

- (void)setTweetDatabase:(UIManagedDocument *)tweetDatabase {
  if (_tweetDatabase != tweetDatabase) {
    _tweetDatabase = tweetDatabase;
    [self useDocument];
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

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.loadingView = [[GmailLikeLoadingView alloc] initWithFrame:CGRectMake(
                              self.view.center.x - 30, self.view.center.y - 40, 40, 40
                                                                            )];
  [self.view addSubview:self.loadingView];
  [self.loadingView startAnimating];

  self.imageCache = [[NSCache alloc] init];
  
  UINib *tweetNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
  [self.tableView registerNib:tweetNib forCellReuseIdentifier:@"TweetCell"];
  
  
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull down to refresh"];
  [refreshControl addTarget:self action:@selector(refresh)
           forControlEvents:UIControlEventValueChanged];
  self.refreshControl = refreshControl;
  
  UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                           target:self
                                                                           action:@selector(composeTweet)];
  
  UIImage *friendsImage = [UIImage imageNamed:@"user.png"];
  UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithImage:friendsImage
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

- (void)composeTweet {
  TMTweetComposeViewController *tweetComposeViewController = [[TMTweetComposeViewController alloc]
                                                              init];
  tweetComposeViewController.account = self.account;
  tweetComposeViewController.tweetComposeDelegate = self;
  [self presentViewController:tweetComposeViewController animated:YES completion:nil];
}

- (void)tweetComposeViewController:(TMTweetComposeViewController *)controller
               didFinishWithResult:(TweetComposeResult)result {
  if(result == TweetComposeResultFailed) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                      message:@"Error in posting your tweet"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Ok", nil];
      dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
      });
    });
  }
  
  [self fetchTweetDataIntoDocument:self.tweetDatabase];
}

- (void)getFriends {
  TMFriendsListViewController *friendsListViewController = [[TMFriendsListViewController alloc]
                                                            init];
  friendsListViewController.account = self.account;
  friendsListViewController.user = self.user;
  friendsListViewController.friendsDatabase = self.tweetDatabase;
  friendsListViewController.imageCache = self.imageCache;
  [self flipViewsFromView:self.view toView:friendsListViewController.view];
  [self.navigationController pushViewController:friendsListViewController animated:TRUE];
}

- (void)getHome {
  TMHomeViewController *homeViewController = [[TMHomeViewController alloc] init];
  homeViewController.account = self.account;
  homeViewController.user = self.user;
  homeViewController.imageCache = self.imageCache;
  homeViewController.newsFeedDatabase = self.tweetDatabase;
  [self flipViewsFromView:self.view toView:homeViewController.view];
  [self.navigationController pushViewController:homeViewController animated:TRUE];
}

-(void)getFollowers {
  TMFollowersViewController *followersViewController = [[TMFollowersViewController alloc] init];
  followersViewController.account = self.account;
  followersViewController.user = self.user;
  followersViewController.imageCache = self.imageCache;
  followersViewController.followersDatabase = self.tweetDatabase;
  [self flipViewsFromView:self.view toView:followersViewController.view];
  [self.navigationController pushViewController:followersViewController animated:TRUE];
}

- (void)fetchTweetDataIntoDocument:(UIManagedDocument *)document {
  NSString *urlString = [[NSString alloc] initWithFormat:@"%@", FETCH_USER_PROFILE_URL];
  [self fetchTweetsFromURL:urlString withDocument:document];
}

- (void)fetchPreviousTweetDataIntoDocument:(UIManagedDocument *)document {
  static NSString *done = @"DONE";
  if([self.previousRequestDone isEqualToString:done]){
    self.previousRequestDone = @"NOT DONE";
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@?max_id=%@",
                                                                FETCH_USER_PROFILE_URL, self.maxId];
    [self fetchTweetsFromURL:urlString
                withDocument:document];
  }
}

- (void)fetchTweetsFromURL:(NSString *)urlString
              withDocument:(UIManagedDocument *)document {
  __block NSString *maxId = nil;
  __block BOOL userAssigned = FALSE;
  
  self.tweets = [[NSArray alloc] init];
  
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
            maxId = [tweetInfo objectForKey:@"id"];
            [Tweet tweetWithInfo:tweetInfo
          inManagedObjectContext:document.managedObjectContext];
            if(userAssigned == FALSE) {
              self.user = [User userWithUsername:[tweetInfo valueForKeyPath:@"user.screen_name"]
                                            name:[tweetInfo valueForKeyPath:@"user.name"]
                                        imageURL:[tweetInfo valueForKeyPath:@"user.profile_image_url"]
                                      followerOf:Nil
                                        friendOf:Nil
                          inManagedObjectContext:document.managedObjectContext];
              userAssigned = TRUE;
            }
          }
          self.previousRequestDone = @"DONE";
          self.maxId = maxId;
          [self.loadingView stopAnimating];
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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"TweetCell";
  
  TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.textLabel.text = tweet.text;
  cell.detailTextLabel.text = tweet.whoWrote.username;
  
  NSTimeInterval interval = [tweet.timestamp doubleValue];
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
  
  cell.timeLabel.text = [dateFormatter stringFromDate:date];
  
  NSURL *url = [NSURL URLWithString:tweet.whoWrote.imageURL];
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
        TweetCell *cell = (TweetCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = [UIImage imageWithData:imageData];
      });
    });
  }
  
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroll {
  CGPoint offset = scroll.contentOffset;
  CGRect bounds = scroll.bounds;
  CGSize size = scroll.contentSize;
  UIEdgeInsets inset = scroll.contentInset;
  float y = offset.y + bounds.size.height - inset.bottom;
  float h = size.height;
  
  float reload_distance = 3.0;
  
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.tweetDatabase.managedObjectContext deleteObject:tweet];
  }
}

@end