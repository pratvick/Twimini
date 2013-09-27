//
//  NewsFeed+Posts.h
//  Twimini
//
//  Created by Prateek Khandelwal on 9/22/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import "NewsFeed.h"
#import "User+Info.h"

@interface NewsFeed (Posts)

+ (NewsFeed *)timelineWithInfo:(NSDictionary *)timelineInfo whoseFeedUsername:(NSString *)username whoseFeedName:(NSString *)name
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
