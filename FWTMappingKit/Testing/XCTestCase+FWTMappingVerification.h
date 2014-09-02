//
//  XCTestCase+FWTMappingVerification.h
//  FWTMappingKit
//
//  Created by Jonathan Flintham on 30/08/2014.
//  Copyright (c) 2014 Future Workshops. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>

@interface XCTestCase (FWTMappingVerification)

- (void)verifyPropertyMappingFromDeserializedObject:(NSDictionary *)deserializedObject
                                     toMappedObject:(NSManagedObject *)mappedObject
                                     withMappingKey:(NSString *)mappingKey;

@end
