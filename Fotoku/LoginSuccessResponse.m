//
//  LoginSuccessResponse.m
//  Fotoku
//
//  Created by Olivier on 23/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "LoginSuccessResponse.h"

@implementation LoginSuccessResponse

-(NSString *)description
{
    return [NSString stringWithFormat:@"LoginSuccessResponse{authenticationToken=%@, userID=%d}", self.authenticationToken, self.userID.intValue];
}

@end
