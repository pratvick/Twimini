#import "User.h"

@interface User (Info)

+ (User *)userWithUsername:(NSString *)username
                      name:(NSString *)name
                  imageURL:(NSString *)imageURL
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
