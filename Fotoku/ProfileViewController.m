//
//  ProfileViewController.m
//  Fotoku
//
//  Created by Olivier on 24/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "ProfileViewController.h"
#import "User+Current.h"

@interface ProfileViewController()
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) User *user;
@end

@implementation ProfileViewController

- (User *)user
{
    if(!_user) {
        _user = [[User class] currentUserInManagedObjectContext:self.managedObjectContext];
    }
    return _user;
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
