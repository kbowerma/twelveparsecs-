//
//  ProductDetailViewController,h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductSObjectData.h"
#import "SObjectDataManager.h"

@interface ProductDetailViewController : UITableViewController <UITableViewDataSource>

/**
 Initialize a new product detail view controller.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initForNewProductWithDataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock;

/**
 Initialize with an existing product detail view controller.
 @param product the current product.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initWithProduct:(ProductSObjectData *)product dataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock;

@end
