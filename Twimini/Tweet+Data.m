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
  request.predicate = [NSPredicate predicateWithFormat:@"tweetId = %@",
                       [tweetInfo objectForKey:@"id_str"]];
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp"
                                                                   ascending:NO];
  request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  
  NSError *error = nil;
  NSArray *matches = [context executeFetchRequest:request error:&error];
  
  if (!matches || ([matches count] > 1)) {
    NSLog(@"Error occurred");
  } else if ([matches count] == 0) {
    tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet"
                                          inManagedObjectContext:context];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    
    [dateFormatter setDateFormat: @"EEE MMM dd HH:mm:ss Z yyyy"];
    
    NSDate *date = [dateFormatter dateFromString:[tweetInfo objectForKey:@"created_at"]];    
    NSTimeInterval tweetTime = [date timeIntervalSince1970];
    NSNumber *time = [NSNumber numberWithDouble:tweetTime];
    
    tweet.text = [tweetInfo objectForKey:@"text"];
    tweet.tweetId = [tweetInfo objectForKey:@"id_str"];
    tweet.timestamp = time;
    tweet.whoWrote = [User userWithUsername:[[tweetInfo objectForKey:@"user"]
                                             objectForKey:@"screen_name"]
                                       name:[[tweetInfo objectForKey:@"user"]
                                             objectForKey:@"name"]
                                   imageURL:[[tweetInfo objectForKey:@"user"]
                                             objectForKey:@"profile_image_url"]
                                 followerOf:Nil
                                   friendOf:Nil
                     inManagedObjectContext:context];
  } else {
    tweet = [matches lastObject];
  }
  
  return tweet;
}

@end
