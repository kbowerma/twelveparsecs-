//
//  TabBarViewController.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/23/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import <SmartSync/SFSmartSyncSyncManager.h>
#import <SmartStore/SFSmartStore.h>
#import <SalesforceSDKCore/SFUserAccountManager.h>

#import "TabBarViewController.h"
#import "BaseListViewController.h"
#import "Helper.h"

#import "SObjectDataManager.h"

@implementation TabBarViewController {
    // UI properties
    UIView *pinView;
    UIAlertController *alertView;

    // smart sync properties
    SFSmartSyncSyncManager *mgr;

    // connection properties
    BOOL noConnection;

    // timer properties
    NSString *pin;
    NSTimeInterval timerInterval;
    NSTimer *syncTimer;
}

@synthesize mgrArray;

- (id)init {
    self = [super init];
    if (self) {
        mgr = [SFSmartSyncSyncManager sharedInstance:[SFUserAccountManager sharedInstance].currentUser];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    pin = [standardUserDefaults objectForKey:@"user_pin"];
    timerInterval = [[standardUserDefaults objectForKey:@"timer_preference"] doubleValue];

    pinView = [[UIView alloc] initWithFrame:self.view.bounds];
    pinView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];

    if (!pin) {
        [self.view addSubview:pinView];
        [self.view setUserInteractionEnabled:NO];
    }

    noConnection = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!pin) {
        [self showNewPinAlert];
    } else {
        [self setupSync];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (syncTimer) {
        [syncTimer invalidate];
        syncTimer = nil;
    }
}

/**
 Synchronize up/down all soups.
 */
- (void)syncUpDown {
    if (![Helper isReachable]) {
        return;
    }

    if ([[NSThread currentThread] isMainThread]) {
        [self performSelectorInBackground:@selector(syncUpDown) withObject:nil];
        return;
    }

    [self lock];
    
    __block NSInteger count = self.viewControllers.count;
    NSLog(@"Trying to sync all soups");

    for (SObjectDataManager *dataMgr in self.mgrArray) {
        NSString *name = dataMgr.dataSpec.soupName;
        if ([[mgr getDirtyRecordIds:name idField:SOUP_ENTRY_ID] count] > 0) {
            [self syncUpDown:dataMgr completionBlock:^(SFSyncState *syncProgressDetails) {
                @synchronized(self) {
                    if (--count == 0) [self unlock];

                    [dataMgr refreshLocalData];
                }
            }];
        } else {
            @synchronized(self) {
                if (--count == 0) [self unlock];
            }
        }
    }
}

#pragma mark - Private methods

/// Check the network connection
- (void)checkNetwork {
    if ([Helper isReachable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // return from no connection sync data
            if (noConnection) {
                [self syncUpDown];
            }

            noConnection = NO;
            [pinView removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
            [alertView dismissViewControllerAnimated:YES completion:^{
                alertView = nil;
            }];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            noConnection = YES;
            [self.view addSubview:pinView];
            [self.view setUserInteractionEnabled:NO];
            [self showAlert];
        });
    }
}

/// Setup synchronization objects
- (void)setupSync {
    if (syncTimer) {
        [syncTimer invalidate];
    }

    syncTimer = [NSTimer timerWithTimeInterval:(60 * timerInterval) target:self selector:@selector(syncUpDown)
                                      userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:syncTimer forMode:NSDefaultRunLoopMode];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetwork)
                                                 name:kSFSDKReachabilityChangedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncUpDown) name:kUpdateRecord object:nil];

    if (![Helper isReachable]) {
        [self showAlert];
    }
}

/// Show new pin alert dialog. User will have to enter the new pin.
- (void)showNewPinAlert {
    alertView = [UIAlertController alertControllerWithTitle:@"Pin" message:@"Enter pin"
                                             preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Type pin (6 numbers)";
        textField.secureTextEntry = NO;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.textAlignment = NSTextAlignmentCenter;
    }];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *pinTextField = alertView.textFields.firstObject;
        pin = pinTextField.text;
        if (pin.length != 6) {
            pinTextField.text = nil;
            [self showNewPinAlert];

            return;
        }

        alertView = nil;
        [[NSUserDefaults standardUserDefaults] setObject:pin forKey:@"user_pin"];
        if ([[NSUserDefaults standardUserDefaults] synchronize]) {
            [pinView removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
            [self setupSync];
        }
    }];

    [alertView addAction:action];

    [self presentViewController:alertView animated:YES completion:nil];
}

/// Show alert dialog. User will have to enter pin.
- (void)showAlert {
    if (noConnection) {
        alertView = [UIAlertController alertControllerWithTitle:@"No connection" message:@"Enter your pin"
                                                 preferredStyle:UIAlertControllerStyleAlert];
        [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Type pin";
            textField.secureTextEntry = YES;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.textAlignment = NSTextAlignmentCenter;
        }];

        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *pinTextField = alertView.textFields.firstObject;
            if ([pinTextField.text isEqualToString:pin]) {
                [pinView removeFromSuperview];
                [self.view setUserInteractionEnabled:YES];
                alertView = nil;
            } else {
                [self showAlert];
            }
        }];

        [alertView addAction:action];

        [self presentViewController:alertView animated:YES completion:nil];
    }
}

/// Sync up/down using provided data manager
- (void)syncUpDown:(SObjectDataManager *) dataMgr completionBlock:(SFSyncSyncManagerUpdateBlock)completionBlock {
    [dataMgr updateRemoteData:^(SFSyncState *syncProgressDetails) {
        if ([syncProgressDetails isDone]) {
            [dataMgr refreshRemoteData:completionBlock];
        } else {
            completionBlock(syncProgressDetails);
        }
    }];
}

/// Lock the application to prevent concurrent updates.
- (void)lock {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UINavigationController *nav in self.viewControllers) {
            BaseListViewController *ctrl = (BaseListViewController *) nav.topViewController;
            ctrl.navigationItem.rightBarButtonItem.enabled = NO;
        }
    });

    [Helper lock];
}

/// Unlock the application to prevent concurrent updates.
- (void)unlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UINavigationController *nav in self.viewControllers) {
            BaseListViewController *ctrl = (BaseListViewController *) nav.topViewController;
            ctrl.navigationItem.rightBarButtonItem.enabled = YES;
        }
    });

    [Helper unlock];
}

@end
