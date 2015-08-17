//
//  Cities.m
//  TestTaksik
//
//  Created by Admin on 17.08.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import "Cities.h"


@implementation Cities

@dynamic city_id;
@dynamic city_name;
@dynamic city_latitude;
@dynamic city_longitude;
@dynamic innerID;

+ (NSInteger)allClassCountWithContext:(NSManagedObjectContext *)managedObjectContext{
    NSUInteger retVal;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Cities" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error;
    retVal = [managedObjectContext countForFetchRequest:request error:&error];
    
    if (error)
        NSLog(@"Error: %@", [error localizedDescription]);
    
    return retVal;
}

+ (Cities *) classWithManagedObjectContext:(NSManagedObjectContext *)context andInnerID:(NSInteger)classInnerID{
    Cities *retVal = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Cities" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"innerID = %d", classInnerID];
    [request setPredicate:searchFilter];
    
    NSError * error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count > 0)
        retVal = [results objectAtIndex:0];
    if (error)
        NSLog(@"Error: %@", [error localizedDescription]);
    
    return retVal;
}

@end
