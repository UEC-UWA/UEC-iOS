//
//  UECUniversalAppHelper.m
//  UEC
//
//  Created by Jad Osseiran on 6/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECUniversalAppManager.h"

@interface UECUniversalAppManager ()

@property (strong, nonatomic) NSArray *storyboardFileNames;

@end

@implementation UECUniversalAppManager

+ (UECUniversalAppManager *)sharedManager
{
    static __DISPATCH_ONCE__ UECUniversalAppManager *singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
        
        NSString *path = [[NSBundle mainBundle] resourcePath];
        singletonObject.storyboardFileNames = [singletonObject recursivePathsForResourcesOfType:@"storyboardc"
                                                                                    inDirectory:path];
    });
    
    return singletonObject;
}

- (NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath
{
    NSMutableArray *stroyboardNames = [[NSMutableArray alloc] init];
    
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    
    NSString *filePath = nil;
    
    while ((filePath = [enumerator nextObject]) != nil) {
        // If we have the right type of file, add it to the list
        // Make sure to prepend the directory path
        if ([[filePath pathExtension] isEqualToString:type]) {
            [stroyboardNames addObject:[[filePath pathComponents] lastObject]];
        }
    }
        
    return stroyboardNames;
}

- (BOOL)validStoryboard:(NSString *)storyboardName
{
    NSMutableString *storyboard = [[NSMutableString alloc] initWithString:storyboardName];
    [storyboard appendString:@".storyboardc"];
    
    return [self.storyboardFileNames containsObject:storyboard];
}

- (UIStoryboard *)deviceStroyboardFromTitle:(NSString *)nibTitle
{
    NSMutableString *deviceStroyboard = [[NSMutableString alloc] initWithString:nibTitle];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        [deviceStroyboard appendString:@"Storyboard_iPad"];
    else
        [deviceStroyboard appendString:@"Storyboard_iPhone"];
    
    if ([self validStoryboard:deviceStroyboard]) {
        return [UIStoryboard storyboardWithName:deviceStroyboard bundle:nil];
    } else {
        return nil;
    }
}

@end
