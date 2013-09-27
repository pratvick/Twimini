//
//  Tweet+Data.h
//  Twimini
//
//  Created by Prateek Khandelwal on 9/17/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (Data)

+ (Tweet *)tweetWithInfo:(NSDictionary *)tweetInfo
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
