//
//  NSManagedObject+FWTRestKitMapping.m
//  AEMOI
//
//  Created by Jonathan Flintham on 07/02/2014.
//
//

#import "NSManagedObject+FWTRestKitMapping.h"
#import <RestKit/RestKit.h>

static NSValueTransformer *FWTMappingKitSourceToDestinationKeyValueTransformer = nil;
static NSValueTransformer *FWTMappingKitDestinationToSourceKeyValueTransformer = nil;
static RKValueTransformer *FWTMappingKitDefaultValueTransformer = nil;
static NSMutableDictionary *FWTMappingKitVerificationTransformerDict = nil;

@implementation NSManagedObject (FWTRestKitMapping)

#pragma mark - Value transformers

+ (void)fwt_setSourceToDestinationKeyValueTransformer:(NSValueTransformer *)valueTransformer
{
    @synchronized(self) {
        FWTMappingKitSourceToDestinationKeyValueTransformer = valueTransformer;
    }
}

+ (NSValueTransformer *)fwt_sourceToDestinationKeyValueTransformer
{
    return FWTMappingKitSourceToDestinationKeyValueTransformer;
}

+ (void)fwt_setDestinationToSourceKeyValueTransformer:(NSValueTransformer *)valueTransformer
{
    @synchronized(self) {
        FWTMappingKitDestinationToSourceKeyValueTransformer = valueTransformer;
    }
}

+ (NSValueTransformer *)fwt_destinationToSourceKeyValueTransformer
{
    return FWTMappingKitDestinationToSourceKeyValueTransformer;
}

+ (void)fwt_setDefaultValueTransformers:(NSArray *)valueTransformers
{
    RKCompoundValueTransformer *defaultValueTransformer  = [[RKValueTransformer defaultValueTransformer] copy];
    for (NSInteger i = 0; i < [valueTransformers count]; i++) {
        [defaultValueTransformer insertValueTransformer:valueTransformers[i] atIndex:i];
    }
    
    @synchronized(self) {
        FWTMappingKitDefaultValueTransformer = (RKValueTransformer *)defaultValueTransformer;
    }
}

+ (void)fwt_registerVerificationTransformer:(NSValueTransformer *)valueTransformer forKey:(id<NSCopying>)verificationKey
{
    if (!FWTMappingKitVerificationTransformerDict) {
        @synchronized(self) {
            FWTMappingKitVerificationTransformerDict = [NSMutableDictionary dictionaryWithCapacity:10];
        }
    }
    
    @synchronized(self) {
        FWTMappingKitVerificationTransformerDict[verificationKey] = valueTransformer;
    }
}

#pragma mark - Mapping configuration

+ (NSString *)sourceKeyPathForDestinationKey:(NSString *)destinationKey mappingKey:(NSString *)mappingKey relationshipMappingKey:(NSString **)relationshipMappingKey
{
    NSArray *customMappingConfigurations = [self fwt_customPropertyMappingConfigurationsForMappingKey:mappingKey];
    
    NSString *sourceKeyPath = nil;
    
    // look for a mappingConfiguration for this attribute
    NSUInteger matchingIndex = [customMappingConfigurations indexOfObjectPassingTest:^BOOL(FWTMappingConfiguration *obj, NSUInteger idx, BOOL *stop2) {
        *stop2 = [obj.destinationKey isEqualToString:destinationKey];
        return *stop2;
    }];
    if (customMappingConfigurations && matchingIndex != NSNotFound) {
        FWTMappingConfiguration *mappingConfiguration = customMappingConfigurations[matchingIndex];
        sourceKeyPath = mappingConfiguration.sourceKeyPath;
        if (relationshipMappingKey != NULL) {
            *relationshipMappingKey = mappingConfiguration.relationshipMappingKey;
        }
    }
    
    // look for collectionIndex
    else if ([destinationKey isEqualToString:@"collectionIndex"]) {
        sourceKeyPath = @"@metadata.mapping.collectionIndex";
    }
    
    // look for a default transformer
    else if ([self fwt_destinationToSourceKeyValueTransformer]) {
        NSValueTransformer *valueTransformer = [self fwt_destinationToSourceKeyValueTransformer];
        sourceKeyPath = [valueTransformer transformedValue:destinationKey];
    }
    
    // default to matching keys
    else {
        sourceKeyPath = destinationKey;
    }
    
    return sourceKeyPath;
}

+ (void)configureAttributesForMapping:(RKEntityMapping *)mapping withMappingKey:(NSString *)mappingKey
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
    
    NSDictionary *attributesDict = [entityDescription attributesByName];
    
    NSMutableDictionary *mappings = [NSMutableDictionary dictionaryWithCapacity:[attributesDict count]];
    [attributesDict enumerateKeysAndObjectsUsingBlock:^(id attributeKey, id attributeValue, BOOL *stop) {

        NSString *sourceKeyPath = [self sourceKeyPathForDestinationKey:attributeKey mappingKey:mappingKey relationshipMappingKey:NULL];
        mappings[sourceKeyPath] = attributeKey;
    }];
    
    [mapping addAttributeMappingsFromDictionary:mappings];
}

+ (void)configureRelationshipsForMapping:(RKEntityMapping *)mapping withMappingKey:(NSString *)mappingKey
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                                         inManagedObjectContext:[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
    
    NSDictionary *relationshipsDict = [entityDescription relationshipsByName];
    if ([relationshipsDict count] > 0) {
        
        NSMutableArray *relationshipPropertyMappings = [NSMutableArray arrayWithCapacity:[relationshipsDict count]];
        for (NSString *relationshipName in [relationshipsDict allKeys]) {
            
            NSRelationshipDescription *relationshipDescription = relationshipsDict[relationshipName];
            NSEntityDescription *destinationEntityDescription = relationshipDescription.destinationEntity;
            
            Class destinationEntityClass = NSClassFromString(destinationEntityDescription.managedObjectClassName);
            NSString *relationshipMappingKey = nil;
            
            NSString *sourceKeyPath = [self sourceKeyPathForDestinationKey:relationshipName mappingKey:mappingKey relationshipMappingKey:&relationshipMappingKey];
            
            RKRelationshipMapping *destinationRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:sourceKeyPath toKeyPath:relationshipName withMapping:[destinationEntityClass fwt_entityMappingForKey:relationshipMappingKey]];
            [relationshipPropertyMappings addObject:destinationRelationshipMapping];
        }
        
        [mapping addPropertyMappingsFromArray:relationshipPropertyMappings];
    }
}

+ (void)configureAdditionalInfoForMapping:(RKEntityMapping *)mapping withMappingKey:(NSString *)mappingKey
{
    mapping.valueTransformer = FWTMappingKitDefaultValueTransformer;
}

+ (RKEntityMapping *)fwt_entityMappingForKey:(NSString *)mappingKey
{
    if (!mappingKey) {
        mappingKey = NSStringFromClass(self);
    }
    
    RKEntityMapping *mapping = [RKEntityMapping fwt_cachedEntityMappingForKey:mappingKey];
    
    if (!mapping) {
        
        mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class])
                                      inManagedObjectStore:[[RKObjectManager sharedManager] managedObjectStore]];
        
        [RKEntityMapping fwt_setCachedEntityMapping:mapping forKey:mappingKey];
        
        [self configureAttributesForMapping:mapping withMappingKey:mappingKey];
        [self configureRelationshipsForMapping:mapping withMappingKey:mappingKey];
        [self configureAdditionalInfoForMapping:mapping withMappingKey:mappingKey];
        
        NSString *nestingAttibuteKey = [self fwt_nestingAttributeKey];
        if (nestingAttibuteKey) {
            [mapping fwt_configureForNestingAttributeKey:nestingAttibuteKey];
        }
    }
    
    return mapping;
}

+ (NSString *)fwt_nestingAttributeKey
{
    return nil;
}

+ (NSArray *)fwt_customPropertyMappingConfigurationsForMappingKey:(NSString *)mappingKey
{
    return nil;
}

+ (NSDictionary *)nonDefaultVerificationTypes
{
    return nil;
}

@end
