//
//  ProductSObjectDataSpec.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "ProductSObjectDataSpec.h"
#import "ProductSObjectData.h"

NSString * const kProductNameField          = @"Name";
NSString * const kProductDescriptionField   = @"Description__c";
NSString * const kProductSKUField           = @"Sku__c";

@implementation ProductSObjectDataSpec

- (id)init {
    NSString *objectType = @"Product__c";
    NSArray *objectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kSObjectIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectOwnerIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kProductNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kProductDescriptionField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kProductSKUField searchable:YES]
                                   ];
    NSArray *updateObjectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kProductNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kProductDescriptionField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kProductSKUField searchable:YES]
                                   ];

    // Any searchable fields would likely require index specs, if you're searching directly against SmartStore.
    NSArray *indexSpecs = @[ [[SFSoupIndex alloc] initWithPath:kProductNameField indexType:kSoupIndexTypeString columnName:kProductNameField],
                             [[SFSoupIndex alloc] initWithPath:kProductDescriptionField indexType:kSoupIndexTypeString columnName:kProductDescriptionField]
                             ];
    NSString *soupName = @"Products";
    NSString *orderByFieldName = kProductNameField;
    
    
    // ktb 1.27.2016 took this out since I want to show all products.
    //self.whereClause = [NSString stringWithFormat:@"OwnerId = '%@'", [self.class currentUserID]];
    
   
    

    return [self initWithObjectType:objectType objectFieldSpecs:objectFieldSpecs updateObjectFieldSpecs:updateObjectFieldSpecs
                         indexSpecs:indexSpecs soupName:soupName orderByFieldName:orderByFieldName];
}

#pragma mark - Abstract overrides

+ (SObjectData *)createSObjectData:(NSDictionary *)soupDict {
    return [[ProductSObjectData alloc] initWithSoupDict:soupDict];
}

@end
