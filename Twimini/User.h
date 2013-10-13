//
//  User.h
//  Twimini
//
//  Created by Prateek Khandelwal on 10/12/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet, User;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * noOfFollowers;
@property (nonatomic, retain) NSNumber * noOfTweets;
@property (nonatomic, retain) NSNumber * noOfFriends;
@property (nonatomic, retain) NSSet *followerOf;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *tweets;
@property (nonatomic, retain) NSSet *friendOf;
@property (nonatomic, retain) NSSet *friends;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFollowerOfObject:(User *)value;
- (void)removeFollowerOfObject:(User *)value;
- (void)addFollowerOf:(NSSet *)values;
- (void)removeFollowerOf:(NSSet *)values;

- (void)addFollowersObject:(User *)value;
- (void)removeFollowersObject:(User *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

- (void)addFriendOfObject:(User *)value;
- (void)removeFriendOfObject:(User *)value;
- (void)addFriendOf:(NSSet *)values;
- (void)removeFriendOf:(NSSet *)values;

- (void)addFriendsObject:(User *)value;
- (void)removeFriendsObject:(User *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

@end
