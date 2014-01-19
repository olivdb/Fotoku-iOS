//
//  UIImage+Helper.h
//  Fotoku
//
//  Created by Olivier on 17/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

//make a copy at a different size
- (UIImage *)imageByScalineToSize:(CGSize)size;

// applies filter
- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName;

@end
