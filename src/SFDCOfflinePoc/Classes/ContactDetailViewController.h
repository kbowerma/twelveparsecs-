//
//  ContactDetailViewController.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactSObjectData.h"
#import "SObjectDataManager.h"

@interface ContactDetailViewController : UITableViewController <UITableViewDataSource>

/**
 Initialize a new contact detail view controller.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initForNewContactWithDataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock;

/**
 Initialize with an existing contact detail view controller.
 @param contact the current contact.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initWithContact:(ContactSObjectData *)contact dataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock;

@end
