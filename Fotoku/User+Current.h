//
//  User+Current.h
//  Fotoku
//
//  Created by Olivier on 17/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "User.h"

@interface User (Current)

+ (User *)userWithID:(NSNumber *)id
      inManagedObjectContext:(NSManagedObjectContext *)context;

+ (User *)currentUserInManagedObjectContext:(NSManagedObjectContext *)context;

@end
