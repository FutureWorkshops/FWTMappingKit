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

typedef NS_ENUM(NSInteger, MOIPropertyVerifcationType) {
    
    MOIPropertyVerifcationTypeIgnore = -1,
    MOIPropertyVerifcationTypeDefaultInference,
    MOIPropertyVerifcationTypeString, // default for strings
    MOIPropertyVerifcationTypeNumber, // default for numbers
    MOIPropertyVerifcationTypeBoolTrueFalse, // default for bools
    MOIPropertyVerifcationTypeBoolYN,
    MOIPropertyVerifcationTypeBoolYesNo,
    MOIPropertyVerifcationTypeDateGregorian, // default for dates
    MOIPropertyVerifcationTypeDateHijri,
    MOIPropertyVerifcationTypeDateHijriCondensed,
};

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

// aid for unit testing
+ (NSDictionary *)nonDefaultVerificationTypes; // determines the type conversion from the mapped value back to a string for comparison with the JSON property

@end
