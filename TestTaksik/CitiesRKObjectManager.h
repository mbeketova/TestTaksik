//
//  CitiesRKObjectManager.h
//  TestTaksik
//
//  Created by Admin on 17.08.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CitiesRKObjectManager : NSObject

- (id) init;

+ (CitiesRKObjectManager *)manager;

- (NSManagedObjectContext *)managedObjectContext;

- (void)configureWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;

- (void) addMappingForEntityForName:(NSString *)nameClass
 andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
        andIdentificationAttributes:(NSArray *)ids;

- (void)getUrlObjectsAtPath:(NSString *)path
                       parameters:(NSDictionary *)params
                          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
