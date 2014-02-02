//
//  QuestViewController.m
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 28/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "QuestViewController.h"
#import <MapKit/MapKit.h>
#import "User.h"
#import "Quest+Annotation.h"
#import "SubmitSolutionViewController.h"
#import "Submission+Create.m"

@interface QuestViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
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
@end

@implementation QuestViewController


-(void) setImageView:(UIImageView *)imageView
{
    _imageView = imageView;
    [self.imageView setImageWithURL:[NSURL URLWithString:self.quest.mediumPhotoURL]];
}

-(void) setTitleLabel:(UILabel *)titleLabel
{
    _titleLabel = titleLabel;
    self.titleLabel.text = self.quest.questTitle;
}

-(void) setCreatorButton:(UIButton *)creatorButton
{
    _creatorButton = creatorButton;
    [self.creatorButton setTitle:self.quest.owner.name forState:UIControlStateNormal];
}

-(void) setExtraCreditDescriptionLabel:(UILabel *)extraCreditDescriptionLabel
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
            solutionVC.submission = [[Submission class] submissionForQuest:self.quest];
        }
    }
}



@end
