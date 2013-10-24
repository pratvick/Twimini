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

- (IBAction)sendTweet:(id)sender {
  NSString *status = self.textView.text;
  
  NSURL *url = [NSURL URLWithString:POST_TWEET_URL];
  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:status, @"status", nil];
  
  TWRequest *sendTweet = [[TWRequest alloc] initWithURL:url
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
      [self.tweetComposeDelegate tweetComposeViewController:self
                                        didFinishWithResult:TweetComposeResultFailed];
      NSLog(@"Problem sending tweet: %@", error);
    }
  }];
  
  CGAffineTransform transform = self.view.transform;
  [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
    self.view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.7, 0.7), 2*M_PI/3);
  } completion:^(BOOL finished){
    if(finished)
      [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.4, 0.4), -2*M_PI/3);
      } completion:^(BOOL finished){
        if(finished)
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
          self.view.transform = CGAffineTransformScale(transform, 0.1, 0.1);
        } completion:^(BOOL finished){
          if(finished) 
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
      }];
  }];
}

- (IBAction)cancel:(id)sender {
  [self.tweetComposeDelegate tweetComposeViewController:self
                                    didFinishWithResult:TweetComposeResultCancelled];

  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
  [self setCloseButton:nil];
  [self setSendButton:nil];
  [self setTextView:nil];
  [self setTitleView:nil];
  [super viewDidUnload];
}

@end
