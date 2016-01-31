//
//  SampleRequestSObjectDataSpec.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SampleRequestSObjectDataSpec.h"
#import "SampleRequestSObjectData.h"

NSString * const kSampleRequestNameField         = @"Name";
NSString * const kSampleRequestContactQuery      = @"Contact__r.Name";
NSString * const kSampleRequestContactQueryField = @"Contact__r";
NSString * const kSampleRequestContactField      = @"Contact__c";
NSString * const kSampleRequestProductQuery      = @"Product__r.Name";
NSString * const kSampleRequestProductQueryField = @"Product__r";
NSString * const kSampleRequestProductField      = @"Product__c";
NSString * const kSampleRequestDeliveryDateField = @"Delivery_Date__c";
NSString * const kSampleRequestQuantityField     = @"Quantity__c";
NSString * const kSampleRequestStatusField       = @"Status__c";
NSString * const kSampleRequestAuthorizedUsersQuery = @"(SELECT User__r.Name, User__c FROM Authorized_Users__r)";
NSString * const kSampleRequestAuthorizedUsersField = @"Authorized_Users__r";

@implementation SampleRequestSObjectDataSpec

- (id)init {
    NSString *objectType = @"SampleRequest__c";
    NSArray *objectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kSObjectIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectOwnerIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestContactQuery searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestContactField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestProductQuery searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestProductField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestDeliveryDateField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestQuantityField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestStatusField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestAuthorizedUsersQuery searchable:NO]
                                   ];
    NSArray *updateObjectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestContactField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestProductField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestDeliveryDateField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestQuantityField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kSampleRequestStatusField searchable:NO]
                                   ];

    // Any searchable fields would likely require index specs, if you're searching directly against SmartStore.
    NSArray *indexSpecs = @[ [[SFSoupIndex alloc] initWithPath:kSampleRequestNameField indexType:kSoupIndexTypeString columnName:kSampleRequestNameField]
                             ];

    self.whereClause = nil;

    NSString *soupName = @"SampleRequests";
    NSString *orderByFieldName = kSampleRequestNameField;
    return [self initWithObjectType:objectType objectFieldSpecs:objectFieldSpecs updateObjectFieldSpecs:updateObjectFieldSpecs
                         indexSpecs:indexSpecs soupName:soupName orderByFieldName:orderByFieldName];
}

#pragma mark - Abstract overrides

+ (SObjectData *)createSObjectData:(NSDictionary *)soupDict {
    return [[SampleRequestSObjectData alloc] initWithSoupDict:soupDict];
}

@end
