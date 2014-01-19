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

    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(loadQuests) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self loadQuests];
    [self.refreshControl beginRefreshing];
}

- (void)loadQuests
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/quests" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
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


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Quest Cell"];
    
    Quest *quest = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = quest.title;
    cell.distanceLabel.text = @"0 km";
#warning Blocking main queue!
    cell.thumbnailView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:quest.thumbnailURL]]];
    
    return cell;
}

#pragma mark - Modal Quest Creation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destinationVC = segue.destinationViewController;
    if([destinationVC isKindOfClass:[UINavigationController class]]) {
        destinationVC = ((UINavigationController *)destinationVC).topViewController;
    }
    if([destinationVC isKindOfClass:[CreateQuestViewController class]]) {
        CreateQuestViewController *createQuestVC = (CreateQuestViewController *)destinationVC;
        createQuestVC.questOwner = [User currentUserInManagedObjectContext:self.managedObjectContext];
    }
}

- (IBAction)createdQuest:(UIStoryboardSegue *)segue
{
    if([segue.sourceViewController isKindOfClass:[CreateQuestViewController class]]) {
        CreateQuestViewController *createQuestVC = (CreateQuestViewController *)segue.sourceViewController;
        Quest *createdQuest = createQuestVC.createdQuest;
        if(createdQuest) {
            //TODO: do something?
        } else {
            NSLog(@"CreateQuestViewController unexpectedly did not create a quest!");
        }
    }
}


@end
