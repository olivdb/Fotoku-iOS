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
#import "Authentication.h"
#import "QuestViewController.h"

@interface QuestsCDTVC () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addQuestBarButtonItem;
@property (strong, nonatomic) RKResponseDescriptor *getQuestsResponseDescriptor;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) BOOL firstLoad;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger locationErrorCode;
@end

@implementation QuestsCDTVC

- (CLLocationManager *)locationManager
{
    if(!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.firstLoad = YES;
        _locationManager = locationManager;
    }
    return _locationManager;
}

#define MIN_HORIZONTAL_LOCATION_ACCURACY 1000 //in meters

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
    //NSLog(@"Acquired location with accuracy %f at(%f,%f)", self.location.horizontalAccuracy, self.location.coordinate.longitude, self.location.coordinate.latitude);
    if(self.firstLoad && self.location.horizontalAccuracy < MIN_HORIZONTAL_LOCATION_ACCURACY) {
        [self loadQuests];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationErrorCode = error.code;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager performSelector:@selector(requestWhenInUseAuthorization)];
        //[_locationManager requestAlwaysAuthorization];
    }
    [super viewWillAppear:animated];
    [self.locationManager startUpdatingLocation];
    [self login];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (RKResponseDescriptor *) getQuestsResponseDescriptor
{
    if(!_getQuestsResponseDescriptor) {
        RKEntityMapping *questMapping = [RKEntityMapping mappingForEntityForName:@"Quest"
                                                            inManagedObjectStore:[RKManagedObjectStore defaultStore]];
        [questMapping addAttributeMappingsFromDictionary:@{@"id":               @"id",
                                                           @"title":            @"questTitle",
                                                           @"photo_url":        @"photoURL",
                                                           @"photo_url_medium": @"mediumPhotoURL",
                                                           @"photo_url_thumb":  @"thumbnailURL",
                                                           @"latitude":         @"latitude",
                                                           @"longitude":        @"longitude"}];
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
                                                                                 method:RKRequestMethodGET
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
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"distance"
                                                              ascending:YES]];
    
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

- (BOOL)canUseLocation
{
    if(!self.location) {
        switch (self.locationErrorCode) {
            case kCLErrorLocationUnknown:
                [self alert:@"Couldn't figure out where you are (yet)."]; break;
            case kCLErrorDenied:
                [self alert:@"Location Services disabled under Privacy in Settings."]; break;
            case kCLErrorNetwork:
                [self alert:@"Can't figure out where you are. Verify your connection to the network"]; break;
            default:
                [self alert:@"Can't figure out where you are, sorry. "]; break;
        }
        return NO;
    }
    return YES;
}

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Load Nearby Quests"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)loadQuests
{
    if(![self canUseLocation]) {
        return;
    }
    
    self.firstLoad = NO;
    
    [self.refreshControl beginRefreshing];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    if(![objectManager.responseDescriptors containsObject:self.getQuestsResponseDescriptor]) {
        [objectManager addResponseDescriptor:self.getQuestsResponseDescriptor];
    }

    //NSDictionary *params = @{ @"latitude" : @59.92156538116700, @"longitude" : @30.34271342927777 };
    //NSLog(@"coordinates : (lat=%f, lng=%f)", self.location.coordinate.latitude, self.location.coordinate.longitude);
    NSDictionary *params = @{ @"latitude" : @((double)self.location.coordinate.latitude), @"longitude" : @((double)self.location.coordinate.longitude) };

    [[RKObjectManager sharedManager] getObjectsAtPath:@"/quests" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.refreshControl endRefreshing];
        for(Quest *quest in mappingResult.array) {
            //NSLog(@"coord quest %@: lat=%f lgn=%f, coord usr: lat=%f lgn=%f", quest.title, quest.latitude.floatValue, quest.longitude.floatValue, self.location.coordinate.latitude, self.location.coordinate.longitude);
            quest.distance = @([self.location distanceFromLocation:
                [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)quest.latitude.doubleValue
                                           longitude:(CLLocationDegrees)quest.longitude.doubleValue]
            ]);
        }
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
    
    cell.titleLabel.text = quest.questTitle;
    cell.distanceLabel.text = [self convertDistanceToString:quest.distance.doubleValue];
    if(quest.thumbnailURL.length) {
        [cell.thumbnailView setImageWithURL:[NSURL URLWithString:quest.thumbnailURL]];
    }
    return cell;
}

#pragma mark - prepareForSegue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Create Quest"]) {
        UIViewController *destinationVC = segue.destinationViewController;
        if([destinationVC isKindOfClass:[UINavigationController class]]) {
            destinationVC = ((UINavigationController *)destinationVC).topViewController;
        }
        if([destinationVC isKindOfClass:[CreateQuestViewController class]]) {
            CreateQuestViewController *createQuestVC = (CreateQuestViewController *)destinationVC;
            createQuestVC.questOwner = [User currentUserInManagedObjectContext:self.managedObjectContext];
        }
    } /*else if([segue.identifier isEqualToString:@"Profile"]) {
        UIViewController *destinationVC = segue.destinationViewController;
        if([destinationVC isKindOfClass:[ProfileViewController class]]) {
            ProfileViewController *profileVC = (ProfileViewController *)destinationVC;
            profileVC.user = [[User class] currentUserInManagedObjectContext:self.managedObjectContext];
        }
        
    }*/ else if([segue.identifier isEqualToString:@"View Quest"]) {
        UIViewController *destinationVC = segue.destinationViewController;
        if([destinationVC isKindOfClass:[QuestViewController class]]) {
            QuestViewController *questVC = (QuestViewController *)destinationVC;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            Quest *quest = [self.fetchedResultsController objectAtIndexPath:indexPath];
            questVC.quest = quest;
            questVC.user = [[User class] currentUserInManagedObjectContext:quest.managedObjectContext];
        }
        
    } else if([segue.identifier isEqualToString:@"Login"]) {
        
    }
}

#pragma mark - Modal Quest Creation and Modal Login

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
    //NSLog(@"unwinded from loginVC");
    if([segue.sourceViewController isKindOfClass:[LoginViewController class]]) {
        LoginViewController *loginVC = (LoginViewController *)segue.sourceViewController;
        [[NSUserDefaults standardUserDefaults] setObject:loginVC.fbUser.id forKey:FACEBOOK_ID];
        [[NSUserDefaults standardUserDefaults] setObject:loginVC.fbUser.name forKey:FACEBOOK_NAME];
        [[NSUserDefaults standardUserDefaults] setInteger:loginVC.userID forKey:USER_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [UICKeyChainStore setString:loginVC.authenticationToken forKey:AUTH_TOKEN];
        [self login];
    }
}

- (NSString *)convertDistanceToString:(float)distance
{
    if (distance < 100)
        return [NSString stringWithFormat:@"%g m", roundf(distance)];
    else if (distance < 1000)
        return [NSString stringWithFormat:@"%g m", roundf(distance/5)*5];
    else if (distance < 10000)
        return [NSString stringWithFormat:@"%g km", roundf(distance/100)/10];
    else
        return [NSString stringWithFormat:@"%g km", roundf(distance/1000)];
}


@end
