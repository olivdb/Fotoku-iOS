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


@interface CreateQuestViewController () <UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic, readwrite) Quest *createdQuest;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation CreateQuestViewController

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

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.image = [UIImage imageNamed:@"futuroscope.jpg"];
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
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:_thumbnailURL error:NULL];
    self.imageURL = nil;
    self.thumbnailURL = nil;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (IBAction)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePhoto
{
}

- (IBAction)editLocation
{
}
#define UNWIND_SEGUE_IDENTIFIER @"Do Create Quest"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSManagedObjectContext *context = self.questOwner.managedObjectContext;
        if(context) {
            Quest *quest = [NSEntityDescription insertNewObjectForEntityForName:@"Quest"
                                                         inManagedObjectContext:context];
            quest.title = self.titleTextField.text;
            quest.owner = self.questOwner;
            quest.latitude = @(self.location.coordinate.latitude);
            quest.longitude = @(self.location.coordinate.longitude);
            quest.photoURL = [self.imageURL absoluteString];
            quest.thumbnailURL = [self.thumbnailURL absoluteString];
            
            self.createdQuest = quest;
        }
    }
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

@end
