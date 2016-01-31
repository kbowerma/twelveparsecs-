//
//  SampleRequestListViewController.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SampleRequestListViewController.h"

#import "ActionsPopupController.h"
#import "SObjectDataManager.h"
#import "SampleRequestDetailViewController.h"
#import "SampleRequestSObjectDataSpec.h"
#import "SampleRequestSObjectData.h"
#import "ContactSObjectData.h"
#import "ProductSObjectData.h"
#import "WYPopoverController.h"
#import <SalesforceSDKCore/SFDefaultUserManagementViewController.h>
#import <SmartStore/SFSmartStoreInspectorViewController.h>
#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import <SalesforceSDKCore/SFSecurityLockout.h>
#import <SmartSync/SFSmartSyncSyncManager.h>
#import <SmartSync/SFSyncState.h>

static NSString * const kNavBarTitleText                = @"Sample Requests";
static NSUInteger const kProductTitleTextColor          = 0x696969;
static CGFloat    const kProductTitleFontSize           = 15.0;
static CGFloat    const kProductDetailFontSize          = 13.0;

@interface SampleRequestListViewController () <UISearchBarDelegate>

@property (nonatomic, strong) WYPopoverController *popOverController;
@property (nonatomic, strong) UIActionSheet *logoutActionSheet;

// View / UI properties
@property (nonatomic, strong) UILabel *navBarLabel;
@property (nonatomic, strong) UIBarButtonItem *syncButton;
@property (nonatomic, strong) UIBarButtonItem *addButton;

// Data properties
@property (nonatomic, strong) NSMutableArray *filtereDataRows;

@end

@implementation SampleRequestListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.filtereDataRows = [NSMutableArray array];

        self.dataMgr = [[SObjectDataManager alloc] initWithViewController:self dataSpec:[SampleRequestSObjectData dataSpec]];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.filtereDataRows = [NSMutableArray array];

        if (!self.dataMgr) {
            self.dataMgr = [[SObjectDataManager alloc] initWithViewController:self dataSpec:[SampleRequestSObjectData dataSpec]];
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
    self.addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(addSampleRequest)];
    self.syncButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync"] style:UIBarButtonItemStylePlain target:self action:@selector(syncUpDown)];
    self.navigationItem.rightBarButtonItems = @[ self.syncButton, self.addButton ];
    for (UIBarButtonItem *bbi in self.navigationItem.rightBarButtonItems) {
        bbi.tintColor = [UIColor whiteColor];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self reloadData];
}

#pragma mark - Overload methods

/*!
 Reload all data.
 */
- (void)reloadData {
    [self.filtereDataRows removeAllObjects];
    [self.tableView reloadData];

    for (SampleRequestSObjectData *object in self.dataMgr.dataRows) {
        if (!object.ownerId || [object.ownerId isEqualToString:[SObjectDataSpec currentUserID]]) {
            [self.filtereDataRows addObject:object];
        } else {
            for (NSDictionary *user in object.userRecords) {
                NSString *userId = [user objectForKey:@"User__c"];
                if ([userId isEqualToString:[SObjectDataSpec currentUserID]]) {
                    [self.filtereDataRows addObject:object];
                    break;
                }
            }
        }
    }

    [super reloadData];
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filtereDataRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SampleRequestListCellIdentifier";

    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    SampleRequestSObjectData *obj = [self.filtereDataRows objectAtIndex:indexPath.row];
    cell.textLabel.text = [self formatTitle:obj.name ? obj.name : @"Please sync"];
    cell.textLabel.font = [UIFont systemFontOfSize:kProductTitleFontSize];
    cell.detailTextLabel.text = [self formatSubtitle:obj];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:kProductDetailFontSize];
    cell.detailTextLabel.textColor = [[self class] colorFromRgbHexValue:kProductTitleTextColor];
    cell.imageView.image = nil;

    cell.accessoryView = [self accessoryViewForContact:obj];

    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SampleRequestSObjectData *contact = [self.filtereDataRows objectAtIndex:indexPath.row];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kNavBarTitleText style:UIBarButtonItemStylePlain target:nil action:nil];
    SampleRequestDetailViewController *detailVc = [[SampleRequestDetailViewController alloc]
                                                   initWithSampleRequest:contact dataManager:self.dataMgr
                                                   saveBlock:^{
                                                       [self.tableView beginUpdates];
                                                       [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                                                       [self.tableView endUpdates];
                                                   }];
    detailVc.contactMgr = self.contactDataMgr;
    detailVc.productMgr = self.productDataMgr;

    [self.navigationController pushViewController:detailVc animated:YES];
}

#pragma mark - Private methods

- (void)addSampleRequest {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kNavBarTitleText style:UIBarButtonItemStylePlain target:nil action:nil];
    SampleRequestDetailViewController *detailVc = [[SampleRequestDetailViewController alloc] initForNewSampleRequestWithDataManager:self.dataMgr saveBlock:^{
        [self.dataMgr refreshLocalData];
    }];
    detailVc.contactMgr = self.contactDataMgr;
    detailVc.productMgr = self.productDataMgr;

    [self.navigationController pushViewController:detailVc animated:YES];
}

- (NSString *)formatSubtitle:(SampleRequestSObjectData *)sampleRequest {
    NSString *quantity = [sampleRequest.quantity stringValue];
    NSString *deliveryDate = [sampleRequest.deliveryDate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    NSString *status = [sampleRequest.status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (deliveryDate == nil) {
        return [NSString stringWithFormat:@"Contact: %@ / Product: %@ / Qty: %@ / Status: %@ / Date: -",
                [self formatContact:sampleRequest], [self formatProduct:sampleRequest], quantity, status];
    } else {
        return [NSString stringWithFormat:@"Contact: %@ / Product: %@ / Qty: %@ / Status: %@ / Date: %@",
                [self formatContact:sampleRequest], [self formatProduct:sampleRequest], quantity, status, deliveryDate];
    }
}

- (NSString *)formatProduct:(SampleRequestSObjectData *) sampleRequest {
    ProductSObjectData *product = (ProductSObjectData *) [self.productDataMgr findById:sampleRequest.productId];
    return product ? product.name : (sampleRequest.productName ? sampleRequest.productName : @"");
}

- (NSString *)formatContact:(SampleRequestSObjectData *) sampleRequest {
    ContactSObjectData *contact = (ContactSObjectData *) [self.contactDataMgr findById:sampleRequest.contactId];
    if (!contact) {
        return sampleRequest.contactName ? sampleRequest.contactName : @"";
    }

    NSString *firstName = [contact.firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastName = [contact.lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (firstName == nil && lastName == nil) {
        return @"";
    } else if (firstName == nil && lastName != nil) {
        return lastName;
    } else if (firstName != nil && lastName == nil) {
        return firstName;
    } else {
        return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
}

@end
