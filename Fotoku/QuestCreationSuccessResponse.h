//
//  QuestCreationSuccessResponse.h
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 25/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestCreationSuccessResponse : NSObject
@property (nonatomic, strong) NSNumber *questID;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) NSString *mediumPhotoURL;
@property (nonatomic, strong) NSString *thumbnailURL;
@end
