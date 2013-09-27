//
//  NewsFeed+Posts.m
//  Twimini
//
//  Created by Prateek Khandelwal on 9/22/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import "NewsFeed+Posts.h"

@implementation NewsFeed (Posts)

+ (NewsFeed *)timelineWithInfo:(NSDictionary *)timelineInfo whoseFeedUsername:(NSString *)username whoseFeedName:(NSString *)name
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    NewsFeed *timeline = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NewsFeed"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [timelineInfo objectForKey:@"id_str"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"text" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Error occurred");
    } else if ([matches count] == 0) {
        timeline = [NSEntityDescription insertNewObjectForEntityForName:@"NewsFeed" inManagedObjectContext:context];
        
        timeline.text = [timelineInfo objectForKey:@"text"];
        timeline.unique = [timelineInfo objectForKey:@"id_str"];
        timeline.newsFeeder = [[timelineInfo objectForKey:@"user"]
                               objectForKey:@"screen_name"];
        timeline.whoseFeed = [User userWithUsername:username name:name inManagedObjectContext:context];
    } else {
        timeline = [matches lastObject];
    }
    
    return timeline;
}

@end
