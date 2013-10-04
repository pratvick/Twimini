#import "TMTweetDetailViewController.h"

@interface TMTweetDetailViewController ()

@end

@implementation TMTweetDetailViewController

@synthesize tweet = _tweet;
@synthesize tweetText = _tweetText;
@synthesize userName = _userName;
@synthesize userImage = _userImage;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tweetText.numberOfLines = 0;
    self.tweetText.lineBreakMode = UILineBreakModeWordWrap;
    self.tweetText.font = [UIFont systemFontOfSize:14.0];
    self.tweetText.text = self.tweet.text;
    User *user = self.tweet.whoWrote;
    self.userName.text = user.name;
    NSURL *url = [NSURL URLWithString:self.tweet.imageURL];
    self.userImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

- (void)viewDidUnload {
    [self setUserImage:nil];
    [self setUserName:nil];
    [self setTweetText:nil];
    [super viewDidUnload];
}
@end
