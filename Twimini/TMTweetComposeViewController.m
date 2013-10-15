#import "TMTweetComposeViewController.h"

@implementation TMTweetComposeViewController

@synthesize account = _account;
@synthesize tweetComposeDelegate = _tweetComposeDelegate;
@synthesize closeButton;
@synthesize sendButton;
@synthesize textView;
@synthesize titleView;

- (void)viewWillAppear:(BOOL)animated {
  self.titleView.title = [NSString stringWithFormat:@"@%@", self.account.username];
  [textView setKeyboardType:UIKeyboardTypeTwitter];
  [textView becomeFirstResponder];
}

- (void)viewDidUnload {
  [self setCloseButton:nil];
  [self setSendButton:nil];
  [self setTextView:nil];
  [self setTitleView:nil];
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (IBAction)sendTweet:(id)sender {
  NSString *status = self.textView.text;
  
  NSURL *url = [NSURL URLWithString:POST_TWEET_URL];
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
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tweetComposeDelegate tweetComposeViewController:self
                                          didFinishWithResult:TweetComposeResultSent];
      });
    }
    else {
      NSLog(@"Problem sending tweet: %@", error);
    }
  }];
}

- (IBAction)cancel:(id)sender {
  [self.tweetComposeDelegate tweetComposeViewController:self
                                    didFinishWithResult:TweetComposeResultCancelled];
}

@end
