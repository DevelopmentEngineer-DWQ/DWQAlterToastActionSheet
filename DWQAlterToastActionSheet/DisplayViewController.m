//
//  DisplayViewController.m
//  DWQAlterToastActionSheet
//
//  Created by 杜文全 on 16/11/24.
//  Copyright © 2016年 杜文全. All rights reserved.
//
//
#define SCREENWIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT   [UIScreen mainScreen].bounds.size.height
#import "DisplayViewController.h"
#import "DWQAlert.h"
#import "DWQActionSheet.h"
#import "DWQToastCenter.h"

@interface DisplayViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) DWQAlert        *alertView1;
@property (nonatomic, strong) DWQAlert        *alertView2;
@property (nonatomic, strong) DWQAlert        *alertView3;
@property (nonatomic, strong) DWQAlert        *alertView4;
@property (nonatomic, strong) DWQAlert        *alertView5;
@property (nonatomic, strong) UIView         *viewPwdBgView;
@property (nonatomic, strong) UITextField    *pwdTextField;

@property (nonatomic, strong) DWQActionSheet  *actionSheet1;
@property (nonatomic, strong) DWQActionSheet  *actionSheet2;
@property (nonatomic, strong) DWQActionSheet  *actionSheet3;
@end

@implementation DisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self createUI];
  
    
}
-(void)createUI{
    self.title=@"Alter-Toast-ActionSheet";
    
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0,SCREENWIDTH, 30)];
    
    label.text=@"DWQAlter";
    self.tableview.tableHeaderView=label;

}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0){
        return 5;
    }else if (section==1){
    
        return 3;
    }else{
    
    return 2;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSArray *titleArray1=@[@"包含多个确定按钮的Alter",@"可自定义按钮颜色的Alter",@"可自定义背景的Alter",@"包含图片和文字的Alter",@"自定义控件的Alter"];
    
    NSArray *titleArray2=@[@"类似系统的ActionSheet",@"带标题的ActionSheet",@"带标题和图片的ActionSheet"];
    
    NSArray *titleArray3=@[@"文字toast",@"带图片的toast"];
    
    
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
//    if(cell==nil){
//        
//        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      reuseIdentifier:@"cell"];
    
        if (indexPath.section==0) {
            cell.textLabel.text=titleArray1[indexPath.row];
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
        }else if (indexPath.section==1){
        
            cell.textLabel.text=titleArray2[indexPath.row];
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
        }else{
        
            cell.textLabel.text=titleArray3[indexPath.row];
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
         }
       
//    }
    
    return cell;


}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   if (section==1){
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0,SCREENWIDTH, 20)];
      
        label.text=@"DWQActionSheet";
        return label;
    }else{
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0,SCREENWIDTH, 20)];
    
        label.text=@"DWQToast";
        return label;
    
    }

    
   
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if ( indexPath.row==0){
            [self alertSameToSystem];
            
        }else if (indexPath.row==1){
            [self alertWithCustomColorOfButton];
            
        }else if (indexPath.row==2){
            
            [self alertWithBackgroundImage];
        }else if (indexPath.row==3){
            
            [self alertWithImageAndText];
        }else if (indexPath.row==4){
            
            [self alertWithCustom];
        }

    }else if (indexPath.section==1){
    
        if ( indexPath.row==0){
            [self dwqActionSheet1];
            
        }else if (indexPath.row==1){
            [self dwqActionSheet2];
            
        }else {
            
            [self dwqActionSheet3];
        }
    
    }else{
        if ( indexPath.row==0){
            [[DWQToastCenter defaultCenter]postToastWithMessage:@"ios高级开发工程师-杜文全"];
            
        }else if (indexPath.row==1){
            [[DWQToastCenter defaultCenter] postToastWithMessage:@"ios高级开发工程师-杜文全" image:[UIImage imageNamed:@"DWQ-LOGO.jpeg"]];
            
        }
    
    }
    

}
#pragma mark altert方法汇总
- (void)alertSameToSystem
{
    
    /*! 第一种封装使用示例 */
    [DWQAlert dwq_showAlertWithTitle:@"杜文全提示：：" message:@"iOS是由苹果公司开发的移动操作系统[1]  。苹果公司最早于2007年1月9日的Macworld大会上公布这个系统，最初是设计给iPhone使用的，后来陆续套用到iPod touch、iPad以及Apple TV等产品上。" image:nil buttonTitles:@[@"取消",@"第一个确定",@"第二个确定",@"第三个确定"] buttonTitlesColor:@[[UIColor redColor], [UIColor blueColor], [UIColor grayColor], [UIColor purpleColor]] configuration:^(DWQAlert *temp) {
        
        //        temp.bgColor       = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0.3];
        /*! 开启边缘触摸隐藏alertView */
        temp.isTouchEdgeHide = YES;
        /*! 添加高斯模糊的样式 , [UIColor purpleColor]*/
        temp.blurEffectStyle = DWQAlertBlurEffectStyleLight;
        /*! 开启动画 */
        //        temp.isShowAnimate   = YES;
        //        /*! 进出场动画样式 默认为：1 */
        //        temp.animatingStyle  = 1;
    }actionClick:^(NSInteger index) {
        if (index == 0)
        {
            NSLog(@"点击了取消按钮！");
            /*! 隐藏alert */
            //            [weakSelf.alertView1 dwq_dismissAlertView];
        }
        else if (index == 1)
        {
            NSLog(@"点击了确定按钮！");
           
            /*! 隐藏alert */
            //            [weakSelf.alertView1 dwq_dismissAlertView];
        }
    }];
    
    /*! 第二种常用方法使用示例 */
    
    //    /*! 1、类似系统alert【加边缘手势消失】 */
    //    _alertView1 = [[DWQAlert alloc] dwq_showTitle:@"温馨提示："
    //
    //                                                    image:nil
    //                                             buttonTitles:@[@"取消", @"确定"]];
    //    _alertView1.bgColor = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0.3];
    //    /*! 是否开启边缘触摸隐藏 alert */
    //    _alertView1.isTouchEdgeHide = YES;
    //    /*! 显示alert */
    //    [_alertView1 dwq_showAlertView];
    //
    //    DWQWeak;
    //    _alertView1.buttonActionBlock = ^(NSInteger index){
    //        if (index == 0)
    //        {
    //            NSLog(@"点击了取消按钮！");
    //            /*! 隐藏alert */
    ////            [weakSelf.alertView1 dwq_dismissAlertView];
    //        }
    //        else if (index == 1)
    //        {
    //            NSLog(@"点击了确定按钮！");
    //            ViewController2 *vc2 = [ViewController2 new];
    //            vc2.title = @"alert1";
    //            [weakSelf.navigationController pushViewController:vc2 animated:YES];
    //            /*! 隐藏alert */
    ////            [weakSelf.alertView1 dwq_dismissAlertView];
    //        }
    //    };
}

- (void)alertWithCustomColorOfButton
{
    /*! 2、自定义按钮颜色 */
    _alertView2                  = [[DWQAlert alloc] dwq_showTitle:@"杜文全提示："
                                                         message:@"您可以自定义按钮的颜色哦"
                                                           image:nil
                                                    buttonTitles:@[@"取消", @"确定"] buttonTitlesColor:@[[UIColor redColor], [UIColor greenColor]]];
    /*! 自定义按钮文字颜色 */
    //    _alertView2.buttonTitleColor = [UIColor orangeColor];
    //_alertView2.bgColor = [UIColor colorWithRed:1.0 green:1.0 blue:0 alpha:0.3];
    
    /*! 是否开启进出场动画 默认：NO，如果 YES ，并且同步设置进出场动画枚举为默认值：1 */
    _alertView2.showAnimate = YES;
    
    /*! 显示alert */
    [_alertView2 dwq_showAlertView];
    DWQWeak;
    _alertView2.buttonActionBlock = ^(NSInteger index){
        if (index == 0)
        {
            NSLog(@"点击了取消按钮！");
            /*! 隐藏alert */
            [weakSelf.alertView2 dwq_dismissAlertView];
        }
        else if (index == 1)
        {
            NSLog(@"点击了确定按钮！");
            
            /*! 隐藏alert */
            //            [weakSelf.alertView2 dwq_dismissAlertView];
        }
    };
}

- (void)alertWithBackgroundImage
{
    /*! 3、自定义背景图片 */
    _alertView3                  = [[DWQAlert alloc] dwq_showTitle:@"杜文全提示："
                                                         message:@"016年1月，随着9.2.1版本的发布，苹果修复了一个存在了3年的漏洞。该漏洞在iPhone或iPad用户在酒店或者机场等访问带强制门户的网络时，登录页面会通过未加密的HTTP连接显示网络使用条款。"
                                                           image:nil
                                                    buttonTitles:@[@"取消", @"确定"]buttonTitlesColor:@[[UIColor redColor], [UIColor greenColor]]];
    /*! 自定义按钮文字颜色 */
    //    _alertView3.buttonTitleColor = [UIColor orangeColor];
    /*! 自定义alert的背景图片 */
    _alertView3.bgImageName      = @"DWQ-LOGO.jpeg";
    /*! 开启动画，并且设置动画样式，默认：1 */
    //    _alertView3.isShowAnimate = YES;
    
    /*! 没有开启动画，直接进出场动画样式，默认开启动画 */
    _alertView3.animatingStyle  = DWQAlertAnimatingStyleFall;
    
    /*! 显示alert */
    [_alertView3 dwq_showAlertView];

    _alertView3.buttonActionBlock = ^(NSInteger index){
        if (index == 0)
        {
            NSLog(@"点击了取消按钮！");
            /*! 隐藏alert */
            //            [weakSelf.alertView3 dwq_dismissAlertView];
        }
        else if (index == 1)
        {
           
            /*! 隐藏alert */
            //            [weakSelf.alertView3 dwq_dismissAlertView];
        }
    };
}

- (void)alertWithImageAndText
{
    /*! 4、内置图片和文字，可滑动查看 */
    _alertView4                  = [[DWQAlert alloc] dwq_showTitle:@"温馨提示："
                                                           message:@"苹果至今仍没有宣布任何让iPhone运行Java的计划。但太阳微系统已宣布其将会发布能在iPhone上运行的Java虚拟机(JVM)的计划它是基于Java的Micro Edition版本"
                                                           image:[UIImage imageNamed:@"短裤.jpg"]
                                                    buttonTitles:@[@"取消", @"确定"] buttonTitlesColor:@[[UIColor redColor], [UIColor greenColor]]];
    /*! 自定义按钮文字颜色 */
    //    _alertView4.buttonTitleColor = [UIColor orangeColor];
    /*! 自定义alert的背景图片 */
   // _alertView4.bgImageName      = @"DWQ-LOGO.jpeg";
    /*! 是否显示动画效果 */
    _alertView4.showAnimate    = YES;
    /*! 显示alert */
    [_alertView4 dwq_showAlertView];
    DWQWeak;
    _alertView4.buttonActionBlock = ^(NSInteger index){
        if (index == 0)
        {
            NSLog(@"点击了取消按钮！");
            /*! 隐藏alert */
            //            [weakSelf.alertView4 dwq_dismissAlertView];
        }
        else if (index == 1)
        {
            NSLog(@"点击了确定按钮！");
           
            /*! 隐藏alert */
            //            [weakSelf.alertView4 dwq_dismissAlertView];
        }
    };
}

- (void)alertWithCustom
{
    /*! 5、完全自定义alert */
    
    /*! 纯代码加载方式  【建议用 xib 方式】*/
    /*! 用纯代码的时候，记得这里的自定义 View 不能用懒加载，要不然点击第二次就不会在出现那个自定义 View 了 */
    [self setViewPwdBgView];
    //    self.viewPwdBgView.hidden = NO;
    //    _alertView5                  = [[DWQAlert alloc] initWithCustomView:self.viewPwdBgView];
    //    _alertView5.isTouchEdgeHide = YES;
    //    _alertView5.showAnimate = YES;
    //    [_alertView5 dwq_showAlertView];
    
    DWQWeak;
    [DWQAlert dwq_showCustomView:self.viewPwdBgView configuration:^(DWQAlert *tempView) {
        tempView.isTouchEdgeHide = YES;
        tempView.animatingStyle = DWQAlertAnimatingStyleScale;
        weakSelf.alertView5 = tempView;
    }];
    
    /*! xib 加载方式 【建议用 xib 方式】*/
    //    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"VerCodeAlertView" owner:self options:nil];
    //    UIView *view1 = nib[0];
    //    [DWQAlert dwq_showCustomView:view1 configuration:^(DWQAlert *tempView) {
    //        tempView.isTouchEdgeHide = YES;
    //        tempView.animatingStyle = DWQAlertAnimatingStyleScale;
    //        weakSelf.alertView5 = tempView;
    //    }];
}

- (void)setViewPwdBgView
{
    //    if (!_viewPwdBgView)
    //    {
    _viewPwdBgView                         = [UIView new];
    _viewPwdBgView.frame                   = CGRectMake(30, 100, SCREENWIDTH - 60, 160);
    
    _viewPwdBgView.backgroundColor         = [UIColor whiteColor];
    _viewPwdBgView.layer.masksToBounds     = YES;
    _viewPwdBgView.layer.cornerRadius      = 10.0f;
    
    CGFloat buttonWith                     = (SCREENWIDTH - 60)/2 - 0.5;
    CGFloat buttonHeight                   = 40;
    
    UILabel *titleLabel                    = [UILabel new];
    titleLabel.frame                       = CGRectMake(0, 0, _viewPwdBgView.frame.size.width, buttonHeight);
    titleLabel.text                        = @"请输入密码";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.font                        = [UIFont systemFontOfSize:18];
    titleLabel.backgroundColor             = [UIColor clearColor];
    
    UIView *lineView1                      = [UIView new];
    lineView1.frame                        = CGRectMake(0, CGRectGetMaxY(titleLabel.frame), _viewPwdBgView.frame.size.width, 1);
    lineView1.backgroundColor              = [UIColor lightGrayColor];
    
    _pwdTextField                          = [UITextField new];
    _pwdTextField.frame                    = CGRectMake(20, CGRectGetMaxY(lineView1.frame) + 20, _viewPwdBgView.frame.size.width - 40, buttonHeight);
    _pwdTextField.borderStyle              = UITextBorderStyleRoundedRect;
    _pwdTextField.keyboardType             = UIKeyboardTypeNumberPad;
    _pwdTextField.secureTextEntry          = YES;
    _pwdTextField.textAlignment            = NSTextAlignmentCenter;
    _pwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //        _pwdTextField.autoresizingMask         = UIViewAutoresizingFlexibleWidth;
    [_pwdTextField becomeFirstResponder];
    
    UIView *lineView2                      = [UIView new];
    lineView2.frame                        = CGRectMake(0, _viewPwdBgView.frame.size.height - 41, _viewPwdBgView.frame.size.width, 1);
    lineView2.backgroundColor              = [UIColor lightGrayColor];
    
    UIButton *cancleButton                 = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView2.frame), buttonWith, buttonHeight)];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton setBackgroundColor:[UIColor clearColor]];
    [cancleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(cancleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //        cancleButton.autoresizingMask          = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    UIView *lineView3                      = [UIView new];
    lineView3.frame                        = CGRectMake(buttonWith, CGRectGetMinY(cancleButton.frame), 1, buttonHeight);
    lineView3.backgroundColor              = [UIColor lightGrayColor];
    
    UIButton *sureButton                   = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lineView3.frame), CGRectGetMinY(cancleButton.frame), buttonWith, buttonHeight)];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setBackgroundColor:[UIColor clearColor]];
    [sureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(cancleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //        sureButton.autoresizingMask            = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    cancleButton.tag                       = 1;
    sureButton.tag                         = 2;
    
    [_viewPwdBgView addSubview:titleLabel];
    [_viewPwdBgView addSubview:lineView1];
    [_viewPwdBgView addSubview:_pwdTextField];
    [_viewPwdBgView addSubview:lineView2];
    [_viewPwdBgView addSubview:cancleButton];
    [_viewPwdBgView addSubview:lineView3];
    [_viewPwdBgView addSubview:sureButton];
    
    //        //这里是让titleLabel跟父view上左右边距为0,底部间距不设置
    //        [titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    //        //设置titleLabel的高度为buttonHeight
    //        [titleLabel autoSetDimension:ALDimensionHeight toSize:buttonHeight];
    //
    //        //设置lineView1与父view左右间距为0,顶部和titleLabel的底部间距为0,高度为1
    //        [lineView1 autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_viewPwdBgView];
    //        [lineView1 autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_viewPwdBgView];
    //        [lineView1 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel];
    //        [lineView1 autoSetDimension:ALDimensionHeight toSize:1.0];
    //
    //        //设置_pwdTextField与父view左右间距为20,顶部和lineView1的底部间距为20,高度为buttonHeight
    //        [_pwdTextField autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_viewPwdBgView withOffset:20];
    //        [_pwdTextField autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_viewPwdBgView withOffset:-20];
    //        [_pwdTextField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lineView1 withOffset:20];
    //        [_pwdTextField autoSetDimension:ALDimensionHeight toSize:buttonHeight];
    //
    //        //这里是让lineView2跟父view上左右边距为0,顶部间距不设置,底部跟父view间距41,高度为buttonHeight
    //        [lineView2 autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 41.0, 0) excludingEdge:ALEdgeTop];
    //        [lineView2 autoSetDimension:ALDimensionHeight toSize:1.0];
    //
    //        //设置cancleButton与父view左底间距为0,高度为buttonHeight,宽度为buttonWith
    //        [cancleButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_viewPwdBgView];
    //        [cancleButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_viewPwdBgView];
    //        [cancleButton autoSetDimension:ALDimensionHeight toSize:buttonHeight];
    //
    //        //设置lineView3与父view底间距为0,高度为buttonHeight,左边与cancelButton的右间距为0,宽度为1
    //        [lineView3 autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:cancleButton];
    //        [lineView3 autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_viewPwdBgView];
    //        [lineView3 autoSetDimension:ALDimensionHeight toSize:buttonHeight];
    //        [lineView3 autoSetDimension:ALDimensionWidth toSize:1];
    //
    //        //设置sureButton与父view底右间距为0,高度为buttonHeight,左边与cancelButton的右间距为0
    //        [sureButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lineView3];
    //        [sureButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_viewPwdBgView];
    //        [sureButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_viewPwdBgView];
    //        [sureButton autoSetDimension:ALDimensionHeight toSize:buttonHeight];
    //        [sureButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:cancleButton];
    
    //    }
    //    return _viewPwdBgView;
}



#pragma mark DWQActionSheet方法汇总

-(void)dwqActionSheet1{
 DWQWeak;
    [DWQActionSheet dwq_showActionSheetWithStyle:DWQCustomActionSheetStyleNormal
                                  contentArray:@[@"ios",@"objective-c",@"swift"]
                                    imageArray:nil
                                      redIndex:1
                                         title:nil
                                 configuration:^(DWQActionSheet *tempView) {
                                     weakSelf.actionSheet1 = tempView;
                                 } ClikckButtonIndex:^(NSInteger index) {
                                     NSLog(@"你点击了第 %ld 行！",(long)index);
                                     [weakSelf.actionSheet1 dwq_dismissDWQActionSheet];
                                 }];


}
-(void)dwqActionSheet2{
    DWQWeak;
    [DWQActionSheet dwq_showActionSheetWithStyle:DWQCustomActionSheetStyleTitle
                                  contentArray:@[@"ios",@"objective-c",@"swift"]
                                    imageArray:nil
                                      redIndex:1
                                         title:@"带标题的ActionSheet"
                                 configuration:^(DWQActionSheet *tempView) {
                                     weakSelf.actionSheet1 = tempView;
                                 } ClikckButtonIndex:^(NSInteger index) {
                                     NSLog(@"你点击了第 %ld 行！",(long)index);
                                     [weakSelf.actionSheet1 dwq_dismissDWQActionSheet];
                                 }];
    
}
-(void)dwqActionSheet3{
    DWQWeak;
    [DWQActionSheet dwq_showActionSheetWithStyle:DWQCustomActionSheetStyleImageAndTitle
                                  contentArray:@[@"ios",@"objective-c",@"swift"]
                                    imageArray:@[[UIImage imageNamed:@"杜文全背景.png"],[UIImage imageNamed:@"DWQ-LOGO.jpeg"],[UIImage imageNamed:@"短裤.jpg"]]
                                      redIndex:1
                                         title:@"带标题和图片的ActionSheet"
                                 configuration:^(DWQActionSheet *tempView) {
                                     weakSelf.actionSheet1 = tempView;
                                 } ClikckButtonIndex:^(NSInteger index) {
                                     NSLog(@"你点击了第 %ld 行！",(long)index);
                                     [weakSelf.actionSheet1 dwq_dismissDWQActionSheet];
                                 }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancleButtonAction:(UIButton *)sender
{
    if (sender.tag == 1)
    {
        NSLog(@"点击了取消按钮！");
        /*! 隐藏alert */
        [_alertView5 dwq_dismissAlertView];
        [_pwdTextField resignFirstResponder];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSLog(@"点击了确定按钮！密码：%@", _pwdTextField.text);
        
        //        WEAKSELF;
        if (_pwdTextField.text.length < 4 || _pwdTextField.text.length > 8 )
        {
            self.pwdTextField.text = @"";
            [DWQAlert dwq_showAlertWithTitle:@"温馨提示：" message:@"请输入正确的密码！" image:nil buttonTitles:@[@"确定"] buttonTitlesColor:@[[UIColor redColor], [UIColor cyanColor]] configuration:^(DWQAlert *tempView) {
                //                weakSelf.alert2 = tempView;
            } actionClick:^(NSInteger index) {
                if (1 == index)
                {
                    return;
                }
            }];
            return;
        }
        /*! 隐藏alert */
        [_alertView5 dwq_dismissAlertView];
        [_pwdTextField resignFirstResponder];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardwqegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
