//
//  SampleRequestDetailViewController.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SampleRequestSObjectData.h"
#import "SObjectDataManager.h"

@interface SampleRequestDetailViewController : UITableViewController <UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) SObjectDataManager *contactMgr;
@property (nonatomic, strong) SObjectDataManager *productMgr;

/**
 Initialize a new sample request detail view controller.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initForNewSampleRequestWithDataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock;

/**
 Initialize with an existing sample request detail view controller.
 @param ample request the current product.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initWithSampleRequest:(SampleRequestSObjectData *)sampleRequest dataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock;

@end
