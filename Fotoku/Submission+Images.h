//
//  Submission+Images.h
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 29/06/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "Submission.h"

@interface Submission (Images)
- (void)loadPhotoInImageView:(UIImageView*)imageView;
- (BOOL)setPhoto:(UIImage*)image;
@end
