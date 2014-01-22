//
//  LoginRequest.m
//  Fotoku
//
//  Created by Olivier on 22/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "LoginRequest.h"

@implementation LoginRequest

-(NSString *)description
{
    return [NSString stringWithFormat:@"LoginRequest{fbAccessToken=%@}", self.fbAccessToken];
}

@end
