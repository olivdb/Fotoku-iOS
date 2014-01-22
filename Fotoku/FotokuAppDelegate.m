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

@implementation FotokuAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Prepare the Store
    
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Fotoku" ofType:@"momd"]];
    // NOTE: Due to an iOS 5 bug, the managed object model returned is immutable.
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // Initialize the Core Data stack
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSPersistentStore __unused *persistentStore = [managedObjectStore addInMemoryPersistentStore:&error];
    NSAssert(persistentStore, @"Failed to add persistent store: %@", error);
    
    [managedObjectStore createManagedObjectContexts];

    // Set the default store shared instance
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    
    
    // Configure the object manager

    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://192.168.1.22:3000"]];
    objectManager.managedObjectStore = managedObjectStore;
    [RKObjectManager setSharedManager:objectManager];

    // GET
    
    // TODO: Move this to QuestsCDTVC
    RKEntityMapping *questMapping = [RKEntityMapping mappingForEntityForName:@"Quest" inManagedObjectStore:managedObjectStore];
    [questMapping addAttributeMappingsFromDictionary:@{
                                                       @"id":             @"id",
                                                       @"title":          @"title",
                                                       @"photo_url":      @"thumbnailURL"}];
    questMapping.identificationAttributes = @[ @"id" ];
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"id":             @"id",
                                                      @"name":           @"name"}];
    userMapping.identificationAttributes = @[ @"id" ];
    [questMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"owner" toKeyPath:@"owner" withMapping:userMapping]];
    RKResponseDescriptor *getQuestsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:questMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:@"/quests"
                                                                                           keyPath:nil
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:getQuestsResponseDescriptor];
    
    // POST
    
    RKRequestDescriptor * postQuestRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[questMapping inverseMapping] objectClass:[Quest class] rootKeyPath:@"quest" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:postQuestRequestDescriptor];
    
    // FB LOGIN
    
    RKObjectMapping *loginRequestMapping = [RKObjectMapping requestMapping];
    [loginRequestMapping addAttributeMappingsFromDictionary:@{@"fbAccessToken": @"fb_access_token"}];


    RKRequestDescriptor *loginRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:loginRequestMapping objectClass:[LoginRequest class] rootKeyPath:nil method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:loginRequestDescriptor];
    
    // Set up quest controller
        
    //UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    //QuestsCDTVC *questViewController = (QuestsCDTVC *)navigationController.topViewController;
    //questViewController.managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
    
    // FB SDK
    
    [FBLoginView class];
    
    return YES;
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
