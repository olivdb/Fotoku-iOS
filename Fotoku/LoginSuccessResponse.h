//
//  LoginSuccessResponse.h
//  Fotoku
//
//  Created by Olivier on 23/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginSuccessResponse : NSObject
@property (nonatomic, strong) NSString *authenticationToken;
@property (nonatomic, strong) NSNumber *userID;
@end
