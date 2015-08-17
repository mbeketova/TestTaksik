//
//  CitiesRKObjectManager.m
//  TestTaksik
//
//  Created by Admin on 17.08.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import "CitiesRKObjectManager.h"
#import "Cities.h"

@implementation CitiesRKObjectManager{
    RKObjectManager *objectManager;
    RKManagedObjectStore *managedObjectStore;
}

- (NSManagedObjectContext *)managedObjectContext{
    return managedObjectStore.mainQueueManagedObjectContext;
}

#pragma mark - Core Data

- (void)getUrlObjectsAtPath:(NSString *)path
                       parameters:(NSDictionary *)params
                          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    //данный метод по сути проксирует обращение к getObjectsAtPath объекта типа RKObjectManager.
    //Название у метода “говорящее” — ждем от него загрузки удаленных объектов

    // Непосредственный вызов метода у объекта objectManager
    [objectManager getObjectsAtPath:[NSString stringWithFormat:@"%@", @"/taxik/api/client/query_cities"]
                         parameters:params
                            success:success
                            failure:failure];
}

- (void) addMappingForEntityForName:(NSString *)nameClass
 andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
        andIdentificationAttributes:(NSArray *)ids {
    //добавление маппинга (соответствия) между сущностью Core Data и удаленным объектом
    
    if (!managedObjectStore)
        return;
    
    RKEntityMapping *objectMapping = [RKEntityMapping mappingForEntityForName:nameClass
                                                         inManagedObjectStore:managedObjectStore];
    // Указываем, какие атрибуты должны маппиться.
    [objectMapping addAttributeMappingsFromDictionary:attributeMappings];
    // Указываем, какие атрибуты являются идентификаторами - это важно для того, чтобы не было дубликатов в локальной базе.
    objectMapping.identificationAttributes = ids;
    
    // Создаем дескриптор ответа, ориентируясь на формат ответов нашего сервера и добавляем его в менеджер.
    RKResponseDescriptor *songResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:objectMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@"cities"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:songResponseDescriptor];
    
}

- (void)configureWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    //работа с CoreData: метод, который конфигурирует объект типа RKManagedObjectStore
    
    if (!managedObjectModel)
        return;
    
    managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    if (!RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error))
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Test.sqlite"];
    if (![managedObjectStore addSQLitePersistentStoreAtPath:path
                                     fromSeedDatabaseAtPath:nil
                                          withConfiguration:nil options:nil error:&error])
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    
    [managedObjectStore createManagedObjectContexts];
    objectManager.managedObjectStore = managedObjectStore;
}


#pragma mark - Singleton Accessor

+ (CitiesRKObjectManager *)manager {
    static CitiesRKObjectManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[CitiesRKObjectManager alloc] init];
    });
    return manager;
}

#pragma mark - NSObject-derived

- (id) init {
    //инициализация HTTP-клиента
    
    self = [super init];
    if (self)
    {
        NSURL *baseURL = [NSURL URLWithString:MAIN_URL];
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
        
    }
    
    return self;
}


@end
