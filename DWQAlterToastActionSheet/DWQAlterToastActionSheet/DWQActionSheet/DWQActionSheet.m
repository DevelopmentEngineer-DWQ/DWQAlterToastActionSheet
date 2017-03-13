
//  DWQAlterToastActionSheet
//
//  Created by 杜文全 on 16/11/24.
//  Copyright © 2016年 杜文全. All rights reserved.



#import "DWQActionSheet.h"
#import "DWQTableCell.h"

@interface DWQActionSheet ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
/*! tableView */
@property (strong, nonatomic) UITableView  *tableView;
/*! 触摸背景消失 */
@property (strong, nonatomic) UIControl    *overlayControl;
/*! 数据源 */
@property (strong, nonatomic) NSArray      *dataArray;
/*! 图片数组 */
@property (strong, nonatomic) NSArray      *imageArray;
/*! 标记颜色是红色的那行 */
@property (assign, nonatomic) NSInteger    specialIndex;
/*! 标题 */
@property (copy, nonatomic  ) NSString     *title;
/*! 点击事件回调 */
@property (copy, nonatomic) void(^callback)(NSInteger index);
/*! 自定义样式 */
@property (assign, nonatomic) DWQCustomActionSheetStyle viewStyle;

@end

@implementation DWQActionSheet

+ (instancetype)shareActionSheet
{
    DWQActionSheet *actionSheet   = [[self alloc] init];
    actionSheet.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    return actionSheet;
}

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
                  ClikckButtonIndex:(ButtonActionBlock)clikckButtonIndex
{
    DWQActionSheet *actionSheet       = [self shareActionSheet];
    actionSheet.dataArray            = contentArray;
    actionSheet.callback             = clikckButtonIndex;
    actionSheet.viewStyle            = style;
    actionSheet.imageArray           = imageArray;
    actionSheet.specialIndex         = redIndex;
    actionSheet.title                = title;
    if (configuration)
    {
        configuration(actionSheet);
    }
    [actionSheet.tableView reloadData];
    [actionSheet show];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( 0 == section )
    {
        if ( self.viewStyle == DWQCustomActionSheetStyleNormal || self.viewStyle == DWQCustomActionSheetStyleImage )
        {
            return self.dataArray.count;
        }
        else
        {
            return self.dataArray.count + 1;
        }
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (section == 0)?8.f:0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWQTableCell *cell = [tableView dequeueReusableCellWithIdentifier:DWQASCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = (self.title)?UITableViewCellSelectionStyleNone:UITableViewCellSelectionStyleDefault;
    if ( 0 == indexPath.section )
    {
        if ( indexPath.row == self.specialIndex )
        {
            cell.customTextLabel.textColor = [UIColor redColor];
        }
        
        if ( self.viewStyle == DWQCustomActionSheetStyleNormal )
        {
            cell.customTextLabel.text = self.dataArray[indexPath.row];
        }
        else if ( self.viewStyle == DWQCustomActionSheetStyleTitle )
        {
            cell.customTextLabel.text = (indexPath.row ==0) ? self.title : self.dataArray[indexPath.row-1];
        }
        else
        {
            
            NSInteger index = (self.title) ? indexPath.row - 1 : indexPath.row;
            if ( index >= 0 )
            {
                cell.customImageView.image = self.imageArray[index];
            }
            
            cell.customTextLabel.text = (indexPath.row == 0) ? self.title : self.dataArray[indexPath.row-1];
        }
    }
    else
    {
        cell.customTextLabel.text = @"取 消";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( 0 == indexPath.section )
    {
        NSInteger index = 0;
        if ( self.viewStyle == DWQCustomActionSheetStyleNormal || self.viewStyle == DWQCustomActionSheetStyleImage )
        {
            index = indexPath.row;
        }
        else
        {
            index = indexPath.row - 1;
        }
        if (-1 == index)
        {
            NSLog(@"【 DWQActionSheet 】标题不能点击！");
            return;
        }
        self.callback(index);
    }
    else if ( 1 == indexPath.section )
    {
        NSLog(@"【 DWQActionSheet 】你点击了取消按钮！");
        [self fadeOut];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UpdateFrame
- (void)fadeIn
{
    CGFloat tableViewHeight = MIN(SCREENHEIGHT - 64.f, self.tableView.contentSize.height);
    self.tableView.frame = CGRectMake(0.f, 0.f, SCREENWIDTH, tableViewHeight);
    
    self.frame = CGRectMake(0.f, SCREENHEIGHT, SCREENWIDTH, tableViewHeight);
    DWQWeak;
    [UIView animateWithDuration:.25f animations:^{
        weakSelf.frame = CGRectMake(0.f, SCREENHEIGHT - tableViewHeight, SCREENWIDTH, tableViewHeight);
    }];
}

- (void)fadeOut
{
    DWQWeak;
    [UIView animateWithDuration:.25f animations:^{
        weakSelf.frame = CGRectMake(0.f, SCREENHEIGHT, SCREENWIDTH, CGRectGetHeight(weakSelf.frame));
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf.overlayControl removeFromSuperview];
            weakSelf.overlayControl = nil;
            [weakSelf removeFromSuperview];
        }
    }];
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    CGFloat tableViewHeight       = MIN(SCREENHEIGHT - 64.f, self.tableView.contentSize.height);
    self.tableView.frame      = CGRectMake(0.f, 0.f, SCREENWIDTH, tableViewHeight);
    self.frame                = CGRectMake(0.f, SCREENHEIGHT - tableViewHeight, SCREENWIDTH, tableViewHeight);
}

- (void)show
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self.overlayControl];
    [keywindow addSubview:self];
    [self fadeIn];
}

- (void)dwq_dismissDWQActionSheet
{
    NSLog(@"【 DWQActionSheet 】你触摸了背景隐藏！");
    [self fadeOut];
}

#pragma mark - lazy
- (UITableView *)tableView
{
    if ( !_tableView )
    {
        _tableView                 = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate        = self;
        _tableView.dataSource      = self;
        _tableView.scrollEnabled   = NO;
        _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.f];
        [self addSubview:_tableView];
        [_tableView registerNib:[UINib nibWithNibName:DWQASCellIdentifier bundle:nil] forCellReuseIdentifier:DWQASCellIdentifier];
    }
    return _tableView;
}

- (UIControl *)overlayControl
{
    if ( !_overlayControl )
    {
        _overlayControl                 = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _overlayControl.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.5];
        [_overlayControl addTarget:self action:@selector(dwq_dismissDWQActionSheet) forControlEvents:UIControlEventTouchUpInside];
        _overlayControl.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _overlayControl;
}

@end
