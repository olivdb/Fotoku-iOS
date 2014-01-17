//
//  QuestsCDTVC.m
//  Fotoku
//
//  Created by Olivier on 13/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "QuestsCDTVC.h"
#import "Quest.h"
#import "User+Current.h"
#import "QuestCell.h"
#import "CreateQuestViewController.h"

@interface QuestsCDTVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addQuestBarButtonItem;
@end

@implementation QuestsCDTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Quest"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(loadQuests) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self loadQuests];
    [self.refreshControl beginRefreshing];
    
    
    
}

- (void)loadQuests
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/quests/index" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.refreshControl endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void)insertNewObject:(id)sender
{
    /*
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
     */
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Quest Cell"];
    
    Quest *quest = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = quest.title;
    cell.distanceLabel.text = @"0 km";
#warning Blocking main queue!
    cell.thumbnailView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:quest.photoURL]]];
    
    return cell;
}

#pragma mark - Modal Quest Creation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[CreateQuestViewController class]]) {
        CreateQuestViewController *createQuestVC = (CreateQuestViewController *)segue.destinationViewController;
        createQuestVC.questOwner = [User currentUserInManagedObjectContext:self.managedObjectContext];
    }
}

- (IBAction)createdQuest:(UIStoryboardSegue *)segue
{
    if([segue.sourceViewController isKindOfClass:[CreateQuestViewController class]]) {
        CreateQuestViewController *createQuestVC = (CreateQuestViewController *)segue.sourceViewController;
        Quest *createdQuest = createQuestVC.createdQuest;
        if(createdQuest) {
            //TODO: insert new quest to this QuestsCDTVC
        } else {
            NSLog(@"CreateQuestViewController unexpectedly did not create a quest!");
        }
    }
}


@end
