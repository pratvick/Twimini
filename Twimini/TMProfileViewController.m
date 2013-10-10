#import "TMProfileViewController.h"

@interface TMProfileViewController()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation TMProfileViewController

@synthesize tweetDatabase = _tweetDatabase;

#define MAINLABEL_TAG 1
#define SECONDLABEL_TAG 2
#define PHOTO_TAG 3

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
    followersViewController.name = self.name;
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
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"text"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:self.tweetDatabase.managedObjectContext
                                       sectionNameKeyPath:nil
                                                cacheName:nil];
}

- (void)fetchTweetDataIntoDocument:(UIManagedDocument *)document {
    self.tweets = [[NSArray alloc] init];
    NSString *urlString = nil;
    //if(self.maxId)
    //    urlString = [[NSString alloc] initWithFormat:@"%@?max_id=%@", FETCH_USER_PROFILE_URL, self.maxId];
    //else
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
                        //NSString *Id = [tweetInfo objectForKey:@"id"];
                        //if(self.maxId < Id)
                        //  self.maxId = Id;
                        self.username = [[tweetInfo objectForKey:@"user"] objectForKey:@"screen_name"];
                        self.name = [[tweetInfo objectForKey:@"user"] objectForKey:@"name"];
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
            else {
                NSLog(@"Could not parse your timeline: %@", [jsonError localizedDescription]);
            }
        }
        else {
            NSLog(@"The response received an unexpected status code of %d", urlResponse.statusCode);
        }
    }];
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
    self.spinner = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(160, 240);
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    if (!self.tweetDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                             inDomains:NSUserDomainMask]lastObject];
        url = [url URLByAppendingPathComponent:@"Default Twimini Database"];
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
  
    [[cell textLabel] setNumberOfLines:0];
    [[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
    [[cell textLabel] setFont:[UIFont systemFontOfSize: 16.0]];
    [[cell detailTextLabel] setNumberOfLines:0];
    [[cell detailTextLabel] setLineBreakMode:NSLineBreakByWordWrapping];
    [[cell detailTextLabel] setFont:[UIFont systemFontOfSize: 12.0]];
  
    cell.textLabel.text = tweet.text;
    cell.detailTextLabel.text = tweet.whoWrote.username;
    NSURL *url = [NSURL URLWithString:tweet.imageURL];
    
    dispatch_queue_t imageLoader = dispatch_queue_create("imageLoader", NULL);
    dispatch_async(imageLoader, ^{
      NSData *imageData = [NSData dataWithContentsOfURL:url];
      dispatch_async(dispatch_get_main_queue(), ^{
        cell.imageView.image = [UIImage imageWithData:imageData];
      });
    });
  
    [self.spinner stopAnimating];
    
    return cell;
   /*
  static NSString *CellIdentifier = @"ImageOnRightCell";
  
  UILabel *mainLabel, *secondLabel;
  UIImageView *photo;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 220.0, 15.0)];
    mainLabel.tag = MAINLABEL_TAG;
    mainLabel.numberOfLines = 0;
    mainLabel.lineBreakMode = NSLineBreakByWordWrapping;
    mainLabel.font = [UIFont systemFontOfSize:14.0];
    mainLabel.textAlignment = NSTextAlignmentRight;
    mainLabel.textColor = [UIColor blackColor];
    mainLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:mainLabel];
    
    secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 220.0, 25.0)];
    secondLabel.tag = SECONDLABEL_TAG;
    secondLabel.font = [UIFont systemFontOfSize:12.0];
    secondLabel.textAlignment = NSTextAlignmentRight;
    secondLabel.textColor = [UIColor darkGrayColor];
    secondLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:secondLabel];
    
    photo = [[UIImageView alloc] initWithFrame:CGRectMake(225.0, 0.0, 80.0, 45.0)];
    photo.tag = PHOTO_TAG;
    photo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:photo];
  } else {
    mainLabel = (UILabel *)[cell.contentView viewWithTag:MAINLABEL_TAG];
    secondLabel = (UILabel *)[cell.contentView viewWithTag:SECONDLABEL_TAG];
    photo = (UIImageView *)[cell.contentView viewWithTag:PHOTO_TAG];
  }
  Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  mainLabel.text = tweet.text;
  secondLabel.text = tweet.whoWrote.username;
  NSURL *url = [NSURL URLWithString:tweet.imageURL];
  
  dispatch_queue_t imageLoader = dispatch_queue_create("imageLoader", NULL);
  dispatch_async(imageLoader, ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      NSData *imageData = [NSData dataWithContentsOfURL:url];
      photo.image = [UIImage imageWithData:imageData];
    });
  });
  
  return cell;
   */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *title = tweet.text;
    NSString *subtitle = tweet.whoWrote.name;
    
    CGSize cellBounds = CGSizeMake(tableView.bounds.size.width - 120.0, 1000.0);
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize: 16.0]
                         constrainedToSize:cellBounds
                             lineBreakMode:NSLineBreakByWordWrapping];
    CGSize subtitleSize = [subtitle sizeWithFont:[UIFont systemFontOfSize: 12.0]
                               constrainedToSize:cellBounds
                                   lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height = titleSize.height + subtitleSize.height;

    return height < 44.0 ? 44.0 : height;
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
  NSInteger currentOffset = scroll.contentOffset.y;
  NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
  
  if (maximumOffset - currentOffset <= 5.0) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
      [self fetchTweetDataIntoDocument:self.tweetDatabase];
    });
  }
}

- (void)refresh {
  dispatch_queue_t refreshQueue = dispatch_queue_create("refreshQueue", NULL);
  dispatch_async(refreshQueue,^{
    [self fetchTweetDataIntoDocument:self.tweetDatabase];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing"];
    
    NSDateFormatter *formattedDate = [[NSDateFormatter alloc]init];
    [formattedDate setDateFormat:@"MMM d, h:mm a"];
    NSString *lastupdated = [NSString stringWithFormat:@"Last Updated on %@",
                                                      [formattedDate stringFromDate:[NSDate date]]];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:lastupdated];
    [self.refreshControl endRefreshing];
  });
}

@end
