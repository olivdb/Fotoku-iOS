//
//  Submission+Status.h
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 9/02/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "Submission.h"

typedef enum { STATUS_PENDING_REVIEW, STATUS_REJECTED, STATUS_ACCEPTED, STATUS_ACCEPTED_WITH_EXTRA_CREDIT } SubmissionStatus;

@interface Submission (SubmissionStatus)

- (NSString *)stringStatus;

@end
