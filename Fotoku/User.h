//
//  User.h
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 1/02/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Quest;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *quests;
@property (nonatomic, retain) NSSet *submissions;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addQuestsObject:(Quest *)value;
- (void)removeQuestsObject:(Quest *)value;
- (void)addQuests:(NSSet *)values;
- (void)removeQuests:(NSSet *)values;

- (void)addSubmissionsObject:(NSManagedObject *)value;
- (void)removeSubmissionsObject:(NSManagedObject *)value;
- (void)addSubmissions:(NSSet *)values;
- (void)removeSubmissions:(NSSet *)values;

@end
