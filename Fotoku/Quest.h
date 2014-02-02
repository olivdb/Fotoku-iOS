//
//  Quest.h
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 1/02/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Submission, User;

@interface Quest : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * extraCreditDescription;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * mediumPhotoURL;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * questTitle;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) User *owner;
@property (nonatomic, retain) NSSet *submissions;
@end

@interface Quest (CoreDataGeneratedAccessors)

- (void)addSubmissionsObject:(Submission *)value;
- (void)removeSubmissionsObject:(Submission *)value;
- (void)addSubmissions:(NSSet *)values;
- (void)removeSubmissions:(NSSet *)values;

@end
