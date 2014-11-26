//
//  FWTCustomPropertyMapping.m
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 22/08/2014.
//
//

#import "FWTCustomPropertyMapping.h"

@interface FWTCustomPropertyMapping ()

@property (nonatomic, strong, readwrite) NSString *sourceKeyPath;
@property (nonatomic, strong, readwrite) NSString *destinationKey;
@property (nonatomic, strong, readwrite) NSString *relationshipMappingKey;

@end

@implementation FWTCustomPropertyMapping

- (instancetype)initWithSourceKeyPath:(NSString *)sourceKeyPath mappedToDestinationKey:(NSString *)destinationKey withRelationshipMappingKey:(NSString *)relationshipMappingKey
{
    self = [super init];
    if (self) {
        self.sourceKeyPath = sourceKeyPath;
        self.destinationKey = destinationKey;
        self.relationshipMappingKey = relationshipMappingKey;
    }
    return self;
}

- (instancetype)initWithSourceKeyPath:(NSString *)sourceKeyPath mappedToDestinationKey:(NSString *)destinationKey
{
    return [self initWithSourceKeyPath:sourceKeyPath mappedToDestinationKey:destinationKey withRelationshipMappingKey:nil];
}

- (instancetype)init
{
    return [self initWithSourceKeyPath:nil mappedToDestinationKey:nil]; // will raise assert
}

// convenience for simple mapping configurations
+ (NSArray *)mappingConfigurationsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *configurations = [NSMutableArray arrayWithCapacity:[dictionary count]];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *sourceKeyPath, NSString *destinationKey, BOOL *stop) {
        FWTCustomPropertyMapping *configuration = [[FWTCustomPropertyMapping alloc] initWithSourceKeyPath:sourceKeyPath mappedToDestinationKey:destinationKey withRelationshipMappingKey:nil];
        [configurations addObject:configuration];
    }];
    
    return [configurations copy];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: sourceKeyPath: '%@', destinationKey: '%@', relationshipMappingKey: '%@'", [super description], self.sourceKeyPath, self.destinationKey, self.relationshipMappingKey];
}

@end
