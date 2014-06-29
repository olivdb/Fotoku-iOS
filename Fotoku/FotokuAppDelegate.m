//
//  FotokuAppDelegate.m
//  Fotoku
//
//  Created by Olivier on 13/01/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "FotokuAppDelegate.h"
#import "QuestsCDTVC.h"
#import "Quest.h"
#import "LoginRequest.h"
#import "ErrorResponse.h"
#import "LoginSuccessResponse.h"
#import "UICKeyChainStore.h"
#import "LoginViewController.h"
#import "Authentication.h"
#import "ProfileViewController.h"
#import "User+Current.h"

@implementation FotokuAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupRestKit];
    
    
    // Uncomment to clear all saved data before launching (for testing purpose)
    //[self clearAllSavedData];
    
    
    if(![[NSUserDefaults standardUserDefaults] stringForKey:FACEBOOK_ID]
       && [UICKeyChainStore stringForKey:AUTH_TOKEN]) {
        // The app has been deleted and reinstalled. We need to clear Keychain to have consistent data in both Keychain and NSUserDefaults
        [self clearAllSavedData];
    }
    
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    // Set up quest controller
    UINavigationController *navigationController = (UINavigationController *)tabBarController.viewControllers[0];
    QuestsCDTVC *questViewController = (QuestsCDTVC *)navigationController.topViewController;
    questViewController.managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    // Set up profile controller
    ProfileViewController *profileVC = (ProfileViewController *)tabBarController.viewControllers[1];
    profileVC.managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    
    // TEST
    /*NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Quest"];
    request.predicate = nil;
    NSError *error;
    NSArray *matches = [questViewController.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@" count = %d ", [matches count]);
    if([matches count]) {
        for(Quest* sub in matches) {
            NSLog(@"quest: %@", sub);
        }
    }
    NSString *msg = [NSString stringWithFormat:@" quest count = %d ", [matches count]];
    [[[UIAlertView alloc] initWithTitle:@"Test CoreData"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];*/
    
    
    // FB SDK
    
    [FBLoginView class];
    
    return YES;
}

- (void)setupRestKit
{
    // Prepare the Store
    
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Fotoku" ofType:@"momd"]];
    // NOTE: Due to an iOS 5 bug, the managed object model returned is immutable.
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // Initialize the Core Data stack
    [managedObjectStore createPersistentStoreCoordinator];
    
    // In memory store:
    //NSPersistentStore __unused *persistentStore = [managedObjectStore addInMemoryPersistentStore:&error];
    //NSAssert(persistentStore, @"Failed to add persistent store: %@", error);
    
    // SQLite data store:
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Store.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed adding persistent store at path '%@': %@", path, error);
    
    [managedObjectStore createManagedObjectContexts];
    
    // Set the default store shared instance
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    // Configure the object manager
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://192.168.1.5:3000"]];
    objectManager.managedObjectStore = managedObjectStore;
    [RKObjectManager setSharedManager:objectManager];
    
    // Add an Error Response Descriptor
    
    // Error JSON looks like {"error": "Some Error Has Occurred"}
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[ErrorResponse class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"error" toKeyPath:@"errorMessage"]];
    NSIndexSet *errorStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError); //4xx status code range
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:errorStatusCodes];
    [objectManager addResponseDescriptor:errorDescriptor];
    
}

- (void)clearAllSavedData
{
    // Clear Keychain
    [UICKeyChainStore removeAllItems];
    
    // Clear UserDefaults
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) { [defs removeObjectForKey:key]; }
    [defs synchronize];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}


@end
