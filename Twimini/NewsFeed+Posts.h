#import "NewsFeed.h"
#import "User+Info.h"

@interface NewsFeed (Posts)

+ (NewsFeed *)timelineWithInfo:(NSDictionary *)timelineInfo whoseFeedUsername:(NSString *)username whoseFeedName:(NSString *)name
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
