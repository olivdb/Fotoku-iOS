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


+ (User *)userWithFacebookID:(NSString *)facebookID
      inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    if ([facebookID length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"facebookID = %@", facebookID];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                 inManagedObjectContext:context];
            user.facebookID = facebookID;
        } else {
            user = [matches lastObject];
        }
    }
    
    return user;
}

+ (User *)currentUserInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *currentUserFacebookID = [[NSUserDefaults standardUserDefaults] stringForKey:FACEBOOK_ID];
    User *currentUser = [[self class] userWithFacebookID:currentUserFacebookID
                                   inManagedObjectContext:context];
    currentUser.name = [[NSUserDefaults standardUserDefaults] stringForKey:FACEBOOK_NAME];
    return currentUser;
}


@end
