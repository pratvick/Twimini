#import "User.h"

@interface User (Info)

+ (User *)userWithUsername:(NSString *)username
                      name:(NSString *)name
    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (User *)userWithUsername:(NSString *)username
                      name:(NSString *)name
                followerOf:(User *)user
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
