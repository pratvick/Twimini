//
//  User+Info.h
//  Twimini
//
//  Created by Prateek Khandelwal on 9/17/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import "User.h"

@interface User (Info)

+ (User *)userWithUsername:(NSString *)username name:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;

+ (User *)userWithUsername:(NSString *)username name:(NSString *)name followerOf:(User *)user
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
