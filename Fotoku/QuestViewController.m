//
//  QuestViewController.m
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 28/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "QuestViewController.h"
#import <MapKit/MapKit.h>
#import "User+Current.h"
#import "Quest+Annotation.h"
#import "SubmitSolutionViewController.h"
#import "Submission+Create.h"

@interface QuestViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *questPhotoView;
@property (weak, nonatomic) IBOutlet UIImageView *submissionView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinRewardLabel;
@property (weak, nonatomic) IBOutlet UILabel *xpRewardLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinExtraCreditLabel;
@property (weak, nonatomic) IBOutlet UILabel *xpExtraCreditLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgesLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *creatorButton;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet UILabel *extraCreditDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) Submission *submission;
@end

@implementation QuestViewController


- (Submission*)submission
{
    if(!_submission) {
        _submission = [[Submission class] submissionForQuest:self.quest byUser:self.user];
    }
    return _submission;
}

- (void)refreshSubmissionView
{
    
}

- (void)setSubmissionView:(UIImageView *)submissionView
{
    _submissionView = submissionView;
    
    NSLog(@"QuestVC :: setSubmissionView localURL = %@, photoURL = %@", self.submission.photoLocalURL, self.submission.photoURL);
    NSURL *url = [NSURL URLWithString:self.submission.photoLocalURL];
    NSString *path = [url path];
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    { NSLog(@" localURL exists"); }
    else
    { NSLog(@" doesn't exists"); }
    
    
    //TODO: use thumbnails here
    if(self.submission.photoLocalURL) {
        [self.submissionView setImageWithURL:[NSURL URLWithString:self.submission.photoLocalURL]];
    } else if(self.submission.photoURL) {
        [self.submissionView setImageWithURL:[NSURL URLWithString:self.submission.photoURL]];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"QuestVC :: viewDidAppear localURL = %@, photoURL = %@", self.submission.photoLocalURL, self.submission.photoURL);
    NSURL *url = [NSURL URLWithString:self.submission.photoLocalURL];
    NSString *path = [url path];
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    { NSLog(@" localURL exists"); }
    else
    { NSLog(@" doesn't exists"); }
}

- (void)setQuestPhotoView:(UIImageView *)imageView
{
    _questPhotoView = imageView;
    [self.questPhotoView setImageWithURL:[NSURL URLWithString:self.quest.mediumPhotoURL]];
}

- (void)setTitleLabel:(UILabel *)titleLabel
{
    _titleLabel = titleLabel;
    self.titleLabel.text = self.quest.questTitle;
}

- (void)setCreatorButton:(UIButton *)creatorButton
{
    _creatorButton = creatorButton;
    [self.creatorButton setTitle:self.quest.owner.name forState:UIControlStateNormal];
}

- (void)setExtraCreditDescriptionLabel:(UILabel *)extraCreditDescriptionLabel
{
    if(self.quest.extraCreditDescription.length) {
        self.extraCreditDescriptionLabel.text = self.quest.extraCreditDescription;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setupSrollViewContentSize];
}

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


- (IBAction)submitPhoto
{
}

- (IBAction)showCreatorProfile
{
}

- (void) setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
    CLLocationDistance fenceDistance = 3000;
    CLLocationCoordinate2D circleMiddlePoint = CLLocationCoordinate2DMake(self.quest.latitude.doubleValue, self.quest.longitude.doubleValue);
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:circleMiddlePoint radius:fenceDistance];
    [self.mapView addOverlay:circle level:MKOverlayLevelAboveLabels];
    [self.mapView addAnnotation:self.quest];
    [self.mapView setVisibleMapRect:circle.boundingMapRect edgePadding:UIEdgeInsetsMake(10, 0, 10, 0) animated:false];
}


- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    circleRenderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    return circleRenderer;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Submit Photo"]) {
        UIViewController *destinationVC = segue.destinationViewController;
        if([destinationVC isKindOfClass:[SubmitSolutionViewController class]]) {
            SubmitSolutionViewController *solutionVC = (SubmitSolutionViewController *)destinationVC;
            solutionVC.submission = [[Submission class] submissionForQuest:self.quest byUser:[[User class] currentUserInManagedObjectContext:self.quest.managedObjectContext]];
        }
    }
}

- (IBAction)submittedPhotoTapped:(UITapGestureRecognizer *)sender
{
    if(self.submission.photoLocalURL || self.submission.photoURL) {
        [self performSegueWithIdentifier:@"Submit Photo" sender:self];
    } else {
        [self takePhoto];
    }
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
    
    // Save image in the file system; update the submission with the photo local url; update the submission view
    /*
     - (IBAction)saveImage {
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0];
     NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
     UIImage *image = imageView.image; // imageView is my image from camera
     NSData *imageData = UIImagePNGRepresentation(image);
     [imageData writeToFile:savedImagePath atomically:NO];
     }
     */
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f", floor([NSDate timeIntervalSinceReferenceDate])];
    NSURL *localPhotoURL = [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if([imageData writeToURL:localPhotoURL atomically:YES]) {
        self.submission.photoLocalURL = [localPhotoURL absoluteString];
        
        NSLog(@"QuestVC :: imagePickerdidFinishPicking localURL = %@, photoURL = %@", self.submission.photoLocalURL, self.submission.photoURL);
        NSURL *url = [NSURL URLWithString:self.submission.photoLocalURL];
        NSString *path = [url path];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        { NSLog(@" localURL exists"); }
        else
        { NSLog(@" doesn't exists"); }
        
        [self.submissionView setImageWithURL:[NSURL URLWithString:self.submission.photoLocalURL]];
        [self performSegueWithIdentifier:@"Submit Photo" sender:self];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
