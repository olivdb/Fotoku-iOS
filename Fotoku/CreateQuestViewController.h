//
//  AddQuestViewController.h
//  Fotoku
//
//  Created by Olivier on 17/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quest.h"

@interface CreateQuestViewController : UITableViewController

//in
@property (nonatomic, strong) User *questOwner;

//out
@property (nonatomic, strong, readonly) Quest *createdQuest;

@end
