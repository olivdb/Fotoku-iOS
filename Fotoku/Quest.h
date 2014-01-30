//
//  Quest.h
//  Fotoku
//
//  Created by Olivier on 30/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Quest : NSManagedObject

@property (nonatomic, retain) NSString * extraCreditDescription;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * mediumPhotoURL;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * questTitle;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) User *owner;

@end
