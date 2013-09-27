//
//  User.h
//  Twimini
//
//  Created by Prateek Khandelwal on 9/24/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NewsFeed, Tweet, User;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *newsfeed;
@property (nonatomic, retain) NSSet *tweets;
@property (nonatomic, retain) User *followerOf;
@property (nonatomic, retain) NSSet *followers;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addNewsfeedObject:(NewsFeed *)value;
- (void)removeNewsfeedObject:(NewsFeed *)value;
- (void)addNewsfeed:(NSSet *)values;
- (void)removeNewsfeed:(NSSet *)values;

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

- (void)addFollowersObject:(User *)value;
- (void)removeFollowersObject:(User *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

@end
