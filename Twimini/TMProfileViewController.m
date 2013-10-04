#import "TMProfileViewController.h"
#import "TMTweetComposeViewController.h"
#import "TMFriendsListViewController.h"
#import "TMFollowersViewController.h"
#import "TMHomeViewController.h"
#import "Tweet.h"
#import "User.h"
#import "Tweet+Data.h"
#import "User+Info.h"

@interface TMProfileViewController()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation TMProfileViewController

@synthesize tweetDatabase = _tweetDatabase;

- (void)composeTweet
{
    TMTweetComposeViewController *tweetComposeViewController = [[TMTweetComposeViewController alloc] init];
    tweetComposeViewController.account = self.account;
    tweetComposeViewController.tweetComposeDelegate = self;
    [self presentViewController:tweetComposeViewController animated:YES completion:nil];
}

- (void)tweetComposeViewController:(TMTweetComposeViewController *)controller didFinishWithResult:(TweetComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self fetchTweetDataIntoDocument:self.tweetDatabase];
}

- (void)getFriends
{
    TMFriendsListViewController *friendsListViewController = [[TMFriendsListViewController alloc] init];
    friendsListViewController.account = self.account;
    [self.navigationController pushViewController:friendsListViewController animated:TRUE];
}

- (void)getHome
{
    TMHomeViewController *homeViewController = [[TMHomeViewController alloc] init];
    homeViewController.account = self.account;
    homeViewController.name = self.name;
    homeViewController.username = self.username;
    homeViewController.newsFeedDatabase = self.tweetDatabase;
    [self.navigationController pushViewController:homeViewController animated:TRUE];
}

-(void)getFollowers
{
    TMFollowersViewController *followersViewController = [[TMFollowersViewController alloc] init];
    followersViewController.account = self.account;
    followersViewController.username = self.username;
    followersViewController.name = self.name;
    followersViewController.followersDatabase = self.tweetDatabase;
    [self.navigationController pushViewController:followersViewController animated:TRUE];
}

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
                        else
                            NSLog(@"Document is not saved");
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
    }else{
        [self setupFetchedResultsController];
        [self fetchTweetDataIntoDocument:self.tweetDatabase];
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
        url = [url URLByAppendingPathComponent:@"Default Twitter Database"];
        self.tweetDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
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
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            imageData = [NSData dataWithContentsOfURL:url];
            dispatch_sync(dispatch_get_main_queue(), ^{
                cell.imageView.image = [UIImage imageWithData:imageData];
                [self.tableView reloadData];
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
    
    CGSize cellBounds = CGSizeMake(tableView.bounds.size.width - 120.0, 1000.0);
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize: 14.0] constrainedToSize:cellBounds lineBreakMode:UILineBreakModeWordWrap];
    CGSize subtitleSize = [subtitle sizeWithFont:[UIFont systemFontOfSize: 14.0] constrainedToSize:cellBounds lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = titleSize.height + subtitleSize.height;

    [self.spinner stopAnimating];
    return height < 44.0 ? 44.0 : height;
}

@end
