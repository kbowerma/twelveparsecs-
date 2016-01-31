//
//  TabBarViewController.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/23/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarViewController : UITabBarController<UIAlertViewDelegate>

/*!
 Data manager array.
 */
@property (nonatomic, strong) NSArray *mgrArray;

/**
 Synchronize up/down all soups.
 */
- (void)syncUpDown;

@end
