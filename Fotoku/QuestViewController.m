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

@interface QuestViewController ()
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
    self.titleLabel.text = self.quest.title;
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

@end
