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

- (void)setUser:(User *)user
{
    _user = user;
    self.profilePictureView.profileID = user.facebookID;
    self.nameLabel.text = user.name;
}

- (void)setProfilePictureView:(FBProfilePictureView *)profilePictureView
{
    _profilePictureView = profilePictureView;
    self.profilePictureView.profileID = self.user.facebookID;
}

- (void)setNameLabel:(UILabel *)nameLabel
{
    _nameLabel = nameLabel;
    self.nameLabel.text = self.user.name;
}


@end
