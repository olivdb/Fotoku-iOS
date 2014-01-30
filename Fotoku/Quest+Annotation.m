//
//  Quest+Annotation.m
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 18/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "Quest+Annotation.h"
#import "User.h"

@implementation Quest (Annotation)

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    
    return coordinate;
}

- (NSString *) subtitle
{
    return @"Center of the search region (radius = 3km)";
}

- (NSString *) title
{
    //return [NSString stringWithFormat:@"%@ - ⭐️⭐️⭐️ - Medium", self.questTitle];
    return self.questTitle;
}

@end
