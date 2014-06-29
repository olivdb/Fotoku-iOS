//
//  Submission+Images.m
//  Fotoku
//
//  Created by Olivier van den Biggelaar on 29/06/14.
//  Copyright (c) 2014 Olivier Van Den Biggelaar. All rights reserved.
//

#import "Submission+Images.h"

@implementation Submission (Images)
- (void)loadPhotoInImageView:(UIImageView*)imageView
{
    //TODO: use thumbnails here
    NSURL *localURL = [NSURL URLWithString:self.photoLocalURL];
    if(localURL && [[NSFileManager defaultManager] fileExistsAtPath:[localURL path]]) { // The submission photo exists locally
        imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localURL]];
    } else if(self.photoURL) { // The submission photo exists on the server
        [imageView setImageWithURL:[NSURL URLWithString:self.photoURL]];
    } else {
       // No photo to load. Loading placeholder instead.
    }
}

- (BOOL)setPhoto:(UIImage*)image
{
    // Save image in the file system
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f", floor([NSDate timeIntervalSinceReferenceDate])];
    NSURL *localPhotoURL = [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    if([imageData writeToURL:localPhotoURL atomically:YES]) {
        if(self.photoLocalURL) {
            [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:self.photoLocalURL] error:NULL];
            NSLog(@"Deleted local photo at %@", self.photoLocalURL);
            self.photoLocalURL = nil;
        } else if(self.photoURL) {
            self.photoURL = nil;
        }
        
        self.photoLocalURL = [localPhotoURL absoluteString];
        [self.managedObjectContext saveToPersistentStore:nil];
        
        return YES;
    }
    
    return NO;
}
@end
