/*
 Copyright (c) 2014, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ContactSObjectDataSpec.h"
#import "ContactSObjectData.h"

NSString * const kContactFirstNameField    = @"FirstName";
NSString * const kContactLastNameField     = @"LastName";
NSString * const kContactTitleField        = @"Title";
NSString * const kContactMobilePhoneField  = @"MobilePhone";
NSString * const kContactEmailField        = @"Email";
NSString * const kContactDepartmentField   = @"Department";
NSString * const kContactHomePhoneField    = @"HomePhone";

@implementation ContactSObjectDataSpec

- (id)init {
    NSString *objectType = @"Contact";
    NSArray *objectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectOwnerIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactFirstNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactLastNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactTitleField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactMobilePhoneField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactEmailField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactDepartmentField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactHomePhoneField searchable:NO]
                                   ];

    NSArray *updateObjectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kContactFirstNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactLastNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactTitleField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactMobilePhoneField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactEmailField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactDepartmentField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kContactHomePhoneField searchable:NO]
                                   ];
    
    // Any searchable fields would likely require index specs, if you're searching directly against SmartStore.
    NSArray *indexSpecs = @[ [[SFSoupIndex alloc] initWithPath:kContactFirstNameField indexType:kSoupIndexTypeString columnName:kContactFirstNameField],
                             [[SFSoupIndex alloc] initWithPath:kContactLastNameField indexType:kSoupIndexTypeString columnName:kContactLastNameField],
                             [[SFSoupIndex alloc] initWithPath:kContactTitleField indexType:kSoupIndexTypeString columnName:kContactTitleField]
                             ];

    self.whereClause = [NSString stringWithFormat:@"OwnerId = '%@'", [self.class currentUserID]];

    NSString *soupName = @"contacts";
    NSString *orderByFieldName = kContactLastNameField;
    return [self initWithObjectType:objectType objectFieldSpecs:objectFieldSpecs updateObjectFieldSpecs:updateObjectFieldSpecs
                         indexSpecs:indexSpecs soupName:soupName orderByFieldName:orderByFieldName];
}

#pragma mark - Abstract overrides

+ (SObjectData *)createSObjectData:(NSDictionary *)soupDict {
    return [[ContactSObjectData alloc] initWithSoupDict:soupDict];
}

@end
