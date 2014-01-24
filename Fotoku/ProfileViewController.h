//
//  ProfileViewController.h
//  Fotoku
//
//  Created by Olivier on 24/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileViewController : UIViewController
@property (strong, nonatomic) User *user;
@end
