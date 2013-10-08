#import "Tweet.h"

@interface Tweet (Data)

+ (Tweet *)tweetWithInfo:(NSDictionary *)tweetInfo
  inManagedObjectContext:(NSManagedObjectContext *)context;

@end
