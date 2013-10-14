#import "TMHomeViewController.h"

@interface TMHomeViewController ()

@end

@implementation TMHomeViewController

@synthesize newsFeedDatabase = _newsFeedDatabase;

- (void)setupFetchedResultsController {
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
  request.predicate = [NSPredicate predicateWithFormat:@"whoWrote.username != %@", self.account.username];
  request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp"
                                                                                   ascending:NO
                                                                                    selector:nil]];

  self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                   initWithFetchRequest:request
                                   managedObjectContext:self.newsFeedDatabase.managedObjectContext
                                   sectionNameKeyPath:nil
                                   cacheName:nil];
}

- (void)fetchTimelineDataIntoDocument:(UIManagedDocument *)document {
  self.timeline = [[NSArray alloc] init];
  NSString *urlString = nil;
  
  urlString = [[NSString alloc] initWithFormat:@"%@", FETCH_HOME_TIMELINE_URL];
  
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
        self.timeline = jsonResult;
        [document.managedObjectContext performBlock:^{
          for (NSDictionary *timelineInfo in self.timeline) {
            NSString *Id = [timelineInfo objectForKey:@"id"];
            if(self.maxId < Id)
              self.maxId = Id;
            [Tweet tweetWithInfo:timelineInfo
                inManagedObjectContext:document.managedObjectContext];
            self.previousRequestDone = @"DONE";
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
      else
        NSLog(@"Could not parse your timeline: %@", [jsonError localizedDescription]);
    }
    else
      NSLog(@"The response received an unexpected status code of %d", urlResponse.statusCode);
  }];
}

- (void)fetchPreviousTimelineDataIntoDocument:(UIManagedDocument *)document {
  self.timeline = [[NSArray alloc] init];
  NSString *urlString = nil;
  NSString *done = @"DONE";
  
  if([self.previousRequestDone isEqualToString:done]) {
    self.previousRequestDone = @"NOT DONE";
    urlString = [[NSString alloc] initWithFormat:@"%@?max_id=%@", FETCH_HOME_TIMELINE_URL, self.maxId];
  
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
          self.timeline = jsonResult;
          [document.managedObjectContext performBlock:^{
            for (NSDictionary *timelineInfo in self.timeline) {
              NSString *Id = [timelineInfo objectForKey:@"id"];
              if(self.maxId < Id)
                self.maxId = Id;
              [Tweet tweetWithInfo:timelineInfo
            inManagedObjectContext:document.managedObjectContext];
              self.previousRequestDone = @"DONE";
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
        else
          NSLog(@"Could not parse your timeline: %@", [jsonError localizedDescription]);
      }
      else
        NSLog(@"The response received an unexpected status code of %d", urlResponse.statusCode);
    }];
  }
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull to Refresh"];
  [refreshControl addTarget:self action:@selector(refresh)
           forControlEvents:UIControlEventValueChanged];
  
  self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self setupFetchedResultsController];
  [self fetchTimelineDataIntoDocument:self.newsFeedDatabase];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
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
  UIImage *image = [self.imageCache objectForKey:url];
  
  if(image) {
    cell.imageView.image = image;
    NSLog(@"image from cache");
  }
  else {
    NSLog(@"image from network");
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
  
  float reload_distance = 3.0;
  
  if(y > h + reload_distance) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
      [self fetchPreviousTimelineDataIntoDocument:self.newsFeedDatabase];
    });
  }
}

- (void)refresh {
  [self.refreshControl beginRefreshing];
  dispatch_queue_t refreshQueue = dispatch_queue_create("refreshQueue", NULL);
  dispatch_async(refreshQueue,^{
    [self fetchTimelineDataIntoDocument:self.newsFeedDatabase];
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
