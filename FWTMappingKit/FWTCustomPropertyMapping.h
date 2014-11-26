//
//  FWTCustomPropertyMapping.h
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 22/08/2014.
//
//

/**
 An instance of `FWTCustomPropertyMapping` specifies a custom mapping from a single `sourceKeyPath` on a source object to a single `destinationKey` on a destination object. Additionally, it is possible to specify a custom `relationshipMappingKey`, which will subsequently be passed to a related NSManagedObject subclass in order that it can provide a differentiated mapping for varying relationship contexts.
 
 Arrays of `FWTCustomPropertyMapping` objects are intended to be returned by overridden implmentations of `fwt_customPropertyMappingsForMappingKey:` in `NSManagedObject+FWTRestKitMapping`.
 */

@interface FWTCustomPropertyMapping : NSObject

/// @name Properties

/**
 The keyPath from which the source value will be accessed.
 */
@property (nonatomic, readonly) NSString *sourceKeyPath;

/**
 The keyPath from which the transformed value will be set.
 */
@property (nonatomic, readonly) NSString *destinationKey;

/**
 An optional mappingKey which will determine the mapping configuration of objects mapped to the relationship specified by `destinationKey`.
 */
@property (nonatomic, readonly) NSString *relationshipMappingKey;

/// @name Initialisation

/**
 Allows custom configuration of a property mapping.
 
 @param sourceKeyPath The keyPath on the source object from which a value will be retrieved, transformed, and then mapped to the destination object.
 @param destinationKey The key on the destination object to which the transformed value from the source object will be mapped. Optionally provide `nil` or empty to explicitely ignore `sourceKeyPath` during the mapping process, i.e. if you do not want the property to be mapped automatically via entity reflection.
 
 @return The newly initialised `FWTCustomPropertyMapping` object.
 */
- (instancetype)initWithSourceKeyPath:(NSString *)sourceKeyPath mappedToDestinationKey:(NSString *)destinationKey;

/**
 Like `initWithSourceKeyPath:mappedToDestinationKey:`, but optionally allows for relationship mappings to be assigned to alternative mappings differentiated with a mappingKey. For example, a Person entity might need a different mapping configuration when it refers to an employer than to an employee.
 
 @param sourceKeyPath The keyPath on the source object from which a value will be retrieved, transformed, and then mapped to the destination object.
 @param destinationKey The key on the destination object to which the transformed value from the source object will be mapped. Optionally provide `nil` or empty to explicitely ignore the `sourceKeyPath` during the mapping process, i.e. if you do not want the property to be mapped automatically via entity reflection.
 @param relationshipMappingKey The mappingKey that differentiate the mapping configuration for the relationship.
 
 @return The newly initialised `FWTCustomPropertyMapping` object.
 
 @warning `destinationKey` should refer to a relationship on the destination object
 */
- (instancetype)initWithSourceKeyPath:(NSString *)sourceKeyPath mappedToDestinationKey:(NSString *)destinationKey withRelationshipMappingKey:(NSString *)relationshipMappingKey;

/**
 Convenience for creating a batch of simple FWTCustomPropertyMapping instances. `initWithSourceKeyPath:mappedToDestinationKey:` is called for each `sourceKeyPath`:`destinationKey` pair provided in `dictionary`, and the array of resulting configurations is returned.
 
 When it is necessary to specify a custom mappingKey for objects mapped to a relationship, use `initWithSourceKeyPath:mappedToDestinationKey:relationshipMappingKey:` instead.
 
 @param dictionary Dictionary where keys are `sourceKeyPath`s and values are corresponding `destinationKey`s.
 
 @return An array of instances of FWTMappingConfiguraton.
*/
+ (NSArray *)mappingConfigurationsFromDictionary:(NSDictionary *)dictionary;

@end
