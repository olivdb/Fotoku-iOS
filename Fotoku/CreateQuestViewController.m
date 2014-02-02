//
//  AddQuestViewController.m
//  Fotoku
//
//  Created by Olivier on 17/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "CreateQuestViewController.h"
#import "User.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Helper.h"
#import "QuestCreationSuccessResponse.h"


@interface CreateQuestViewController () <UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic, readwrite) Quest *createdQuest;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger locationErrorCode;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; //only used if CreateQuestViewController doesn't subclass a static UITableViewController (but instead subclasses a generic UIViewController)
@property (weak, nonatomic) IBOutlet UITableViewCell *extraCreditDescriptionCell;
@property (weak, nonatomic) IBOutlet UITextField *extraCreditDescriptionTextField;
@property (strong, nonatomic) RKRequestDescriptor *postQuestRequestDescriptor;
@property (strong, nonatomic) RKResponseDescriptor *questCreationSuccessResponseDescriptor;
@end

@implementation CreateQuestViewController

- (RKRequestDescriptor *)postQuestRequestDescriptor
{
    if(!_postQuestRequestDescriptor) {
        RKEntityMapping *questMapping = [RKEntityMapping mappingForEntityForName:@"Quest"
                                                            inManagedObjectStore:[RKManagedObjectStore defaultStore]];
        [questMapping addAttributeMappingsFromDictionary:@{@"title":                    @"title",
                                                           @"latitude":                 @"latitude",
                                                           @"longitude":                @"longitude",
                                                           @"extra_credit_description": @"extraCreditDescription"}];
        _postQuestRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[questMapping inverseMapping]
                                                                        objectClass:[Quest class]
                                                                        rootKeyPath:@"quest"
                                                                            method:RKRequestMethodAny];
    }
    return _postQuestRequestDescriptor;
}

- (RKResponseDescriptor *)questCreationSuccessResponseDescriptor
{
    if(!_questCreationSuccessResponseDescriptor) {
        RKObjectMapping *questCreationSuccessMapping = [RKObjectMapping mappingForClass:[QuestCreationSuccessResponse class]];
        [questCreationSuccessMapping addAttributeMappingsFromDictionary:@{@"id":               @"questID",
                                                                          @"photo_url":        @"photoURL",
                                                                          @"photo_url_medium": @"mediumPhotoURL",
                                                                          @"photo_url_thumb":  @"thumbnailURL"}];
        NSIndexSet *successStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
        _questCreationSuccessResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:questCreationSuccessMapping
                                                                                               method:RKRequestMethodAny
                                                                                          pathPattern:@"/quests"
                                                                                              keyPath:nil
                                                                                          statusCodes:successStatusCodes];
    }
    return _questCreationSuccessResponseDescriptor;
}

- (IBAction)extraCreditSwitchToggled:(UISwitch *)sender
{
    self.extraCreditDescriptionCell.hidden = !sender.on;
}


+ (BOOL)canCreateQuest
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
    
    if(![[self class] canCreateQuest])
    {
        [self fatalAlert:@"Sorry, this device cannot create a quest."];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setupSrollViewContentSize];
}

//only used if CreateQuestViewController doesn't subclass a static UITableViewController (but instead subclasses a generic UIViewController)
- (void) setupSrollViewContentSize
{
    if(self.scrollView) { 
        CGFloat scrollViewContentHeight = 0;
        for (UIView *subview in self.scrollView.subviews) {
            CGFloat viewBottom = subview.frame.origin.y + subview.frame.size.height;
            if (viewBottom > scrollViewContentHeight)
                scrollViewContentHeight = viewBottom;
        }
        scrollViewContentHeight += 20; // adding the standard auto-layout spacing to the scrollView's content height
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, scrollViewContentHeight);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
    [self updateAnnotation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationErrorCode = error.code;
}

-(void)setLocation:(CLLocation *)location
{
    _location = location;
    [self updateAnnotation];
}

- (void)updateAnnotation
{
    // let's update the mapView
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.location.coordinate;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:annotation];
    [self.mapView showAnnotations:@[annotation] animated:YES];
}

- (IBAction)mapTapped:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if(self.mapView.annotations.count) {
            CGPoint point = [sender locationInView:self.mapView];
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
            self.location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
            [self.locationManager stopUpdatingLocation];
        }
    }
}

- (NSURL *)uniqueDocumentURL
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f", floor([NSDate timeIntervalSinceReferenceDate])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

- (NSURL *)imageURL
{
    if(!_imageURL && self.image) {
        NSURL *url = [self uniqueDocumentURL];
        if(url) {
            NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
            if([imageData writeToURL:url atomically:YES]) {
                _imageURL = url;
            }
        }
    }
    return _imageURL;
}

- (NSURL *)thumbnailURL
{
    NSURL *url = [self.imageURL URLByAppendingPathExtension:@"thumbnail"];
    
    if(![_thumbnailURL isEqual:url]) {
        _thumbnailURL = nil;
        if(url) {
            UIImage *thumbnail = [self.image imageByScalineToSize:CGSizeMake(75, 75)];
            NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
            if([imageData writeToURL:url atomically:YES]) {
                _thumbnailURL = url;
            }
        }
    }
    return _thumbnailURL;
}


- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    // when image is changed, we must delete files we've created for previous image (if any)
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:_thumbnailURL error:NULL];
    self.imageURL = nil;
    self.thumbnailURL = nil;
    
    // let's update the mapView to show where the image was taken
    //MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    //annotation.coordinate = self.location.coordinate;
    //[self.mapView removeAnnotations:self.mapView.annotations];
    //[self.mapView addAnnotation:annotation];
    //[self.mapView showAnnotations:@[annotation] animated:NO];
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (IBAction)cancel
{
    self.image = nil; // this will clean up the image & thumbnail url's (i.e. remove the files from disk; see setImage:)
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
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

#define UNWIND_SEGUE_IDENTIFIER @"Do Create Quest"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSManagedObjectContext *context = self.questOwner.managedObjectContext;
        if(context) {
            Quest *quest = [NSEntityDescription insertNewObjectForEntityForName:@"Quest"
                                                         inManagedObjectContext:context];
            quest.questTitle = self.titleTextField.text;
            quest.owner = self.questOwner;
            quest.latitude = @(self.location.coordinate.latitude);
            quest.longitude = @(self.location.coordinate.longitude);
            quest.photoURL = [self.imageURL absoluteString];
            quest.thumbnailURL = [self.thumbnailURL absoluteString];
            quest.extraCreditDescription = self.extraCreditDescriptionTextField.text.length ? self.extraCreditDescriptionTextField.text : @"";
            
            self.createdQuest = quest;
            
            // now we need to make sure that the files corresponding to image and thumbnails won't be deleted next time image is changed (after a new modal segway to this controller), so let's protect these files from destruction by setting their url's to nil (so that the files won't be deleted in setImage: in the future)
            //self.imageURL = nil;
            //self.thumbnailURL = nil;
            
            [self postQuest:quest];
        }
    }
}

- (void)postQuest:(Quest *)quest
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    if(![objectManager.requestDescriptors containsObject:self.postQuestRequestDescriptor]) {
        [objectManager addRequestDescriptor:self.postQuestRequestDescriptor];
    }
    if(![objectManager.responseDescriptors containsObject:self.questCreationSuccessResponseDescriptor]) {
        [objectManager addResponseDescriptor:self.questCreationSuccessResponseDescriptor];
    }
    
    /*[[RKObjectManager sharedManager] postObject:quest path:@"/quests" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"post quest success: %@", mappingResult.array);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];*/
    
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:quest
                                                                                           method:RKRequestMethodPOST
                                                                                             path:@"/quests"
                                                                                       parameters:nil
                                                                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                            [formData appendPartWithFileData:UIImageJPEGRepresentation(self.image, 1.0f)
                                                                                                        name:@"quest[photo]"
                                                                                                    fileName:@"photo.jpg"
                                                                                                    mimeType:@"image/jpg"];
    }];
    
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //NSLog(@"POST quest was successful %@, %@ (size=%d), %@ (size=%d)", mappingResult.firstObject, mappingResult.array, [mappingResult.array count], mappingResult.dictionary, [mappingResult.dictionary count]);
        QuestCreationSuccessResponse *response = (QuestCreationSuccessResponse *)mappingResult.firstObject;
        quest.id = response.questID;
        quest.photoURL = response.photoURL;
        quest.mediumPhotoURL = response.mediumPhotoURL;
        quest.thumbnailURL = response.thumbnailURL;
        self.image = nil; // delete the image and thumb caches from the file system
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could not create new quest"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
                                           
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        if(!self.image) {
            [self alert:@"No photo taken!"];
            return NO;
        } else if (![self.titleTextField.text length]) {
            [self alert:@"Title required!"];
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
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Create Quest"
                               message:msg
                              delegate:nil
                     cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Create Quest"
                                message:msg
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancel];
}

#pragma mark - Filter Image

- (IBAction)filterImage
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

@end
