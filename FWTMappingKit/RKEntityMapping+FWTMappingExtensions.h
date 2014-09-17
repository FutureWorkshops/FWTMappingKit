//
//  RKEntityMapping+FWTMappingExtensions.h
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 07/02/2014.
//
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "RKEntityMapping.h"

/**
 Extension of `RKEntityMapping` to provide caching of mappings, and convenience for configuring nesting attribute keys.
 */

@interface RKEntityMapping (FWTMappingExtensions)

/// @name Caching

/**
 Cache a particular mapping, keyed with the provided mapping key.
 
 @param entityMapping The mapping to cache.
 @param mappingKey The mapping key by which the mapping can be retrieved.
 
 @warning `mappingKey` cannot be `nil`.
 */
+ (void)fwt_setCachedEntityMapping:(RKEntityMapping *)entityMapping forKey:(NSString *)mappingKey;

/**
 Retrieve a cached mapping associated with the provided mapping Key.
 
 @param mappingKey The mapping key by which the mapping will be retrieved.
 
 @warning `mappingKey` cannot be `nil`.
 */
+ (RKEntityMapping *)fwt_cachedEntityMappingForKey:(NSString *)mappingKey;

/**
 Clear all previously cached entity mappings.
 */
+ (void)fwt_clearCachedEntityMappings;

/// @name Convenience

/**
 Configure the mapping for the given nestingAttributeKey. See `addAttributeMappingFromKeyOfRepresentationToAttribute:` method of `RKObjectMapping` for more information.
 
 @param nestingAttributeKey The key to which the nesting attribute value should be mapped into.
 */
- (void)fwt_configureForNestingAttributeKey:(NSString *)nestingAttributeKey;

@end
