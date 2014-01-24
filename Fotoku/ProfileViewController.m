//
//  ProfileViewController.m
//  Fotoku
//
//  Created by Olivier on 24/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController()
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation ProfileViewController

- (void) setFbUser:(id<FBGraphUser>)fbUser
{
    _fbUser = fbUser;
    self.profilePictureView.profileID = fbUser.id;
    self.nameLabel.text = fbUser.name;
}

@end
