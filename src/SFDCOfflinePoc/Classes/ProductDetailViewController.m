//
//  ProductDetailViewController,h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductSObjectDataSpec.h"
#import "Helper.h"

@interface ProductDetailViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) ProductSObjectData *product;
@property (nonatomic, strong) SObjectDataManager *dataMgr;
@property (nonatomic, copy) void (^saveBlock)(void);

@property (nonatomic, strong) NSArray *dataRows;
@property (nonatomic, strong) NSArray *productDataRows;
@property (nonatomic, strong) NSArray *deleteButtonDataRow;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL productUpdated;
@property (nonatomic, assign) BOOL isNewProduct;

// Ui properties
@property (nonatomic, strong) UIView *toastView;
@property (nonatomic, strong) UILabel *toastViewMessageLabel;

@end

@implementation ProductDetailViewController

/**
 Initialize a new product detail view controller.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initForNewProductWithDataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock {
    return [self initWithProduct:nil dataManager:dataMgr saveBlock:saveBlock];
}

/**
 Initialize with an existing product detail view controller.
 @param product the current product.
 @param dataMgr the data manager object.
 @param saveBlock the block to be called when data is saved.
 */
- (id)initWithProduct:(ProductSObjectData *)product dataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (product == nil) {
            self.isNewProduct = YES;
            self.product = [[ProductSObjectData alloc] init];
        } else {
            self.isNewProduct = NO;
            self.product = product;
        }
        self.dataMgr = dataMgr;
        self.saveBlock = saveBlock;
        self.isEditing = NO;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    // Toast view
    self.toastView = [[UIView alloc] initWithFrame:CGRectZero];
    self.toastView.backgroundColor = [UIColor colorWithRed:(38.0 / 255.0) green:(38.0 / 255.0) blue:(38.0 / 255.0) alpha:0.7];
    self.toastView.layer.cornerRadius = 10.0;
    self.toastView.alpha = 0.0;

    self.toastViewMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.toastViewMessageLabel.font = [UIFont systemFontOfSize:kToastMessageFontSize];
    self.toastViewMessageLabel.textColor = [UIColor whiteColor];
    [self.toastView addSubview:self.toastViewMessageLabel];
    [self.view addSubview:self.toastView];

    self.dataRows = [self dataRowsFromProduct];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self configureInitialBarButtonItems];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.tableView setAllowsSelection:NO];

    if (self.isNewProduct) {
        [self editProduct];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.productUpdated && self.saveBlock != NULL) {
        dispatch_async(dispatch_get_main_queue(), self.saveBlock);
    }
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataRows count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProductDetailCellIdentifier";
    
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section < [self.productDataRows count]) {
        if (self.isEditing) {
            cell.textLabel.text = nil;
            UITextField *editField = self.dataRows[indexPath.section][3];
            editField.frame = cell.contentView.bounds;
            [self productTextFieldAddLeftMargin:editField];
            [cell.contentView addSubview:editField];
        } else {
            UITextField *editField = self.dataRows[indexPath.section][3];
            [editField removeFromSuperview];
            NSString *rowValueData = self.dataRows[indexPath.section][2];
            cell.textLabel.text = rowValueData;
        }
    } else {
        UIButton *deleteButton = self.dataRows[indexPath.section][1];
        deleteButton.frame = cell.contentView.bounds;
        [cell.contentView addSubview:deleteButton];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataRows[section][0];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self deleteProduct];
    }
}

#pragma mark - Private methods

- (void)configureInitialBarButtonItems {
    if (self.isNewProduct) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveProduct)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProduct)];
    }
    self.navigationItem.leftBarButtonItem = nil;
}

- (NSArray *)dataRowsFromProduct {
    self.productDataRows = @[ @[ @"Name",
                                 kProductNameField,
                                 [[self class] emptyStringForNullValue:self.product.name],
                                 [self productTextField:self.product.name] ],
                              @[ @"Description",
                                 kProductDescriptionField,
                                 [[self class] emptyStringForNullValue:self.product.productDescription],
                                 [self productTextField:self.product.productDescription] ],
                              @[ @"Sku",
                                 kProductSKUField,
                                 [[self class] emptyStringForNullValue:self.product.sku],
                                 [self productTextField:self.product.sku] ]
                              ];
    self.deleteButtonDataRow = @[ @"", [self deleteButtonView] ];
    
    NSMutableArray *workingDataRows = [NSMutableArray array];
    [workingDataRows addObjectsFromArray:self.productDataRows];
    if (!self.isNewProduct) {
        [workingDataRows addObject:self.deleteButtonDataRow];
    }
    
    return workingDataRows;
}

- (void)editProduct {
    self.isEditing = YES;
    if (!self.isNewProduct) {
        // Buttons will already be set for new product case.
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditProduct)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveProduct)];
    }
    [self.tableView reloadData];
    __weak ProductDetailViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.dataRows[0][3] becomeFirstResponder];
    });
}

- (void)cancelEditProduct {
    self.isEditing = NO;
    [self configureInitialBarButtonItems];
    [self.tableView reloadData];
}

- (void)saveProduct {
    [self configureInitialBarButtonItems];
    
    self.productUpdated = NO;
    for (NSArray *fieldArray in self.productDataRows) {
        NSString *fieldName = fieldArray[1];
        NSString *origFieldData = fieldArray[2];
        NSString *newFieldData = ((UITextField *)fieldArray[3]).text;
        if (self.isNewProduct || ![newFieldData isEqualToString:origFieldData]) {
            BOOL empty = !newFieldData || newFieldData.length == 0;
            if (empty && [fieldName isEqualToString:kProductNameField]) {
                [Helper showToast:self.toastView message:@"Please enter a name" label:self.toastViewMessageLabel];
                return;
            } else if (empty && [fieldName isEqualToString:kProductSKUField]) {
                [Helper showToast:self.toastView message:@"Please enter a SKU value" label:self.toastViewMessageLabel];
                return;
            }
            [self.product updateSoupForFieldName:fieldName fieldValue:newFieldData];
            self.productUpdated = YES;
        }
    }
    
    if (self.productUpdated) {
        if (self.isNewProduct) {
            [self.dataMgr createLocalData:self.product];
        } else {
            [self.dataMgr updateLocalData:self.product];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.tableView reloadData];
    }
    
}

- (void)deleteProductConfirm {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this product?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)deleteProduct {
    [self.dataMgr deleteLocalData:self.product];
    self.productUpdated = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextField *)productTextField:(NSString *)propertyValue {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.text = propertyValue;
    return textField;
}

- (UIButton *)deleteButtonView {
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteButton setTitle:@"Delete Product" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    deleteButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [deleteButton addTarget:self action:@selector(deleteProductConfirm) forControlEvents:UIControlEventTouchUpInside];
    return deleteButton;
}

- (void)productTextFieldAddLeftMargin:(UITextField *)textField {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, textField.frame.size.height)];
    leftView.backgroundColor = textField.backgroundColor;
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (NSString *)emptyStringForNullValue:(id)origValue {
    if (origValue == nil || origValue == [NSNull null]) {
        return @"";
    } else {
        return origValue;
    }
}

@end
