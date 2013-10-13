//
//  User.h
//  Twimini
//
//  Created by Prateek Khandelwal on 10/13/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet, User;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * noOfFollowers;
@property (nonatomic, retain) NSNumber * noOfFriends;
@property (nonatomic, retain) NSNumber * noOfTweets;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) User *followerOf;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) User *friendOf;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFollowersObject:(User *)value;
- (void)removeFollowersObject:(User *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addFriendsObject:(User *)value;
- (void)removeFriendsObject:(User *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
