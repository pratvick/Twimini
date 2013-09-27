#import "TweetDetailViewController.h"

@interface TweetDetailViewController ()

@end

@implementation TweetDetailViewController
@synthesize detailItem = _detailItem;
@synthesize nameLabel = _nameLabel;
@synthesize tweetLabel = _tweetLabel;
@synthesize profileImage = _profileImage;

- (void)viewDidUnload {
    [self setProfileImage:nil];
    [self setNameLabel:nil];
    [self setTweetLabel:nil];
    [super viewDidUnload];
}

-(void)configure
{
    if (self.detailItem) {
        NSLog(@"here comes");
        NSDictionary *tweet = self.detailItem;
        
        NSString *text = [[tweet objectForKey:@"user"] objectForKey:@"name"];
        NSString *name = [tweet objectForKey:@"text"];
        
        self.tweetLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.tweetLabel.numberOfLines = 0;
        
        self.nameLabel.text = text;
        self.tweetLabel.text = name;
        
        NSLog(@"%@", name);
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImage.image = [UIImage imageWithData:data];
            });
        });
         */
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configure];
}
@end
