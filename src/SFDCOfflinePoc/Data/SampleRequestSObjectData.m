//
//  SampleRequestSObjectData.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SampleRequestSObjectData.h"
#import "SampleRequestSObjectDataSpec.h"
#import "SObjectData+Internal.h"
#import <SmartSync/SFSmartSyncConstants.h>

@implementation SampleRequestSObjectData

+ (SObjectDataSpec *)dataSpec {
    static SampleRequestSObjectDataSpec *sDataSpec = nil;
    if (sDataSpec == nil) {
        sDataSpec = [[SampleRequestSObjectDataSpec alloc] init];
    }
    return sDataSpec;
}

#pragma mark - Property getters / setters

- (NSString *)name {
    return [self nonNullFieldValue:kSampleRequestNameField];
}

- (void)setName:(NSString *)name {
    [self updateSoupForFieldName:kSampleRequestNameField fieldValue:name];
}

- (NSString *)contactId {
    return [self nonNullFieldValue:kSampleRequestContactField];
}

- (void)setContactId:(NSString *)contactId {
    [self updateSoupForFieldName:kSampleRequestContactField fieldValue:contactId];
}

- (NSString *)contactName {
    return [[self nonNullFieldValue:kSampleRequestContactQueryField] objectForKey:@"Name"];
}

- (NSString *)productId {
    return [self nonNullFieldValue:kSampleRequestProductField];
}

- (void)setProductId:(NSString *)productId {
    [self updateSoupForFieldName:kSampleRequestProductField fieldValue:productId];
}

- (NSString *)productName {
    return [[self nonNullFieldValue:kSampleRequestProductQueryField] objectForKey:@"Name"];
}

- (NSString *)deliveryDate {
    return [self nonNullFieldValue:kSampleRequestDeliveryDateField];
}

- (void)setDeliveryDate:(NSString *)deliveryDate {
    [self updateSoupForFieldName:kSampleRequestDeliveryDateField fieldValue:deliveryDate];
}

- (NSString *)quantity {
    return [self nonNullFieldValue:kSampleRequestQuantityField];
}

- (void)setQuantity:(NSString *)quantity {
    [self updateSoupForFieldName:kSampleRequestQuantityField fieldValue:quantity];
}

- (NSString *)status {
    return [self nonNullFieldValue:kSampleRequestStatusField];
}

- (void)setStatus:(NSString *)status {
    [self updateSoupForFieldName:kSampleRequestStatusField fieldValue:status];
}

- (NSDictionary *)authorizedUsers {
    return [self nonNullFieldValue:kSampleRequestAuthorizedUsersField];
}

- (void)setAuthorizedUsers:(NSDictionary *)authorizedUsers {
    [self updateSoupForFieldName:kSampleRequestAuthorizedUsersField fieldValue:authorizedUsers];
}

- (NSArray *) userRecords {
    int totalSize = [[self.authorizedUsers objectForKey:@"totalSize"] intValue];
    if (totalSize > 0) {
        return [self.authorizedUsers objectForKey:@"records"];
    }
    return nil;
}

@end
