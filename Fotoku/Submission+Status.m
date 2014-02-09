//
//  Submission+Status.m
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 9/02/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "Submission+Status.h"

@implementation Submission (Status)

- (NSString *)stringStatus
{
    NSString *result = nil;
    
    switch((SubmissionStatus)self.status.intValue) {
        case STATUS_PENDING_REVIEW:
            result = @"PENDING_REVIEW";
            break;
        case STATUS_REJECTED:
            result = @"REJECTED";
            break;
        case STATUS_ACCEPTED:
            result = @"ACCEPTED";
            break;
        case STATUS_ACCEPTED_WITH_EXTRA_CREDIT:
            result = @"ACCEPTED_WITH_EXTRA_CREDIT";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected Status."];
    }
    
    return result;
}

@end
