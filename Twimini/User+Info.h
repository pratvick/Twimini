#import "User.h"

@interface User (Info)

+ (User *)userWithUsername:(NSString *)username
                      name:(NSString *)name
                  imageURL:(NSString *)imageURL
                followerOf:(User *)followerOfUsername
                  friendOf:(User *)friendOfUsername
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
