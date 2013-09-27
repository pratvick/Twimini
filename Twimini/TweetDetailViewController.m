//
//  TweetDetailViewController.m
//  Twimini
//
//  Created by Prateek Khandelwal on 9/20/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import "TweetDetailViewController.h"

@interface TweetDetailViewController ()

@end

@implementation TweetDetailViewController

@synthesize tweet = _tweet;
@synthesize tweetText = _tweetText;
@synthesize userName = _userName;
@synthesize userImage = _userImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tweetText.lineBreakMode = UILineBreakModeWordWrap;
    self.tweetText.numberOfLines = 0;
    self.tweetText.text = self.tweet.text;
    User *user = self.tweet.whoWrote;
    self.userName.text = user.name;
    NSURL *url = [NSURL URLWithString:self.tweet.imageURL];
    self.userImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setUserImage:nil];
    [self setUserName:nil];
    [self setTweetText:nil];
    [super viewDidUnload];
}
@end
