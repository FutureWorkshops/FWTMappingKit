//
//  NSManagedObject+FWTRestKitMapping.h
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 07/02/2014.
//
//

#import <CoreData/CoreData.h>
#import "RKEntityMapping+FWTMappingExtensions.h"
#import "FWTCustomPropertyMapping.h"

/**
 `NSManagedObject+FWTRestKitMapping` is an extension of `NSManagedObject` designed to produce `RKEntityMapping`s by reflecting on the object's `NSEntityDescription`.
 
 The key method for acquiring an `RKEntityMapping` is `fwt_entityMappingForMappingKey:`, and various other methods provide additional options for customisation of the mapping.
 
 Mapping keys provide a method of differentiating mapping customisation for different contexts, e.g. different network responses can sometimes return equivalent objects, but with variations in the keys meant to represent otherwise equal properties. For such cases you can provide different mapping keys to `fwt_entityMappingForMappingKey:`, and then test for these in your overridden implementation of `fwt_customPropertyMappingsForMappingKey:` in order to return different property mappings.
 */

@interface NSManagedObject (FWTRestKitMapping)

/// @name Default key transformers

/**
 Set the default `NSValueTransformer` used in converting sourceKeys to destinationKeys. If this is set to `nil` (the default), the transformed destinationKey will be equal to the sourceKey.
 
 This is used in `fwt_verifyMappingFromDeserializedObject:forMappingKey:` to determine which property on the destination object should be verified against a particular source object property.
 
 @param valueTransformer The `NSValueTransformer` to set.
 */
+ (void)fwt_setSourceToDestinationKeyValueTransformer:(NSValueTransformer *)valueTransformer;

/**
 @return The current default transformer for generating destinationKeys from sourceKeys if there is no corresponding `FWTCustomPropertyMapping`.
 */
+ (NSValueTransformer *)fwt_sourceToDestinationKeyValueTransformer;

/**
 Set the default `NSValueTransformer` used in converting destinationKeys to sourceKeys. If this is set to `nil` (the default), the transformed sourceKey will be equal to the destinationKey.
 
 This is primarily used to generate a sourceKey by reflecting on the destination entity's `NSEntityDescription`.
 
  @param valueTransformer The `NSValueTransformer` to set.
 */
+ (void)fwt_setDestinationToSourceKeyValueTransformer:(NSValueTransformer *)valueTransformer;

/**
 @return The current default transformer for generating sourceKeys from destinationKeys if there is no corresponding `FWTCustomPropertyMapping`.
 */
+ (NSValueTransformer *)fwt_destinationToSourceKeyValueTransformer;

/// @name Default value transformers

/**
 Optionally add some additional `RKValueTransformer`s to the default set, i.e. use this to add some custom `NSDateFormatter`s. These will be added to every `RKEntityMapping`.
 
 @param valueTransformers The `RKValueTransformer`s to add.
 */
+ (void)fwt_setDefaultValueTransformers:(NSArray *)valueTransformers;

/// @name Mapping configuration

/**
 Optionally override this to perform additional customisation of the RKEntityMapping for this object, e.g. set identificationAttributes or establish relationships via connections. The mapping should be obtained by first calling super, and then additional configuration can be carried out.
 
 @param mappingKey Mapping keys provide context for the current mapping, allowing the mapping to be configured differently for different responses, if required.
 
 @return The RKEntityMapping after additional configuration has been performed.
 */
+ (RKEntityMapping *)fwt_entityMappingForMappingKey:(NSString *)mappingKey;

/**
 Optionally override this to configure the mapping for a nesting attribute key (i.e. using RKEntityMapping method `addAttributeMappingFromKeyOfRepresentationToAttribute:`).
 
 @return The key to which the nesting attribute value should be mapped into.
 */
+ (NSString *)fwt_nestingAttributeKey;

/**
 Optionally override this to perform further configuration of the mapping, e.g. to set identificationAttributes.
 
 @param mappingKey Mapping keys provide context for the current mapping, allowing the mapping to be configured differently for different responses, if required.
 */
+ (void)fwt_configureAdditionalInfoForMapping:(RKEntityMapping *)mapping forMappingKey:(NSString *)mappingKey NS_REQUIRES_SUPER;

/**
 Optionally override this to provide custom property mappings (instances of `FWTCustomPropertyMapping`) to aid mapping back and forth between source and destination respresentations.
 
 If a matching `FWTCustomPropertyMapping` is not specified, default `NSValueTransformer`s will be used.
 
 @param mappingKey Mapping keys provide context for the current mapping, allowing the RKEntityMapping to be configured differently for different responses, if required.
 
 @return An array of `FWTCustomPropertyMapping` objects.
 
 @see -fwt_sourceToDestinationKeyValueTransformer
 @see -fwt_destinationToSourceKeyValueTransformer
 */
+ (NSArray *)fwt_customPropertyMappingsForMappingKey:(NSString *)mappingKey;

/// @name Property mapping verification

/**
 Verify mapping against deserialized source representation - will raise exceptions for mismatches. Intended to be used in unit tests.
 
 @param deserializedObject The deserialized source representation to verify.
 @param mappingKey Optional mapping key to determine the mapping context.
 
 @warning `deserializedObject` cannot be `nil`.
 */
- (void)fwt_verifyMappingFromDeserializedObject:(NSDictionary *)deserializedObject
                                  forMappingKey:(NSString *)mappingKey;

/**
 Verify mappings for a deserialized source collection mapped to a one-to-many relationship.
 
 @param deserializedArray The deserialized source array to verify.
 @param mappedSet The set of objects to verify against.
 @param mappingKey Optional mapping key to determine the mapping context.
 
 @warning The mapped objects must have implemented the collectionIndex attribute in order to match them correctly back to the source collection.
 */
+ (void)fwt_verifyMappingFromArray:(NSArray *)deserializedArray
                       toMappedSet:(NSSet *)mappedSet
                     forMappingKey:(NSString *)mappingKey;

/**
 Optionally override to provide custom property equivalence checking during verification, e.g. BOOL values can come from a variety of string sources, 'yes', 'y', 'true', '1', etc.
 
 The default implementation provides some basic checking, i.e. you can call super for properties where custom checking is not required
 
 @param sourceValue The source value to verify.
 @param sourceKeyPath The corresponding sourceKeyPath.
 @param destinationValue The destination value to verify against.
 @param destinationKey The corresponding destinationKey.
 @param mappingKey Optional mapping key to determine the mapping context.
 
 @return YES if `sourceValue` and `destinationValue` are determined to be equivalent, NO otherwise.
 */
- (BOOL)fwt_isSourceValue:(id)sourceValue
        withSourceKeyPath:(NSString *)sourceKeyPath
  equalToDestinationValue:(id)destinationValue
       withDestinationKey:(NSString *)destinationKey
            forMappingKey:(NSString *)mappingKey;

@end
