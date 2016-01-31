//
//  Helper.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/29/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SalesForceSDKCore/SFSDKReachability.h>

#define kUpdateRecord                   @"kUpdateRecord"
#define kToastMessageFontSize           16.0

@interface Helper : NSObject

/**
 Get the SFSDKReachability object.
 @return the SFSDKReachability instance object.
 */
+ (SFSDKReachability *)reachability;

/**
 Check if internet can be reached. Valid for Wifi and WWAN.
 @return YES if reachable, otherwise NO.
 */
+ (BOOL)isReachable;

/**
 Attempts to acquire a lock, blocking a thread’s execution until the lock can be acquired.

 An application protects a critical section of code by requiring a thread to acquire a lock before executing the code. Once the critical section is completed, the thread relinquishes the lock by invoking unlock.
 */
+ (void)lock;

/**
 Attempts to acquire a lock and immediately returns a Boolean value that indicates whether the attempt was successful.
 @return YES if the lock was acquired, otherwise NO.
 */
+ (BOOL)tryLock;

/**
 Relinquishes a previously acquired lock.
 */
+ (void)unlock;

+ (void)showToast:(UIView *) toastView message:(NSString *)message label:(UILabel *)toastLabel;

+ (void)layoutToastView:(UIView *) toastView message:(NSString *)message label:(UILabel *)toastLabel;

@end
