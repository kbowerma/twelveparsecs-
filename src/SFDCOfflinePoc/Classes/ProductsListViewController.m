//
//  ProductsListViewController.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "ProductsListViewController.h"

#import "ActionsPopupController.h"
#import "SObjectDataManager.h"
#import "ProductSObjectDataSpec.h"
#import "ProductSObjectData.h"
#import "ProductDetailViewController.h"
#import <WYPopoverController/WYPopoverController.h>
#import <SalesforceSDKCore/SFDefaultUserManagementViewController.h>
#import <SmartStore/SFSmartStoreInspectorViewController.h>
#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import <SalesforceSDKCore/SFSecurityLockout.h>
#import <SmartSync/SFSmartSyncSyncManager.h>
#import <SmartSync/SFSyncState.h>

static NSString * const kNavBarTitleText                = @"Products";
static NSUInteger const kProductTitleTextColor          = 0x696969;
static CGFloat    const kProductTitleFontSize           = 15.0;
static CGFloat    const kProductDetailFontSize          = 13.0;


@interface ProductsListViewController () <UISearchBarDelegate>

@property (nonatomic, strong) WYPopoverController *popOverController;
@property (nonatomic, strong) UIActionSheet *logoutActionSheet;


// View / UI properties
@property (nonatomic, strong) UILabel *navBarLabel;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *syncButton;

@end

@implementation ProductsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataMgr = [[SObjectDataManager alloc] initWithViewController:self dataSpec:[ProductSObjectData dataSpec]];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        if (!self.dataMgr) {
            self.dataMgr = [[SObjectDataManager alloc] initWithViewController:self dataSpec:[ProductSObjectData dataSpec]];
        }
        [self.dataMgr refreshLocalData];
        if ([self.dataMgr.dataRows count] == 0)
            [self.dataMgr refreshRemoteData];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];

    self.navigationController.navigationBar.barTintColor = [[self class] colorFromRgbHexValue:kNavBarTintColor];

    // Nav bar label
    self.navBarLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.navBarLabel.text = kNavBarTitleText;
    self.navBarLabel.textAlignment = NSTextAlignmentLeft;
    self.navBarLabel.textColor = [UIColor whiteColor];
    self.navBarLabel.backgroundColor = [UIColor clearColor];
    self.navBarLabel.font = [UIFont systemFontOfSize:kNavBarTitleFontSize];
    self.navigationItem.titleView = self.navBarLabel;

    // Navigation bar buttons
    self.addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(addProduct)];
    self.syncButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync"] style:UIBarButtonItemStylePlain target:self action:@selector(syncUpDown)];
    self.navigationItem.rightBarButtonItems = @[ self.syncButton, self.addButton ];
    for (UIBarButtonItem *bbi in self.navigationItem.rightBarButtonItems) {
        bbi.tintColor = [UIColor whiteColor];
    }
}

#pragma mark - UITableView delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProductListCellIdentifier";

    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    ProductSObjectData *obj = [self.dataMgr.dataRows objectAtIndex:indexPath.row];
    cell.textLabel.text = [self formatTitle:obj.name];
    cell.textLabel.font = [UIFont systemFontOfSize:kProductTitleFontSize];
    cell.detailTextLabel.text = [self formatTitle:obj.productDescription];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:kProductDetailFontSize];
    cell.detailTextLabel.textColor = [[self class] colorFromRgbHexValue:kProductTitleTextColor];
    cell.imageView.image = nil;

    cell.accessoryView = [self accessoryViewForContact:obj];

    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductSObjectData *product = [self.dataMgr.dataRows objectAtIndex:indexPath.row];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kNavBarTitleText style:UIBarButtonItemStylePlain target:nil action:nil];
    ProductDetailViewController *detailVc = [[ProductDetailViewController alloc] initWithProduct:product
                                                                                     dataManager:self.dataMgr
                                                                                       saveBlock:^{
                                                                                           [self.tableView beginUpdates];
                                                                                           [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                                                                                           [self.tableView endUpdates];
                                                                                       }];
    [self.navigationController pushViewController:detailVc animated:YES];
}

#pragma mark - Private methods

- (void)addProduct {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kNavBarTitleText style:UIBarButtonItemStylePlain target:nil action:nil];
    ProductDetailViewController *detailVc = [[ProductDetailViewController alloc] initForNewProductWithDataManager:self.dataMgr saveBlock:^{
        [self.dataMgr refreshLocalData];
    }];
    [self.navigationController pushViewController:detailVc animated:YES];
}

@end
