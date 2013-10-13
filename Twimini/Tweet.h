//
//  Tweet.h
//  Twimini
//
//  Created by Prateek Khandelwal on 10/13/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * tweetId;
@property (nonatomic, retain) User *whoWrote;

@end
