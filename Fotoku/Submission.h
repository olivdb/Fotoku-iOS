//
//  Submission.h
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 9/02/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Quest, User;

@interface Submission : NSManagedObject

@property (nonatomic, retain) NSNumber * coinsEarned;
@property (nonatomic, retain) NSNumber * difficulty;
@property (nonatomic, retain) NSNumber * extraCreditCoinsEarned;
@property (nonatomic, retain) NSNumber * hasExtraCredit;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSNumber * questID;
@property (nonatomic, retain) NSNumber * ranking;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSNumber * xp;
@property (nonatomic, retain) Quest *quest;
@property (nonatomic, retain) User *user;

@end
