//
//  ProfileViewController.h
//  Fotoku
//
//  Created by Olivier on 24/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property (strong, nonatomic) id<FBGraphUser> fbUser;//TODO: instead, just provide a user managedObject with the current user
@end
