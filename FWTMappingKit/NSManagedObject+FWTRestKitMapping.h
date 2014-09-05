//
//  NSManagedObject+FWTRestKitMapping.h
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 07/02/2014.
//
//

#import <CoreData/CoreData.h>
#import "RKEntityMapping+FWTMappingExtensions.h"
#import "FWTMappingConfiguration.h"

@interface NSManagedObject (FWTRestKitMapping)

// optionally configure default key mapping transformers
+ (void)fwt_setSourceToDestinationKeyValueTransformer:(NSValueTransformer *)valueTransformer;
+ (NSValueTransformer *)fwt_sourceToDestinationKeyValueTransformer;
+ (void)fwt_setDestinationToSourceKeyValueTransformer:(NSValueTransformer *)valueTransformer;
+ (NSValueTransformer *)fwt_destinationToSourceKeyValueTransformer;

// optionally set extra value transformers to default set, i.e. date formatters
+ (void)fwt_setDefaultValueTransformers:(NSArray *)valueTransformers;

// optionally register transformers to be used in unit test property verification
+ (void)fwt_registerVerificationTransformer:(NSValueTransformer *)valueTransformer forKey:(id<NSCopying>)verificationKey;

// override to peform additional customisation of the default mapping, e.g. set identificationAttributes
+ (RKEntityMapping *)fwt_entityMappingForKey:(NSString *)mappingKey NS_REQUIRES_SUPER;

// override to configure the mapping for a nesting attribute key (i.e. using RKEntityMapping method addAttributeMappingFromKeyOfRepresentationToAttribute)
+ (NSString *)fwt_nestingAttributeKey;

// override to provide custom configurations (instances of FWTMappingConfiguration) to aid mapping back and forth between source and destination respresentations
// if a matching configuration is not found, default transformers will be used
+ (NSArray *)fwt_customPropertyMappingConfigurationsForMappingKey:(NSString *)mappingKey;

#pragma mark - Verification

// verify mapping against deserialized source representation - will raise exception for mismatches
- (void)fwt_verifyMappingFromDeserializedObject:(NSDictionary *)deserializedObject
                                  forMappingKey:(NSString *)mappingKey;

// override to provide custom property equivalence checking during verification, e.g. BOOL values can come from a variety of string sources, 'yes', 'y', 'true', '1', etc.
// the default implementation provides some basic checking, i.e. you can call super for properties where custom checking is not required
- (BOOL)fwt_isSourceValue:(id)sourceValue withSourceKeyPath:(NSString *)sourceKey equalToDestinationValue:(id)destinationValue withDestinationKey:(NSString *)destinationKey forMappingKey:(NSString *)mappingKey;

@end
