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
#import "UICKeyChainStore.h"
#import "LoginViewController.h"
#import "ProfileViewController.h"

@interface QuestsCDTVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addQuestBarButtonItem;
@property (strong, nonatomic) RKResponseDescriptor *getQuestsResponseDescriptor;
@property (strong, nonatomic) id<FBGraphUser> fbUser;//TODO: remove (possible to find current user with User+Current category)
@end

@implementation QuestsCDTVC


- (RKResponseDescriptor *) getQuestsResponseDescriptor
{
    if(!_getQuestsResponseDescriptor) {
        RKEntityMapping *questMapping = [RKEntityMapping mappingForEntityForName:@"Quest"
                                                            inManagedObjectStore:[RKManagedObjectStore defaultStore]];
        [questMapping addAttributeMappingsFromDictionary:@{@"id":             @"id",
                                                           @"title":          @"title",
                                                           @"photo_url":      @"thumbnailURL"}];
        questMapping.identificationAttributes = @[ @"id" ];
        RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User"
                                                           inManagedObjectStore:[RKManagedObjectStore defaultStore]];
        [userMapping addAttributeMappingsFromDictionary:@{@"id":             @"id",
                                                          @"name":           @"name"}];
        userMapping.identificationAttributes = @[ @"id" ];
        [questMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"owner"
                                                                                     toKeyPath:@"owner"
                                                                                   withMapping:userMapping]];
        _getQuestsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:questMapping
                                                                                 method:RKRequestMethodAny
                                                                            pathPattern:@"/quests"
                                                                                keyPath:nil
                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    }
    return _getQuestsResponseDescriptor;
}

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self login];
    [self loadQuests];
    [self.refreshControl beginRefreshing];
}

#define AUTH_TOKEN @"auth_token"

- (void)login
{
    if(![[[[RKObjectManager sharedManager] HTTPClient] defaultHeaders] objectForKey:AUTH_TOKEN]) {
        NSString *authenticationToken = [UICKeyChainStore stringForKey:AUTH_TOKEN];
        if(!authenticationToken) {
            [self performSegueWithIdentifier:@"Login" sender:self];
            // note : there are alternative implemntations as to how to display the loginVC
            // see http://stackoverflow.com/questions/8221787/perform-segue-on-viewdidload
        } else {
            [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:AUTH_TOKEN
                                                                     value:authenticationToken];
        }
    }
}

- (void)loadQuests
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    if(![objectManager.responseDescriptors containsObject:self.getQuestsResponseDescriptor]) {
        [objectManager addResponseDescriptor:self.getQuestsResponseDescriptor];
    }

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

#pragma mark - Modal Quest Creation and Modal Login
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"CreateQuest"]) {
        UIViewController *destinationVC = segue.destinationViewController;
        if([destinationVC isKindOfClass:[UINavigationController class]]) {
            destinationVC = ((UINavigationController *)destinationVC).topViewController;
        }
        if([destinationVC isKindOfClass:[CreateQuestViewController class]]) {
            CreateQuestViewController *createQuestVC = (CreateQuestViewController *)destinationVC;
            createQuestVC.questOwner = [User currentUserInManagedObjectContext:self.managedObjectContext];
        }
    } else if([segue.identifier isEqualToString:@"Profile"]) {
        UIViewController *destinationVC = segue.destinationViewController;
        if([destinationVC isKindOfClass:[ProfileViewController class]]) {
            ProfileViewController *profileVC = (ProfileViewController *)destinationVC;
            profileVC.fbUser = self.fbUser;//TODO: instead, find the user with currentUser from User+Current category
        }
        
    } else if([segue.identifier isEqualToString:@"Login"]) {
        
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

- (IBAction)loggedIn:(UIStoryboardSegue *)segue
{
    if([segue.sourceViewController isKindOfClass:[LoginViewController class]]) {
        LoginViewController *loginVC = (LoginViewController *)segue.sourceViewController;
        self.fbUser = loginVC.fbUser;//TODO: instead of saving it to property, save fbID and fbName to NSUserDefaults
        [UICKeyChainStore setString:loginVC.authenticationToken forKey:AUTH_TOKEN];
        [self login];
    }
}


@end
