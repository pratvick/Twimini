//
//  User+Info.m
//  Twimini
//
//  Created by Prateek Khandelwal on 9/17/13.
//  Copyright (c) 2013 Directi. All rights reserved.
//

#import "User+Info.h"

@implementation User (Info)

+ (User *)userWithUsername:(NSString *)username name:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users || ([users count] > 1)) {
        NSLog(@"Error occurred");
    } else if (![users count]) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                     inManagedObjectContext:context];
        user.username = username;
        user.name = name;
    } else {
        user = [users lastObject];
    }
    
    return user;
}


+ (User *)userWithUsername:(NSString *)username name:(NSString *)name followerOf:(User *)user
    inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *person = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@ AND followerOf.username = %@", username, user.username];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *persons = [context executeFetchRequest:request error:&error];
    
    if (!persons || ([persons count] > 1)) {
        NSLog(@"Error occurred");
    } else if (![persons count]) {
        person = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                             inManagedObjectContext:context];
        person.username = username;
        person.followerOf = user;
        person.name = name;
    } else {
        person = [persons lastObject];
    }
    
    return person;
}

@end