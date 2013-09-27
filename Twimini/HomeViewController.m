#import "HomeViewController.h"
#import "TweetComposeViewController.h"
#import "FriendsListViewController.h"
#import "FollowersViewController.h"
#import "NewsFeed.h"
#import "NewsFeed+Posts.h"

@interface HomeViewController ()
@end

@implementation HomeViewController

@synthesize account = _account;
@synthesize timeline = _timeline;
@synthesize maxId = _maxId;
@synthesize username = _username;
@synthesize name = _name;

#pragma mark - Compose Tweet
- (void)composeTweet
{
    TweetComposeViewController *tweetComposeViewController = [[TweetComposeViewController alloc] init];
    tweetComposeViewController.account = self.account;
    tweetComposeViewController.tweetComposeDelegate = self;
    [self presentViewController:tweetComposeViewController animated:YES completion:nil];
}

- (void)tweetComposeViewController:(TweetComposeViewController *)controller didFinishWithResult:(TweetComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Get Friends
- (void)getFriends
{
    FriendsListViewController *friendsListViewController = [[FriendsListViewController alloc] init];
    friendsListViewController.account = self.account;
    [self.navigationController pushViewController:friendsListViewController animated:TRUE];
}

-(void)getFollowers
{
    FollowersViewController *followersViewController = [[FollowersViewController alloc] init];
    followersViewController.account = self.account;
    [self.navigationController pushViewController:followersViewController animated:TRUE];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                             target:self
                                                                             action:@selector(composeTweet)];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self
                                                                             action:@selector(fetchData)];
    
    UIImage *image = [UIImage imageNamed:@"friends.png"];
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithImage:image
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(getFriends)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:friends, compose, refresh, nil];
}


- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NewsFeed"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoseFeed.username = %@", self.account.username];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"text" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.newsFeedDatabase.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)fetchTimelineDataIntoDocument:(UIManagedDocument *)document
{
    self.timeline = [[NSArray alloc] init];
    NSString *urlString = nil;
    if(self.maxId)
        urlString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json?max_id=%@", self.maxId];
    else
        urlString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    NSURL *url = [NSURL URLWithString:urlString];
    TWRequest *request = [[TWRequest alloc] initWithURL:url
                                             parameters:nil
                                          requestMethod:TWRequestMethodGET];
    [request setAccount:self.account];
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) {
        if ([urlResponse statusCode] == 200)
        {
            NSError *jsonError = nil;
            NSArray *jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (jsonResult != nil)
            {
                self.timeline = jsonResult;
                [document.managedObjectContext performBlock:^{
                    for (NSDictionary *timelineInfo in self.timeline) {
                        NSString *Id = [timelineInfo objectForKey:@"id"];
                        if(self.maxId < Id)
                            self.maxId = Id;
                        [NewsFeed timelineWithInfo:timelineInfo whoseFeedUsername:self.username whoseFeedName:self.name inManagedObjectContext:document.managedObjectContext];
                    }
                    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
                        if(success)
                            NSLog(@"Document saved successfully");
                    }];
                }];
            }
            else
            {
                NSLog(@"Could not parse your timeline: %@", [jsonError localizedDescription]);
            }
        }
        else
        {
            NSLog(@"The response received an unexpected status code of %d", urlResponse.statusCode);
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
    [self fetchTimelineDataIntoDocument:self.newsFeedDatabase];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll
{
    NSInteger currentOffset = scroll.contentOffset.y;
    NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    
    if (maximumOffset - currentOffset <= 5.0)
        [self fetchTimelineDataIntoDocument:self.newsFeedDatabase];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"News Feed";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NewsFeed *timeline = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = timeline.text;
    cell.detailTextLabel.text = timeline.newsFeeder;
    
    return cell;
}

@end
