//
//  LoginRequest.h
//  Fotoku
//
//  Created by Olivier on 22/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginRequest : NSObject
@property (nonatomic, strong) NSString *fbAccessToken;
@property (nonatomic, copy) NSNumber *fbID;
@property (nonatomic, strong) NSString *fbName;
@end
