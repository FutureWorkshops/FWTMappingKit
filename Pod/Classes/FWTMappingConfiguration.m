//
//  FWTMappingConfiguration.m
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 22/08/2014.
//
//

#import "FWTMappingConfiguration.h"

@interface FWTMappingConfiguration ()

@property (nonatomic, strong, readwrite) NSString *sourceKey;
@property (nonatomic, strong, readwrite) NSString *sourceKeyPath;
@property (nonatomic, strong, readwrite) NSString *destinationKey;
@property (nonatomic, strong, readwrite) NSString *relationshipMappingKey;

@end

@implementation FWTMappingConfiguration

- (instancetype)initWithSourceKey:(NSString *)sourceKey mappedToDestinationKey:(NSString *)destinationKey viaSourceKeyPath:(NSString *)sourceKeyPath relationshipMappingKey:(NSString *)relationshipMappingKey
{
    self = [super init];
    if (self) {
        NSAssert([sourceKey length] > 0 && [destinationKey length] > 0, @"Must provide valid sourceKey and destinationKey");
        
        self.sourceKey = sourceKey;
        self.destinationKey = destinationKey;
        self.sourceKeyPath = sourceKeyPath;
        self.relationshipMappingKey = relationshipMappingKey;
    }
    return self;
}

- (instancetype)initWithSourceKey:(NSString *)sourceKey mappedToDestinationKey:(NSString *)destinationKey viaSourceKeyPath:(NSString *)sourceKeyPath
{
    return [self initWithSourceKey:sourceKey mappedToDestinationKey:destinationKey viaSourceKeyPath:sourceKeyPath relationshipMappingKey:nil];
}

- (instancetype)init
{
    return [self initWithSourceKey:nil mappedToDestinationKey:nil viaSourceKeyPath:nil relationshipMappingKey:nil]; // will raise assert
}

- (NSString *)sourceKeyPath
{
    if (self->_sourceKeyPath) {
        return self->_sourceKeyPath;
    }
    else {
        return self.sourceKey; // default to sourceKey
    }
}

// convenience for simple mapping configurations
+ (NSArray *)mappingConfigurationsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *configurations = [NSMutableArray arrayWithCapacity:[dictionary count]];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *sourceKey, NSString *destinationKey, BOOL *stop) {
        FWTMappingConfiguration *configuration = [[FWTMappingConfiguration alloc] initWithSourceKey:sourceKey mappedToDestinationKey:destinationKey viaSourceKeyPath:nil relationshipMappingKey:nil];
        [configurations addObject:configuration];
    }];
    
    return [configurations copy];
}

@end
