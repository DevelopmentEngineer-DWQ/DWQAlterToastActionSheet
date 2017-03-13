
//  DWQAlterToastActionSheet
//
//  Created by 杜文全 on 16/11/24.
//  Copyright © 2016年 杜文全. All rights reserved.


#import <UIKit/UIKit.h>

static NSString *DWQASCellIdentifier = @"DWQTableCell";

@interface DWQTableCell : UITableViewCell

/*! 自定义图片 */
@property (weak, nonatomic) IBOutlet UIImageView  *customImageView;
/*! 自定义title */
@property (weak, nonatomic) IBOutlet UILabel      *customTextLabel;


@end
