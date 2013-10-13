#import "User+Info.h"

@implementation User (Info)

+ (User *)userWithUsername:(NSString *)username
                      name:(NSString *)name
                  imageURL:(NSString *)imageURL
                followerOf:(User *)followerOfUser
                  friendOf:(User *)friendOfUser
    inManagedObjectContext:(NSManagedObjectContext *)context
{
  User *user = nil;
  
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
  request.predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"username"
                                                                   ascending:YES];
  request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  
  NSError *error = nil;
  NSArray *users = [context executeFetchRequest:request error:&error];
  
  if (!users || ([users count] > 1)) {
    NSLog(@"Error occurred");
  } else if (![users count]) {
    user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                         inManagedObjectContext:context];
    user.name = name;
    user.username = username;
    user.followerOf = followerOfUser;
    user.friendOf = friendOfUser;
    user.imageURL = imageURL;
  } else {
    user = [users lastObject];
  }
  
  return user;
}

@end