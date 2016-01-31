//
//  Helper.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/29/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

#import "Helper.h"

static SFSDKReachability *reachability = nil;
static NSString* reachHostName = @"www.google.com"; // this could be any value to validate internet connection exists
static NSLock *updateLock;

@implementation Helper {
    // Lock for data update from server
    NSLock *updateLock;
}

+ (void)initialize {
    // Allocate a reachability object
    reachability = [SFSDKReachability reachabilityWithHostName:reachHostName];

    // Start the notifier, which will cause the reachability object to retain itself!
    [reachability startNotifier];

    updateLock = [NSLock new];
}

/**
 Get the SFSDKReachability object.
 @return the SFSDKReachability instance object.
 */
+ (SFSDKReachability *)reachability {
    return reachability;
}

/**
 Check if internet can be reached. Valid for Wifi and WWAN.
 @return YES if reachable, otherwise NO.
 */
+ (BOOL)isReachable {
    return [reachability currentReachabilityStatus] != SFSDKReachabilityNotReachable;
}

/**
 Attempts to acquire a lock, blocking a thread’s execution until the lock can be acquired.

 An application protects a critical section of code by requiring a thread to acquire a lock before executing the code. Once the critical section is completed, the thread relinquishes the lock by invoking unlock.
 */
+ (void)lock {
    [updateLock lock];
}

/**
 Attempts to acquire a lock and immediately returns a Boolean value that indicates whether the attempt was successful.
 @return YES if the lock was acquired, otherwise NO.
 */
+ (BOOL)tryLock {
    return [updateLock tryLock];
}

/**
 Relinquishes a previously acquired lock.
 */
+ (void)unlock {
    [updateLock unlock];
}

+ (void)showToast:(UIView *) toastView message:(NSString *)message label:(UILabel *)toastLabel {
    NSTimeInterval const toastDisplayTimeSecs = 2.0;

    [self layoutToastView:toastView message:message label:toastLabel];
    toastView.alpha = 0.0;
    [UIView beginAnimations:@"toastFadeIn" context:NULL];
    [UIView setAnimationDuration:0.3];
    toastView.alpha = 1.0;
    [UIView commitAnimations];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, toastDisplayTimeSecs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView beginAnimations:@"toastFadeOut" context:NULL];
        [UIView setAnimationDuration:0.3];
        toastView.alpha = 0.0;
        [UIView commitAnimations];
    });
}

+ (void)layoutToastView:(UIView *) toastView message:(NSString *)message label:(UILabel *)toastLabel {
    CGFloat toastWidth = 250.0;
    CGFloat toastHeight = 50.0;
    CGFloat bottomScreenPadding = 60.0;

    toastView.frame = CGRectMake(CGRectGetMidX([toastView superview].bounds) - (toastWidth / 2.0),
                                 CGRectGetMaxY([toastView superview].bounds) - bottomScreenPadding - toastHeight,
                                 toastWidth,
                                 toastHeight);

    //
    // messageLabel
    //
    NSDictionary *messageAttrs = @{ NSForegroundColorAttributeName:toastLabel.textColor,
                                    NSFontAttributeName:toastLabel.font };
    if (message == nil) {
        message = @" ";
    }
    CGSize messageTextSize = [message sizeWithAttributes:messageAttrs];
    CGRect messageRect = CGRectMake(CGRectGetMidX(toastView.bounds) - (messageTextSize.width / 2.0),
                                    CGRectGetMidY(toastView.bounds) - (messageTextSize.height / 2.0),
                                    messageTextSize.width, messageTextSize.height);
    toastLabel.frame = messageRect;
    toastLabel.text = message;
}


@end
