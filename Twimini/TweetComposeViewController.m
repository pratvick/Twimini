#import "TweetComposeViewController.h"
#import <Twitter/Twitter.h>

@implementation TweetComposeViewController

@synthesize account = _account;
@synthesize tweetComposeDelegate = _tweetComposeDelegate;

@synthesize closeButton;
@synthesize sendButton;
@synthesize textView;
@synthesize titleView;

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    self.titleView.title = [NSString stringWithFormat:@"@%@", self.account.username];
    [textView setKeyboardType:UIKeyboardTypeTwitter];
    [textView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setCloseButton:nil];
    [self setSendButton:nil];
    [self setTextView:nil];
    [self setTitleView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (IBAction)sendTweet:(id)sender
{
    NSString *status = self.textView.text;
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:status, @"status", nil];
    
    TWRequest *sendTweet = [[TWRequest alloc]
                            initWithURL:url
                            parameters:params
                            requestMethod:TWRequestMethodPOST];
    
    sendTweet.account = self.account;
    
    [sendTweet performRequestWithHandler:^(NSData *responseData,
                                           NSHTTPURLResponse *urlResponse,
                                           NSError *error) {
        if ([urlResponse statusCode] == 200) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tweetComposeDelegate tweetComposeViewController:self didFinishWithResult:TweetComposeResultSent];
            });
        }
        else {
            NSLog(@"Problem sending tweet: %@", error);
        }
    }];
}

- (IBAction)cancel:(id)sender
{
    [self.tweetComposeDelegate tweetComposeViewController:self didFinishWithResult:TweetComposeResultCancelled];
}

@end
