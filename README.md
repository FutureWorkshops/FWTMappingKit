# FWTMappingKit

[![CI Status](http://img.shields.io/travis/Jonathan Flintham/FWTMappingKit.svg?style=flat)](https://travis-ci.org/Jonathan Flintham/FWTMappingKit)
[![Version](https://img.shields.io/cocoapods/v/FWTMappingKit.svg?style=flat)](http://cocoadocs.org/docsets/FWTMappingKit)
[![License](https://img.shields.io/cocoapods/l/FWTMappingKit.svg?style=flat)](http://cocoadocs.org/docsets/FWTMappingKit)
[![Platform](https://img.shields.io/cocoapods/p/FWTMappingKit.svg?style=flat)](http://cocoadocs.org/docsets/FWTMappingKit)

## Overview

FWTMappingKit is a suite of extensions and supporting classes that can produce RKEntityMappings for NSManagedObjects by reflecting against their associated NSEntityDescription, hopefully avoiding the need to specify these mappings explicitely.
                       
    The idea is that you'd use the source representation (e.g. JSON or XML) to inform the construction of your CoreData model, i.e. mirroring attribute and relationship names, mirroring relationship structures, etc.
                       
    Chances are your source representation is not well structured, or is not amenable to being mirrored onto a CoreData model. In this case FWTMappingKit provides additional configuration functionality, such as general property key transformations, and direct specification of mappings for individual properties.
                       
    WARNING: FWTMappingKit works best for large models and fairly consistent source representations, and may not be suitable for all mapping requirements. For small models it may be more conventient just to configure the mappings manually yourself.

## Requirements

## Installation

FWTMappingKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "FWTMappingKit"

## Author

Jonathan Flintham, jonathan@futureworkshops.com

## License

FWTMappingKit is available under the MIT license. See the LICENSE file for more info.

