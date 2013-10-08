#import "TMHomeViewController.h"

@interface TMHomeViewController ()

@end

@implementation TMHomeViewController

@synthesize newsFeedDatabase = _newsFeedDatabase;

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NewsFeed"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoseFeed.username = %@",
                                                                            self.account.username];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"text"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:self.newsFeedDatabase.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
}

- (void)fetchTimelineDataIntoDocument:(UIManagedDocument *)document {
    self.timeline = [[NSArray alloc] init];
    NSString *urlString = nil;
    
    if(self.maxId)
        urlString = [[NSString alloc] initWithFormat:@"%@?max_id=%@", FETCH_HOME_TIMELINE_URL, self.maxId];
    else
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
                        NSLog(@"%@", Id);
                        if(self.maxId < Id){
                            self.maxId = Id;
                        }
                        [NewsFeed timelineWithInfo:timelineInfo
                                 whoseFeedUsername:self.username
                                     whoseFeedName:self.name
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
    [self fetchTimelineDataIntoDocument:self.newsFeedDatabase];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    NSInteger currentOffset = scroll.contentOffset.y;
    NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    
    if (maximumOffset - currentOffset <= 5.0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self fetchTimelineDataIntoDocument:self.newsFeedDatabase];
        });
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"News Feed";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    NewsFeed *timeline = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = timeline.text;
    cell.detailTextLabel.text = timeline.newsFeeder;
    
    return cell;
}

@end
