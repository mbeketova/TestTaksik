//
//  Cities.h
//  TestTaksik
//
//  Created by Admin on 17.08.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Cities : NSManagedObject

@property (nonatomic, retain) NSString * city_id;
@property (nonatomic, retain) NSString * city_name;
@property (nonatomic, retain) NSString * city_latitude;
@property (nonatomic, retain) NSString * city_longitude;
@property (nonatomic, retain) NSNumber * innerID;

+ (NSInteger)allClassCountWithContext:(NSManagedObjectContext *)managedObjectContext;
+ (Cities *) classWithManagedObjectContext:(NSManagedObjectContext *)context andInnerID:(NSInteger)classInnerID;

@end
