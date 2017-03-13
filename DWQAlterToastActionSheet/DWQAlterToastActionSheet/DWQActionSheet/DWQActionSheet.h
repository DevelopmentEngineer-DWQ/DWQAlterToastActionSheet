
//  DWQAlterToastActionSheet
//
//  Created by 杜文全 on 16/11/24.
//  Copyright © 2016年 杜文全. All rights reserved.



#import <UIKit/UIKit.h>

#define SCREENWIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT   [UIScreen mainScreen].bounds.size.height

#define DWQWeak         __weak __typeof(self) weakSelf = self

typedef NS_ENUM(NSInteger, DWQCustomActionSheetStyle) {
    /*!
     *  普通样式
     */
    DWQCustomActionSheetStyleNormal = 1,
    /*!
     *  带标题样式
     */
    DWQCustomActionSheetStyleTitle,
    /*!
     *  带图片和标题样式
     */
    DWQCustomActionSheetStyleImageAndTitle,
    /*!
     *  带图片样式
     */
    DWQCustomActionSheetStyleImage,
};

typedef void(^ButtonActionBlock)(NSInteger index);

@interface DWQActionSheet : UIView

/*!
 *
 *  @param style             样式
 *  @param contentArray      选项数组(NSString数组)
 *  @param imageArray        图片数组(UIImage数组)
 *  @param redIndex          特别颜色的下标数组(NSNumber数组)
 *  @param title             标题内容(可空)
 *  @param clikckButtonIndex block回调点击的选项
 */
+ (void)dwq_showActionSheetWithStyle:(DWQCustomActionSheetStyle)style
                       contentArray:(NSArray<NSString *> *)contentArray
                         imageArray:(NSArray<UIImage *> *)imageArray
                           redIndex:(NSInteger)redIndex
                              title:(NSString *)title
                      configuration:(void (^)(DWQActionSheet *tempView)) configuration
                  ClikckButtonIndex:(ButtonActionBlock)clikckButtonIndex;

/*!
 *  隐藏 DWQActionSheet
 */
- (void)dwq_dismissDWQActionSheet;

@end
