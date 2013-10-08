#import "Constants.h"

@implementation Constants

NSString *const FETCH_HOME_TIMELINE_URL = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
NSString *const FETCH_USER_PROFILE_URL = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
NSString *const FETCH_FOLLOWERS_URL = @"https://api.twitter.com/1.1/followers/list.json";
NSString *const FETCH_FRIENDS_URL = @"https://api.twitter.com/1.1/friends/list.json";
NSString *const POST_TWEET_URL = @"https://api.twitter.com/1.1/statuses/update.json";

@end
