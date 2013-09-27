//
//  NewsFeed.h
//  Twimini
//
//  Created by Prateek Khandelwal on 9/24/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface NewsFeed : NSManagedObject

@property (nonatomic, retain) NSString * newsFeeder;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) User *whoseFeed;

@end
