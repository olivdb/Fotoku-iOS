//
//  Submission+Create.m
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 1/02/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "Submission+Create.h"
#import "Quest.h"
#import "User.h"

@implementation Submission (Create)
+ (Submission *)submissionForQuest:(Quest *)quest byUser:(User *)user
{
    Submission *submission = nil;
    if (quest.id && user.id) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Submission"];
        request.predicate = [NSPredicate predicateWithFormat:@"(quest.id = %@) AND (user.id = %@) ", quest.id, user.id];
        
        NSError *error;
        NSArray *matches = [quest.managedObjectContext executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            submission = [NSEntityDescription insertNewObjectForEntityForName:@"Submission"
                                                 inManagedObjectContext:quest.managedObjectContext];
            submission.quest = quest;
            submission.questID = quest.id;
            submission.user = user;
            submission.userID = user.id;
        } else {
            submission = [matches lastObject];
        }
    }
    
    return submission;
}

+ (NSArray *) submissionsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Submission"];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    return matches;
}

@end
