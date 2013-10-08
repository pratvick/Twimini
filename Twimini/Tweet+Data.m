#import "Tweet+Data.h"
#import "User.h"
#import "User+Info.h"
#import "TMProfileViewController.h"

@implementation Tweet (Data)

+ (Tweet *)tweetWithInfo:(NSDictionary *)tweetInfo
  inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tweet *tweet = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@",
                         [tweetInfo objectForKey:@"id_str"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"text"
                                                                     ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Error occurred");
    } else if ([matches count] == 0) {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet"
                                              inManagedObjectContext:context];
        
        tweet.text = [tweetInfo objectForKey:@"text"];
        tweet.unique = [tweetInfo objectForKey:@"id_str"];
        tweet.imageURL = [[tweetInfo objectForKey:@"user"] objectForKey:@"profile_image_url"];
        tweet.whoWrote = [User userWithUsername:[[tweetInfo objectForKey:@"user"]
                                                 objectForKey:@"screen_name"]
                                           name:[[tweetInfo objectForKey:@"user"]
                                                 objectForKey:@"name"]
                         inManagedObjectContext:context];
    } else {
        tweet = [matches lastObject];
    }
    
    return tweet;
}

@end
