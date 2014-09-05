//
//  FWTMappingConfiguration.m
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 22/08/2014.
//
//

#import "FWTMappingConfiguration.h"

@interface FWTMappingConfiguration ()

@property (nonatomic, strong, readwrite) NSString *sourceKeyPath;
@property (nonatomic, strong, readwrite) NSString *destinationKey;
@property (nonatomic, strong, readwrite) NSString *relationshipMappingKey;

@end

@implementation FWTMappingConfiguration

- (instancetype)initWithSourceKeyPath:(NSString *)sourceKeyPath mappedToDestinationKey:(NSString *)destinationKey withRelationshipMappingKey:(NSString *)relationshipMappingKey
{
    self = [super init];
    if (self) {
        NSAssert([sourceKeyPath length] > 0, @"Must provide valid sourceKeyPath"); // a nil or empty destinationKey means that this sourceKeyPath will not be mapped, i.e. ignored
        
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
        FWTMappingConfiguration *configuration = [[FWTMappingConfiguration alloc] initWithSourceKeyPath:sourceKeyPath mappedToDestinationKey:destinationKey withRelationshipMappingKey:nil];
        [configurations addObject:configuration];
    }];
    
    return [configurations copy];
}

@end
