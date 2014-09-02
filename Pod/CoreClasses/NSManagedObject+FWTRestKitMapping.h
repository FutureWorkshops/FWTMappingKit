//
//  NSManagedObject+FWTRestKitMapping.h
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 07/02/2014.
//
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <SystemConfiguration/SystemConfiguration.h>
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

// override to provide custom configurations (instances of MOIMappingConfiguration) to aid mapping back and forth between source and destination respresentations
// if a matching configuration is not found, default transformers will be used
+ (NSArray *)fwt_customPropertyMappingConfigurationsForMappingKey:(NSString *)mappingKey;

@end
