//  DWQAlterToastActionSheet
//
//  Created by 杜文全 on 16/11/24.
//  Copyright © 2016年 杜文全. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DWQToastView;

/** A notification center for displaying quick bursts of toast information to the user. */
@interface DWQToastCenter : NSObject {
	NSMutableArray *_toasts;
	BOOL _active;
	DWQToastView *_toastView;
	CGRect _toastFrame;
}

/** Returns the process’s default notification center. 
 @return The current process’s default notification center, which is used for toast notifications.
 */
+ (DWQToastCenter*) defaultCenter;


/** Posts a given toast message to the user.
 @param message The message shown under an image.
 @param image The image displayed to the user. If image is nil, the message will only be shown.
 */
- (void) postToastWithMessage:(NSString*)message image:(UIImage*)image;

/** Posts a given toast message to the user.
 @param message The message shown under an image.
 */
- (void) postToastWithMessage:(NSString *)message;

@end
