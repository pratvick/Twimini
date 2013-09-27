#import "TweetsListViewController.h"
#import "TweetComposeViewController.h"
#import "FriendsListViewController.h"
#import "FollowersViewController.h"
#import "HomeViewController.h"
#import "TweetDetailViewController.h"
#import "Tweet.h"
#import "User.h"
#import "Tweet+Data.h"
#import "User+Info.h"

@interface TweetsListViewController()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation TweetsListViewController

@synthesize account = _account;
@synthesize tweets = _tweets;
@synthesize tweetDatabase = _tweetDatabase;
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
    [self fetchTweetDataIntoDocument:self.tweetDatabase];
}

#pragma mark - Get Friends
- (void)getFriends
{
    FriendsListViewController *friendsListViewController = [[FriendsListViewController alloc] init];
    friendsListViewController.account = self.account;
    [self.navigationController pushViewController:friendsListViewController animated:TRUE];
}

- (void)getHome
{
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    homeViewController.account = self.account;
    homeViewController.name = self.name;
    homeViewController.username = self.username;
    homeViewController.newsFeedDatabase = self.tweetDatabase;
    [self.navigationController pushViewController:homeViewController animated:TRUE];
}

-(void)getFollowers
{
    FollowersViewController *followersViewController = [[FollowersViewController alloc] init];
    followersViewController.account = self.account;
    followersViewController.username = self.username;
    followersViewController.name = self.name;
    followersViewController.followersDatabase = self.tweetDatabase;
    [self.navigationController pushViewController:followersViewController animated:TRUE];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:friends, compose, followers, home, nil];
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoWrote.username = %@", self.account.username];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"text" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.tweetDatabase.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)fetchTweetDataIntoDocument:(UIManagedDocument *)document
{
    self.tweets = [[NSArray alloc] init];
    NSString *urlString = nil;
    if(self.maxId)
        urlString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?max_id=%@", self.maxId];
    else
        urlString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
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
                self.tweets = jsonResult;
                [document.managedObjectContext performBlock:^{
                    for (NSDictionary *tweetInfo in self.tweets) {
                        self.username = [[tweetInfo objectForKey:@"user"] objectForKey:@"screen_name"];
                        self.name = [[tweetInfo objectForKey:@"user"] objectForKey:@"name"];;
                        [Tweet tweetWithInfo:tweetInfo inManagedObjectContext:document.managedObjectContext];
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

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.tweetDatabase.fileURL path]]) {
        [self.tweetDatabase saveToURL:self.tweetDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            [self fetchTweetDataIntoDocument:self.tweetDatabase];
        }];
    } else if (self.tweetDatabase.documentState == UIDocumentStateClosed) {
        [self.tweetDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            [self fetchTweetDataIntoDocument:self.tweetDatabase];
        }];
    } else if (self.tweetDatabase.documentState == UIDocumentStateNormal) {
        [self setupFetchedResultsController];
    }
}

- (void)setTweetDatabase:(UIManagedDocument *)tweetDatabase
{
    if (_tweetDatabase != tweetDatabase) {
        _tweetDatabase = tweetDatabase;
        [self useDocument];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(160, 240);
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    if (!self.tweetDatabase)
    {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Tweet Database"];
        self.tweetDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.spinner stopAnimating];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"News Feed";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [[cell textLabel] setNumberOfLines:0];
    [[cell textLabel] setLineBreakMode:UILineBreakModeWordWrap];
    [[cell textLabel] setFont:[UIFont systemFontOfSize: 14.0]];
    [[cell detailTextLabel] setNumberOfLines:0];
    [[cell detailTextLabel] setLineBreakMode:UILineBreakModeWordWrap];
    [[cell detailTextLabel] setFont:[UIFont systemFontOfSize: 14.0]];
    cell.textLabel.text = tweet.text;
    cell.detailTextLabel.text = tweet.whoWrote.username;
    NSURL *url = [NSURL URLWithString:tweet.imageURL];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        __block NSData *imageData;
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{                                         imageData = [NSData dataWithContentsOfURL:url];
            dispatch_sync(dispatch_get_main_queue(), ^{
                cell.imageView.image = [UIImage imageWithData:imageData];
            });
        });
    });
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *title = tweet.text;
    NSString *subtitle = tweet.whoWrote.name;
    
    CGSize cellBounds = CGSizeMake(tableView.bounds.size.width - 100.0, 1000.0);
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize: 14.0] constrainedToSize:cellBounds lineBreakMode:UILineBreakModeWordWrap];
    CGSize subtitleSize = [subtitle sizeWithFont:[UIFont systemFontOfSize: 14.0] constrainedToSize:cellBounds lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = titleSize.height + subtitleSize.height;
    
    return height < 44.0 ? 44.0 : height;
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll
{
    NSInteger currentOffset = scroll.contentOffset.y;
    NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    
    if (maximumOffset - currentOffset <= 5.0)
        [self fetchTweetDataIntoDocument:self.tweetDatabase];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"tweet detail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
        TweetDetailViewController *tweetDetailViewController = segue.destinationViewController;
        tweetDetailViewController.tweet = tweet;
    }
}
/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row%2 == 0) {
        UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.1];
        cell.backgroundColor = altCellColor;
    }
}
*/
@end
