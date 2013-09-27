//
//  Tweet.h
//  Twimini
//
//  Created by Prateek Khandelwal on 9/24/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) User *whoWrote;

@end
