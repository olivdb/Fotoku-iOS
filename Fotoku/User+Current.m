//
//  User+Current.m
//  Fotoku
//
//  Created by Olivier on 17/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "User+Current.h"
#import "Authentication.h"

@implementation User (Current)


+ (User *)userWithID:(NSNumber *)id
      inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    if (id) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"id = %@", id];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                 inManagedObjectContext:context];
            user.id = id;
        } else {
            user = [matches lastObject];
        }
    }
    
    return user;
}

+ (User *)currentUserInManagedObjectContext:(NSManagedObjectContext *)context
{
    int currentUserID = [[NSUserDefaults standardUserDefaults] integerForKey:USER_ID];
    User *currentUser = [[self class] userWithID:@(currentUserID)
                                   inManagedObjectContext:context];
    currentUser.name = [[NSUserDefaults standardUserDefaults] stringForKey:FACEBOOK_NAME];
    currentUser.facebookID = [[NSUserDefaults standardUserDefaults] stringForKey:FACEBOOK_ID];
    return currentUser;
}


@end
