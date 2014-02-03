//
//  LoginViewController.m
//  Fotoku
//
//  Created by Olivier on 21/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginRequest.h"
#import "LoginSuccessResponse.h"
#import "UICKeyChainStore.h"

@interface LoginViewController () <FBLoginViewDelegate>
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (strong, nonatomic) RKRequestDescriptor *loginRequestDescriptor;
@property (strong, nonatomic) RKResponseDescriptor *successfulLoginResponseDescriptor;
@end

@implementation LoginViewController

#pragma mark - RestKit for Login

- (RKRequestDescriptor *) loginRequestDescriptor
{
    if(!_loginRequestDescriptor) {
        RKObjectMapping *loginRequestMapping = [RKObjectMapping requestMapping];
        [loginRequestMapping addAttributeMappingsFromDictionary:@{@"fbAccessToken": @"fb_access_token",
                                                                  @"fbID" :         @"fb_id",
                                                                  @"fbName" :       @"fb_name"}];
        _loginRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:loginRequestMapping
                                                                        objectClass:[LoginRequest class]
                                                                        rootKeyPath:nil
                                                                             method:RKRequestMethodAny];
    }
    return _loginRequestDescriptor;
}

- (RKResponseDescriptor *) successfulLoginResponseDescriptor
{
    if(!_successfulLoginResponseDescriptor) {
        // a successful login response looks like { "authentication_token": "XXXXX" }
        RKObjectMapping *loginSuccessResponseMapping = [RKObjectMapping mappingForClass:[LoginSuccessResponse class]];
        [loginSuccessResponseMapping addAttributeMappingsFromDictionary:@{@"authentication_token": @"authenticationToken",
                                                                          @"user_id":              @"userID"}];
        _successfulLoginResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:loginSuccessResponseMapping
                                                                                          method:RKRequestMethodAny
                                                                                     pathPattern:nil
                                                                                         keyPath:nil
                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    }
    return _successfulLoginResponseDescriptor;
}

- (void)addLoginDescriptors
{
    // add login request descriptor
    [[RKObjectManager sharedManager] addRequestDescriptor:self.loginRequestDescriptor];
    // add successful response descriptor
    [[RKObjectManager sharedManager] addResponseDescriptor:self.successfulLoginResponseDescriptor];
}

- (void)removeLoginDescriptors
{
    // remove login request descriptor
    [[RKObjectManager sharedManager] removeRequestDescriptor:self.loginRequestDescriptor];
    // remove successful response descriptor
    [[RKObjectManager sharedManager] removeResponseDescriptor:self.successfulLoginResponseDescriptor];
}

- (void)sendAccessTokenToServer
{
    NSString *accessToken = FBSession.activeSession.accessTokenData.accessToken;
    LoginRequest * loginRequest = [[LoginRequest alloc] init];
    loginRequest.fbAccessToken = accessToken;
    loginRequest.fbID = @(self.fbUser.id.intValue);
    loginRequest.fbName = self.fbUser.name;
    [[RKObjectManager sharedManager] postObject:loginRequest
                                           path:@"sessions"
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            LoginSuccessResponse *response = (LoginSuccessResponse *) [mappingResult firstObject];
                                            NSLog(@"Facebook login succeeded: auth_token=%@ user_id=%d", response.authenticationToken, response.userID.intValue);
                                            self.authenticationToken = response.authenticationToken;
                                            [self performSegueWithIdentifier:@"UnwindFromLogin" sender:self];
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred"
                                                                                                message:[error localizedDescription]
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:@"OK"
                                                                                      otherButtonTitles:nil];
                                            [alertView show];
                                        }];
}

#pragma mark - FB API delegates

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.fbUser = user;
    [self sendAccessTokenToServer];
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - VC lifecycle

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addLoginDescriptors];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeLoginDescriptors];
}

@end
