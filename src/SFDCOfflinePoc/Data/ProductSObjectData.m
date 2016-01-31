//
//  ProductSObjectData.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "ProductSObjectData.h"
#import "ProductSObjectDataSpec.h"
#import "SObjectData+Internal.h"
#import <SmartSync/SFSmartSyncConstants.h>

@implementation ProductSObjectData

+ (SObjectDataSpec *)dataSpec {
    static ProductSObjectDataSpec *sDataSpec = nil;
    if (sDataSpec == nil) {
        sDataSpec = [[ProductSObjectDataSpec alloc] init];
    }
    return sDataSpec;
}

#pragma mark - Property getters / setters

- (NSString *)name {
    return [self nonNullFieldValue:kProductNameField];
}

- (void)setName:(NSString *)name {
    [self updateSoupForFieldName:kProductNameField fieldValue:name];
}

- (NSString *)productDescription {
    return [self nonNullFieldValue:kProductDescriptionField];
}

- (void)setProductDescription:(NSString *)description {
    [self updateSoupForFieldName:kProductDescriptionField fieldValue:description];
}

- (NSString *)sku {
    return [self nonNullFieldValue:kProductSKUField];
}

- (void)setSku:(NSString *)sku {
    [self updateSoupForFieldName:kProductSKUField fieldValue:sku];
}

@end
