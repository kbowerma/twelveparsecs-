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

#import <UIKit/UIKit.h>
#import <SmartSync/SFSmartSyncSyncManager.h>
#import <SmartSync/SFSyncState.h>
#import <SalesforceSDKCore/SFLogger.h>
#import "SObjectData.h"

static CGFloat    const kNavBarTitleFontSize            = 20.0;
static NSUInteger const kNavBarTintColor                = 0xf10000;

@class SObjectDataManager;

@interface BaseListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

// Data properties
@property (nonatomic, strong) SObjectDataManager *dataMgr;
@property (nonatomic, strong) SObjectDataManager *contactDataMgr;
@property (nonatomic, strong) SObjectDataManager *productDataMgr;
@property (nonatomic, strong) SObjectDataManager *sampleRequestDataMgr;

// Popover methods for handling Salesforce login.
- (void)popoverOptionSelected:(NSString *)text;
- (void)clearPopovers:(NSNotification *)note;

/**
 Create color from an integer rgb value.
 @param rgbHexColorValue integer rgb value.
 @return the color.
 */
+ (UIColor *)colorFromRgbHexValue:(NSUInteger)rgbHexColorValue;

/**
 Format the title or return an empty string.
 @param title to format.
 @return the formatted title.
 */
- (NSString *)formatTitle:(NSString *)title;

/**
 Create an accessory view for each cell.
 @param obj the object used to create the accessory.
 @return the created accessory view.
 */
- (UIView *)accessoryViewForContact:(SObjectData *)contact;

/*!
 Synchronize up/down all records for current data manager.
 */
- (void)syncUpDown;

/*!
 Reload all data.
 */
- (void)reloadData;

@end
