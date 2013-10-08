#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@class TMTweetComposeViewController;

enum TweetComposeResult {
    TweetComposeResultCancelled,
    TweetComposeResultSent,
    TweetComposeResultFailed
};
typedef enum TweetComposeResult TweetComposeResult;

@protocol TMTweetComposeViewControllerDelegate <NSObject>

- (void)tweetComposeViewController:(TMTweetComposeViewController *)controller didFinishWithResult:(TweetComposeResult)result;

@end


@interface TMTweetComposeViewController : UIViewController

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UINavigationItem *titleView;

- (IBAction)sendTweet:(id)sender;
- (IBAction)cancel:(id)sender;

@property (nonatomic, assign) id<TMTweetComposeViewControllerDelegate> tweetComposeDelegate; 

@end
