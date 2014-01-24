//
//  User+Current.m
//  Fotoku
//
//  Created by Olivier on 17/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "User+Current.h"

@implementation User (Current)

+ (User *)userWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                         inManagedObjectContext:context];
            user.name = name;
        } else {
            user = [matches lastObject];
        }
    }
    
    return user;
}

+ (User *)currentUserInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [[self class] userWithName:@"Oli" inManagedObjectContext:context];
    //TODO: find fb id from NSUserDefaults, if there is no user in the db with this fb id, create one alone with the name found in NSUserDefaults, then return it
}


@end
