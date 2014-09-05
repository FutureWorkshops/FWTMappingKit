//
//  FWTMappingConfiguration.h
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 22/08/2014.
//
//

@interface FWTMappingConfiguration : NSObject

@property (nonatomic, readonly) NSString *sourceKeyPath;
@property (nonatomic, readonly) NSString *destinationKey;
@property (nonatomic, readonly) NSString *relationshipMappingKey;

// allows configuration of a mapping where the sourceKey can redirect to a different sourceKeyPath before mapping to destinationKey
- (instancetype)initWithSourceKeyPath:(NSString *)sourceKeyPath mappedToDestinationKey:(NSString *)destinationKey;

// additionally allows for relationships to be assigned to alternative mappings
- (instancetype)initWithSourceKeyPath:(NSString *)sourceKeyPath mappedToDestinationKey:(NSString *)destinationKey withRelationshipMappingKey:(NSString *)relationshipMappingKey;

+ (NSArray *)mappingConfigurationsFromDictionary:(NSDictionary *)dictionary;

@end
