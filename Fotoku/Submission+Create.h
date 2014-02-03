//
//  Submission+Create.h
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 1/02/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "Submission.h"

@interface Submission (Create)
+ (Submission *)submissionForQuest:(Quest *)quest byUser:(User *)user;
@end
