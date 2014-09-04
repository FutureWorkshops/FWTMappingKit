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

static NSString * const FWTMappingKitNestingAttributeVerificationKey = @"FWTNestingAttributeVerificationKey";

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

+ (void)configureAttributesForMapping:(RKEntityMapping *)mapping forMappingKey:(NSString *)mappingKey
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

+ (void)configureRelationshipsForMapping:(RKEntityMapping *)mapping forMappingKey:(NSString *)mappingKey
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

+ (void)configureAdditionalInfoForMapping:(RKEntityMapping *)mapping forMappingKey:(NSString *)mappingKey
{
    mapping.valueTransformer = FWTMappingKitDefaultValueTransformer;
}

#pragma mark - Overrides

+ (RKEntityMapping *)fwt_entityMappingForKey:(NSString *)mappingKey
{
    if (!mappingKey) {
        mappingKey = NSStringFromClass(self);
    }
    
    RKEntityMapping *mapping = [RKEntityMapping fwt_cachedEntityMappingForKey:mappingKey];
    
    if (!mapping) {
        
        RKObjectManager *manager = [RKObjectManager sharedManager];
        RKManagedObjectStore *store = [manager managedObjectStore];
        
        mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class])
                                      inManagedObjectStore:store];
        
        [RKEntityMapping fwt_setCachedEntityMapping:mapping forKey:mappingKey];
        
        [self configureAttributesForMapping:mapping forMappingKey:mappingKey];
        [self configureRelationshipsForMapping:mapping forMappingKey:mappingKey];
        [self configureAdditionalInfoForMapping:mapping forMappingKey:mappingKey];
        
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

#pragma mark - Verification

- (void)verifyMappingFromSource:(NSDictionary *)deserializedObject
                  forMappingKey:(NSString *)mappingKey
{
    if (!deserializedObject) {
        [NSException raise:NSInternalInconsistencyException format:@"deserializedObject should not be nil"];
    }

    // why was this here again?
//    if ([deserializedObject isEqual:[NSNull null]]) {
//        return;
//    }
    
    NSString *nestingAttributeKey = [[self class] fwt_nestingAttributeKey];
    NSArray *customMappingConfigurations = [[self class] fwt_customPropertyMappingConfigurationsForMappingKey:mappingKey];
    
    for (NSString *sourceKey in [deserializedObject allKeys]) {
        
        NSString *sourceKeyPath = nil;
        NSString *destinationKey = nil;
        NSString *relationshipMappingKey = mappingKey;
        
        if ([sourceKey isEqualToString:FWTMappingKitNestingAttributeVerificationKey]) {
            
            if (!nestingAttributeKey)
                continue; // we only care about this property if the mapping is configured for it
            
            sourceKeyPath = sourceKey;
            destinationKey = nestingAttributeKey;
        }
        else {
            // look for a mappingConfiguration for this sourceKey
            NSUInteger matchingIndex = [customMappingConfigurations indexOfObjectPassingTest:^BOOL(FWTMappingConfiguration *obj, NSUInteger idx, BOOL *stop2) {
                *stop2 = [obj.sourceKey isEqualToString:sourceKey];
                return *stop2;
            }];
            if (customMappingConfigurations && matchingIndex != NSNotFound) {
                FWTMappingConfiguration *mappingConfiguration = customMappingConfigurations[matchingIndex];
                sourceKeyPath = mappingConfiguration.sourceKeyPath;
                destinationKey = mappingConfiguration.destinationKey;
                relationshipMappingKey = mappingConfiguration.relationshipMappingKey;
            }
            
            // look for a default transformer
            else if ([[self class] fwt_sourceToDestinationKeyValueTransformer]) {
                NSValueTransformer *valueTransformer = [[self class] fwt_sourceToDestinationKeyValueTransformer];
                destinationKey = [valueTransformer transformedValue:sourceKey];
                sourceKeyPath = sourceKey;
            }
        }
        
        if (![self respondsToSelector:NSSelectorFromString(destinationKey)]) {
            NSLog(@"Skipping %@ - destination property %@ not found in mappedObject of class %@", sourceKeyPath, destinationKey, NSStringFromClass([self class]));
            continue;
        }
        
        id sourceValue = [deserializedObject valueForKeyPath:sourceKeyPath];
        id destinationValue = [self valueForKey:destinationKey];
        
        // verify null to-many relationships
        if ([sourceValue isEqual:[NSNull null]] && [destinationValue isKindOfClass:[NSSet class]]) {
            if ([destinationValue count] > 0) {
                [NSException raise:NSInternalInconsistencyException format:@"%@ -> %@ : Should be no items in mapped set '%@' because sourceValue is null", sourceKeyPath, destinationKey, destinationValue];
            }
        }
        
        // verify property (or nil property or nil to-one relationship)
        else if ([sourceValue isKindOfClass:[NSString class]] || [sourceValue isEqual:[NSNull null]]) {
            
            if (!destinationValue) {
                if (sourceValue != [NSNull null]) {
                    [NSException raise:NSInternalInconsistencyException format:@"Failed to transform '%@' with sourceKey '%@' for destinationKey '%@'", sourceValue, sourceKey, destinationKey];
                }
                continue;
            }
            
            if (![self isSourceValue:sourceValue withSourceKeyPath:sourceKeyPath equalToDestinationValue:destinationValue withDestinationKey:destinationKey forMappingKey:mappingKey]) {
                [NSException raise:NSInternalInconsistencyException format:@"Mapped value not equal for sourceKey '%@' mapped to destinationKey '%@' on class %@", sourceKey, destinationKey, NSStringFromClass([self class])];
            }
        }
        
        // verify object
        else if ([sourceValue isKindOfClass:[NSDictionary class]]) {
            
            // check for objects mapped into collections
            if ([destinationValue isKindOfClass:[NSSet class]]) {
                
                if ([destinationValue count] == 0) {
                    [NSException raise:NSInternalInconsistencyException format:@"There should be at least one object mapped from collection %@ to relationship %@", sourceValue, destinationValue];
                }
                
                NSArray *array = nil;
                
                // check for nesting attribute key collections
                id sampleObject = [destinationValue anyObject];
                if ([[sampleObject class] fwt_nestingAttributeKey]) {
                    
                    array = [NSMutableArray arrayWithCapacity:[sourceValue count]];
                    for (NSString *key in [sourceValue allKeys])
                    {
                        NSMutableDictionary *value = sourceValue[key];
                        value[FWTMappingKitNestingAttributeVerificationKey] = key;
                        [(NSMutableArray *)array addObject:value];
                    }
                }
                else {
                    array = @[sourceValue];
                }
                
                if (![array isKindOfClass:[NSArray class]]) {
                    [NSException raise:NSInternalInconsistencyException format:@"Object mapped from '%@' to '%@' should be an array", sourceKeyPath, destinationKey];
                }
                
                [self _verifyPropertyMappingFromArray:array toMappedSet:destinationValue forMappingKey:relationshipMappingKey];
                
                continue;
            }
            
            [destinationValue verifyMappingFromSource:sourceValue forMappingKey:relationshipMappingKey];
        }
        
        // verify array
        else if ([sourceValue isKindOfClass:[NSArray class]]) {
            
            [self _verifyPropertyMappingFromArray:sourceValue toMappedSet:destinationValue forMappingKey:relationshipMappingKey];
        }
    }
}

- (void)_verifyPropertyMappingFromArray:(NSArray *)deserializedArray
                            toMappedSet:(NSSet *)mappedSet
                          forMappingKey:(NSString *)mappingKey;
{
    if ([deserializedArray count] != [mappedSet count]) {
        [NSException raise:NSInternalInconsistencyException format:@"%@ and %@ should contain the same number of items", deserializedArray, mappedSet];
    }
    
    SEL collectionIndexSelector = NSSelectorFromString(@"collectionIndex");
    if (![[mappedSet anyObject] respondsToSelector:collectionIndexSelector]) {
        [NSException raise:NSInternalInconsistencyException format:@"Mapped collection objects of class %@ must implement collectionIndex property", NSStringFromClass([[mappedSet anyObject] class])];
        return;
    }
    
    NSArray *destinationArray = [mappedSet sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"collectionIndex" ascending:YES]]];
    
    for (NSDictionary *sourceObject in deserializedArray) {
        
        NSUInteger index = [deserializedArray indexOfObject:sourceObject];
        
        id destinationObject = destinationArray[index];
        
        [destinationObject verifyMappingFromSource:sourceObject forMappingKey:mappingKey];
    }
}

- (BOOL)isSourceValue:(id)sourceValue withSourceKeyPath:(NSString *)sourceKey equalToDestinationValue:(id)destinationValue withDestinationKey:(NSString *)destinationKey forMappingKey:(NSString *)mappingKey
{
    // default implementation
    
    NSEntityDescription *entityDescription = self.entity;
    NSAttributeDescription *attributeDescription = [entityDescription attributesByName][destinationKey];
    
    switch (attributeDescription.attributeType) {
            
        case NSStringAttributeType:
        {
            return [destinationValue isEqualToString:sourceValue];
        }
            
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
        {
             return [[destinationValue stringValue] isEqualToString:sourceValue];
        }
            
        case NSBooleanAttributeType:
        {
            static NSArray *noValues = nil;
            static NSArray *yesValues = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                yesValues = @[@"true", @"t", @"yes", @"y", @"1"];
                noValues = @[@"false", @"f", @"no", @"n", @"0"];
            });
            
            if ([destinationValue boolValue]) {
                return [yesValues containsObject:[sourceValue lowercaseString]];
            }
            else {
                return [noValues containsObject:[sourceValue lowercaseString]];
            }
            
            return NO;
        }
            
        case NSDateAttributeType:
        default:
        {
            RKEntityMapping *mapping = [[self class] fwt_entityMappingForKey:mappingKey];
            
            id transformedDestinationValue = nil;
            NSError *error = nil;
            [mapping.valueTransformer transformValue:destinationValue toValue:&transformedDestinationValue ofClass:[sourceValue class] error:&error];
            if (error) {
                [NSException raise:NSInternalInconsistencyException format:@"Tranformation from destinationValue '%@' to sourceValue '%@' failed: %@", destinationValue, sourceValue, [error localizedDescription]];
            }
            
            BOOL areEqual = [transformedDestinationValue isEqual:sourceValue];
            if (!areEqual) {
                [NSException raise:NSInternalInconsistencyException format:@"(%@: %@ -> %@) sourceValue '%@' not equal to transformed destinationValue '%@'", NSStringFromClass([self class]), sourceKey, destinationKey, sourceValue, transformedDestinationValue];
            }
            
            return areEqual;
        }
    }
}

@end
