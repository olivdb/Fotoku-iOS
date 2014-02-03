//
//  SubmitSolutionViewController.m
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 1/02/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "SubmitSolutionViewController.h"
#import "Submission.h"
#import "UIImage+Helper.h"
#import "User+Current.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Quest.h"

@interface SubmitSolutionViewController () <UIAlertViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) RKRequestDescriptor *postSubmissionRequestDescriptor;
@property (strong, nonatomic) RKResponseDescriptor *postSubmissionResponseDescriptor;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger locationErrorCode;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) BOOL hasExtraCredit;
@property (weak, nonatomic) IBOutlet UISwitch *hasExtraCreditSwitch;
@end

@implementation SubmitSolutionViewController

- (RKRequestDescriptor *)postSubmissionRequestDescriptor
{
    if(!_postSubmissionRequestDescriptor) {
        // submission mapping
        RKEntityMapping *submissionMapping = [RKEntityMapping mappingForEntityForName:@"Submission"
                                                            inManagedObjectStore:[RKManagedObjectStore defaultStore]];
        [submissionMapping addAttributeMappingsFromDictionary:@{@"quest_id":                 @"questID",
                                                                @"latitude":                 @"latitude",
                                                                @"longitude":                @"longitude",
                                                                @"has_extra_credit":         @"hasExtraCredit"}];
        // quest sub-mapping
        //RKEntityMapping *questMapping = [RKEntityMapping mappingForEntityForName:@"Quest"
        //                                                    inManagedObjectStore:[RKManagedObjectStore defaultStore]];
        //[questMapping addAttributeMappingsFromDictionary:@{@"id":             @"id"}];
        //questMapping.identificationAttributes = @[ @"id" ];
        //[submissionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"quest"
        //                                                                                  toKeyPath:@"quest"
        //                                                                                withMapping:questMapping]];

        
        _postSubmissionRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:submissionMapping.inverseMapping
                                                                            objectClass:[Submission class]
                                                                            rootKeyPath:@"submission"
                                                                                 method:RKRequestMethodAny];
    }
    return _postSubmissionRequestDescriptor;
}

- (RKResponseDescriptor *)postSubmissionResponseDescriptor
{
    if(!_postSubmissionResponseDescriptor) {
        // submission mapping
       
        
         RKEntityMapping *submissionMapping = [RKEntityMapping mappingForEntityForName:@"Submission"
                                                                     inManagedObjectStore:[RKManagedObjectStore defaultStore]];
        [submissionMapping addAttributeMappingsFromDictionary:@{@"quest_id":                    @"questID",
                                                                @"user_id":                     @"userID",
                                                                @"id":                          @"id",
                                                                @"photo_url":                   @"photoURL",
                                                                @"status":                      @"status",
                                                                @"user_id":                     @"userID",
                                                                @"coins_earned":                @"coinsEarned",
                                                                @"extra_credit_coins_earned":   @"extraCreditCoinsEarned",
                                                                @"xp":                          @"xp",
                                                                @"submitted_at":                @"submittedAt"}];
        /*
         // user sub-mapping
         RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User"
                                                           inManagedObjectStore:[RKManagedObjectStore defaultStore]];
        [userMapping addAttributeMappingsFromDictionary:@{@"id":             @"id"}];
        userMapping.identificationAttributes = @[ @"id" ];
        [submissionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
                                                                                     toKeyPath:@"user"
                                                                                   withMapping:userMapping]];
        // quest sub-mapping
        RKEntityMapping *questMapping = [RKEntityMapping mappingForEntityForName:@"Quest"
                                                           inManagedObjectStore:[RKManagedObjectStore defaultStore]];
        [questMapping addAttributeMappingsFromDictionary:@{@"id":             @"id"}];
        questMapping.identificationAttributes = @[ @"id" ];
        [submissionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"quest"
                                                                                          toKeyPath:@"quest"
                                                                                        withMapping:questMapping]];
         */
        
        //submissionMapping.identificationAttributes = @[ @"@parent.quest.id", @"@parent.user.id" ];
        submissionMapping.identificationAttributes = @[ @"questID", @"userID" ];
        //submissionMapping.identificationPredicate = [NSPredicate predicateWithFormat:@"(user.id = %d) AND (quest.id = %d)", self.submission.user.id.intValue, self.submission.quest.id.intValue];
        
        NSIndexSet *successStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
        _postSubmissionResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:submissionMapping
                                                                                               method:RKRequestMethodAny
                                                                                          pathPattern:@"/submissions"
                                                                                              keyPath:@"submission"
                                                                                          statusCodes:successStatusCodes];
    }
    return _postSubmissionResponseDescriptor;
}

+ (BOOL)canSubmitPhoto
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if([availableMediaTypes containsObject:(NSString*)kUTTypeImage]) {
            if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![[self class] canSubmitPhoto])
    {
        [self fatalAlert:@"Sorry, this device cannot submit a photo."];
    } else {
        [self.locationManager startUpdatingLocation];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}


- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Submit Photo"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Submit Photo"
                                message:msg
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancel];
}

- (IBAction)cancel
{
    self.image = nil; // this will clean up the image url (i.e. remove the files from disk; see setImage:)
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    // when image is changed, we must delete file we've created for previous image (if any)
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    self.imageURL = nil;

}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImageView:(UIImageView *)imageView
{
    _imageView = imageView;
    
    if(self.submission.photoURL) {
        [self.imageView setImageWithURL:[NSURL URLWithString:self.submission.photoURL]];
    }
}

- (void)setHasExtraCreditSwitch:(UISwitch *)hasExtraCreditSwitch
{
    _hasExtraCreditSwitch = hasExtraCreditSwitch;
    if(self.submission) {
        [self.hasExtraCreditSwitch setOn:self.submission.hasExtraCredit.boolValue];
    }
}

- (CLLocationManager *)locationManager
{
    if(!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationErrorCode = error.code;
}


- (IBAction)extraCreditSwitchToggled:(UISwitch *)sender
{
    self.hasExtraCredit = sender.on;
}
- (IBAction)fastReviewSwitchToggled:(UISwitch *)sender
{
}


- (IBAction)takePhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera|UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(!image) image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)filterPhoto
{
    if (!self.image) {
        [self alert:@"You must take a photo first!"];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Filter Image"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        for (NSString *filter in [self filters]) {
            [actionSheet addButtonWithTitle:filter];
        }
        [actionSheet addButtonWithTitle:@"Cancel"]; // put at bottom (don't do at all on iPad)
        
        [actionSheet showInView:self.view]; // different on iPad
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSString *filterName = [self filters][choice];
    self.image = [self.image imageByApplyingFilterNamed:filterName];
}

- (NSDictionary *)filters
{
    return @{ @"Chrome" : @"CIPhotoEffectChrome",
              @"Blur" : @"CIGaussianBlur",
              @"Noir" : @"CIPhotoEffectNoir",
              @"Fade" : @"CIPhotoEffectFade" };
}

- (BOOL)shouldPostSubmission
{
    if(!self.image) {
        [self alert:@"No photo taken!"];
        return NO;
    } else if(!self.location) {
        switch (self.locationErrorCode) {
            case kCLErrorLocationUnknown:
                [self alert:@"Couldn't figure out where this photo was taken (yet)."]; break;
            case kCLErrorDenied:
                [self alert:@"Location Services disabled under Privacy in Settings."]; break;
            case kCLErrorNetwork:
                [self alert:@"Can't figure out where this photo is being taken. Verify your connection to the network"]; break;
            default:
                [self alert:@"Can't figure out where this photo is being taken, sorry. "]; break;
        }
        return NO;
    } else {
        return YES;
    }
}

- (void)prepareForSubmission
{
    //self.submission.user = [[User class] currentUserInManagedObjectContext:self.submission.managedObjectContext];
    self.submission.latitude = @(self.location.coordinate.latitude);
    self.submission.longitude = @(self.location.coordinate.longitude);
    self.submission.hasExtraCredit = @(self.hasExtraCredit);
    //NSLog(@"submission : lat=%f, lng=%f, ec=%d, quest_id=%d, user_id=%d", self.submission.latitude.floatValue, self.submission.longitude.floatValue, self.submission.hasExtraCredit.boolValue, self.submission.questID.intValue, self.submission.userID.intValue);
}

- (IBAction)postSubmission
{
    if ([self shouldPostSubmission]) {
        [self prepareForSubmission];
        
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        if(![objectManager.requestDescriptors containsObject:self.postSubmissionRequestDescriptor]) {
            [objectManager addRequestDescriptor:self.postSubmissionRequestDescriptor];
        }
        if(![objectManager.responseDescriptors containsObject:self.postSubmissionResponseDescriptor]) {
            [objectManager addResponseDescriptor:self.postSubmissionResponseDescriptor];
        }
        
        NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:self.submission
                                                                                                method:RKRequestMethodPOST
                                                                                                  path:@"/submissions"
                                                                                            parameters:nil
                                                                             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                 [formData appendPartWithFileData:UIImageJPEGRepresentation(self.image, 1.0f)
                                                                                                             name:@"submission[photo]"
                                                                                                         fileName:@"photo.jpg"
                                                                                                         mimeType:@"image/jpg"];
                                                                             }];
        
        RKManagedObjectRequestOperation *operation = [[RKObjectManager sharedManager] managedObjectRequestOperationWithRequest:request managedObjectContext:self.submission.managedObjectContext success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"POST submission was successful %@ (size=%d)", mappingResult.firstObject, [mappingResult.array count]);            
            self.image = nil; // delete the image and thumb caches from the file system
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could not submit photo"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        
        [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
    }
}


@end
