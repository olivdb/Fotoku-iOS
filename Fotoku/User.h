//
//  User.h
//  Fotoku
//
//  Created by Olivier on 13/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Quest;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *quests;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addQuestsObject:(Quest *)value;
- (void)removeQuestsObject:(Quest *)value;
- (void)addQuests:(NSSet *)values;
- (void)removeQuests:(NSSet *)values;

@end
