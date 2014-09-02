//
//  XCTestCase+FWTMappingVerification.m
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 30/08/2014.
//  Copyright (c) 2014 Future Workshops. All rights reserved.
//

#import "XCTestCase+FWTMappingVerification.h"
#import "NSManagedObject+FWTRestKitMapping.h"

static NSString * const FWTMappingKitNestingAttributeVerificationKey = @"MOINestingAttributeVerificationKey";

@implementation XCTestCase (FWTMappingVerification)

- (void)verifyPropertyMappingFromDeserializedObject:(NSDictionary *)deserializedObject
                                     toMappedObject:(NSManagedObject *)mappedObject
                                     withMappingKey:(NSString *)mappingKey
{
    XCTAssertNotNil(deserializedObject, @"Should not be nil");
    XCTAssertNotNil(mappedObject, @"Should not be nil");
    
    if (!deserializedObject || !mappedObject) {
        // break here to debug
    }
    
    if ([deserializedObject isEqual:[NSNull null]]) {
        return;
    }
    
    RKEntityMapping *mapping = [[mappedObject class] fwt_entityMappingForKey:mappingKey];
    NSString *nestingAttributeKey = [[mappedObject class] fwt_nestingAttributeKey];
    NSArray *customMappingConfigurations = [[mappedObject class] fwt_customPropertyMappingConfigurationsForMappingKey:mappingKey];
    
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
            else if ([[mappedObject class] fwt_sourceToDestinationKeyValueTransformer]) {
                NSValueTransformer *valueTransformer = [[mappedObject class] fwt_sourceToDestinationKeyValueTransformer];
                destinationKey = [valueTransformer transformedValue:sourceKey];
                sourceKeyPath = sourceKey;
            }
        }
        
        if (![mappedObject respondsToSelector:NSSelectorFromString(destinationKey)]) {
            NSLog(@"Skipping %@ - destination property %@ not found in mappedObject of class %@", sourceKeyPath, destinationKey, NSStringFromClass([mappedObject class]));
            continue;
        }
        
        id sourceValue = [deserializedObject valueForKeyPath:sourceKeyPath];
        id destinationValue = [mappedObject valueForKey:destinationKey];
        
        // verify null to-many relationships
        if ([destinationValue isKindOfClass:[NSSet class]] && [sourceValue isEqual:[NSNull null]]) {
            XCTAssertTrue([destinationValue count] == 0, @"Should be no items in mapped set");
        }
        
        // verify property (or nil property or nil to-one relationship)
        else if ([sourceValue isKindOfClass:[NSString class]] || [sourceValue isEqual:[NSNull null]]) {
            
            if (!destinationValue) {
                XCTAssertTrue(sourceValue == [NSNull null], @"Failed to transform '%@' with sourceKey '%@' for destinationKey '%@'", sourceValue, sourceKey, destinationKey);
                continue;
            }
            
            id transformedSourceValue = nil;
            
            if ([sourceValue isKindOfClass:[NSString class]] && [destinationValue isKindOfClass:[NSString class]]) {
                transformedSourceValue = sourceValue;
            }
            else {
                NSError *error = nil;
                [mapping.valueTransformer transformValue:sourceValue toValue:&transformedSourceValue ofClass:[destinationValue class] error:&error];
                if (error) {
                    XCTFail(@"Tranformation from '%@' to '%@' failed: %@", sourceValue, destinationValue, [error localizedDescription]);
                }
            }
            
            XCTAssertEqualObjects(transformedSourceValue, destinationValue, @"for '%@' mapped to '%@' on class %@", sourceKey, destinationKey, NSStringFromClass([mappedObject class]));
        }
        
        // verify object
        else if ([sourceValue isKindOfClass:[NSDictionary class]]) {
            
            // check for objects mapped into collections
            if ([destinationValue isKindOfClass:[NSSet class]]) {
                
                XCTAssertTrue([destinationValue count] > 0, @"There should be at least one object mapped from collection %@ to relationship %@", sourceValue, destinationValue);
                
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
                
                XCTAssertTrue([array isKindOfClass:[NSArray class]], @"Object should be an array");
                
                [self _verifyPropertyMappingFromArray:array toMappedSet:destinationValue withMappingKey:relationshipMappingKey];
                
                continue;
            }
            
            [self verifyPropertyMappingFromDeserializedObject:sourceValue toMappedObject:destinationValue withMappingKey:relationshipMappingKey];
        }
        
        // verify array
        else if ([sourceValue isKindOfClass:[NSArray class]]) {
            
            [self _verifyPropertyMappingFromArray:sourceValue toMappedSet:destinationValue withMappingKey:relationshipMappingKey];
        }
    }
}

- (void)_verifyPropertyMappingFromArray:(NSArray *)deserializedArray
                            toMappedSet:(NSSet *)mappedSet
                         withMappingKey:(NSString *)mappingKey;
{
    XCTAssertTrue([deserializedArray count] == [mappedSet count], @"Should be the same number of items");
    
    if ([deserializedArray count] != [mappedSet count]) {
        // break here to debug
    }
    
    SEL collectionIndexSelector = NSSelectorFromString(@"collectionIndex");
    if (![[mappedSet anyObject] respondsToSelector:collectionIndexSelector]) {
        XCTFail(@"Mapped collection objects of class %@ must implement collectionIndex property", NSStringFromClass([[mappedSet anyObject] class]));
        return;
    }
    
    NSArray *destinationArray = [mappedSet sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"collectionIndex" ascending:YES]]];
    
    for (NSDictionary *sourceObject in deserializedArray) {
        
        NSUInteger index = [deserializedArray indexOfObject:sourceObject];
        
        id destinationObject = destinationArray[index];
        
        [self verifyPropertyMappingFromDeserializedObject:sourceObject toMappedObject:destinationObject withMappingKey:mappingKey];
    }
}

@end
