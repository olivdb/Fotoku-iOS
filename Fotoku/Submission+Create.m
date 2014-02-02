//
//  Submission+Create.m
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 1/02/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "Submission+Create.h"
#import "Quest.h"

@implementation Submission (Create)
+ (Submission *)submissionForQuest:(Quest *)quest
{
    Submission *submission = nil;
    
    if (quest.id) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Submission"];
        request.predicate = [NSPredicate predicateWithFormat:@"quest.id = %@", quest.id];
        
        NSError *error;
        NSArray *matches = [quest.managedObjectContext executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            submission = [NSEntityDescription insertNewObjectForEntityForName:@"Submission"
                                                 inManagedObjectContext:quest.managedObjectContext];
            submission.quest = quest;
        } else {
            submission = [matches lastObject];
        }
    }
    
    return submission;
}
@end
