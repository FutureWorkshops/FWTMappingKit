//
//  RKEntityMapping+FWTMappingExtensions.m
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 07/02/2014.
//
//

#import "RKEntityMapping+FWTMappingExtensions.h"
#import <RestKit/RestKit.h>

static NSMutableDictionary *FWTMappingKitCachedEntityMappingsDict = nil; // used to cache entity mappings for the life of the application in memory

@implementation RKEntityMapping (FWTMappingExtensions)

+ (void)fwt_setCachedEntityMapping:(RKEntityMapping *)entityMapping forKey:(NSString *)mappingKey
{
    NSAssert(mappingKey != nil, @"key should not be nil");
    
    if (!FWTMappingKitCachedEntityMappingsDict) {
        @synchronized(self) {
            FWTMappingKitCachedEntityMappingsDict = [NSMutableDictionary dictionaryWithCapacity:100];
        }
    }
    
    @synchronized(self) {
        FWTMappingKitCachedEntityMappingsDict[mappingKey] = entityMapping;
    }
}

+ (RKEntityMapping *)fwt_cachedEntityMappingForKey:(NSString *)mappingKey
{
    return FWTMappingKitCachedEntityMappingsDict[mappingKey];
}

+ (void)fwt_clearCachedEntityMappings
{
    @synchronized(self) {
        FWTMappingKitCachedEntityMappingsDict = nil;
    }
}

- (void)fwt_configureForNestingAttributeKey:(NSString *)nestingAttributeKey
{
    NSArray *attributeMappings = [self.attributeMappings copy];
    for (RKAttributeMapping *attributeMapping in attributeMappings) {
        
        // remove the attributeMapping from the entityMapping
        [self removePropertyMapping:attributeMapping];
        
        // if nesting attribute, add it back as such
        if ([attributeMapping.destinationKeyPath isEqualToString:nestingAttributeKey]) {
            [self addAttributeMappingFromKeyOfRepresentationToAttribute:attributeMapping.destinationKeyPath];
        }
        
        // if metadata mapping, add it back in
        else if ([attributeMapping.sourceKeyPath rangeOfString:@"@metadata"].location != NSNotFound) {
            [self addPropertyMapping:attributeMapping];
        }
        
        // if not the nesting attribute, add modified version back in
        else {
            [self addAttributeMappingsFromDictionary:
                @{[NSString stringWithFormat:@"(%@).%@", nestingAttributeKey, attributeMapping.sourceKeyPath] : attributeMapping.destinationKeyPath}];
        }
    }
}

@end
