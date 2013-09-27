//
//  TweetDetailViewController.h
//  Twimini
//
//  Created by Prateek Khandelwal on 9/20/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TweetsListViewController.h"
#import "User.h"

@interface TweetDetailViewController : UIViewController

@property (strong, nonatomic) Tweet *tweet;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;

@end
