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

@interface RKEntityMapping (FWTMappingExtensions)

+ (void)fwt_setCachedEntityMapping:(RKEntityMapping *)entityMapping forKey:(NSString *)mappingKey;
+ (RKEntityMapping *)fwt_cachedEntityMappingForKey:(NSString *)mappingKey;

+ (void)fwt_clearCachedEntityMappings;

- (void)fwt_configureForNestingAttributeKey:(NSString *)nestingAttributeKey;

@end
