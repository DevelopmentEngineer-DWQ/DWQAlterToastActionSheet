# DWQAlterToastActionSheet
集成Alter，ActionSheet,类似安卓的Toast的框架，方便调用，形式多样
![DWQ-LOGO.jpeg](http://upload-images.jianshu.io/upload_images/2231137-1545493cd60adb2b.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##引述
  不管是在iOS 开发还是在安卓开发，或者WebAPP开发中，有一个小功能是不可忽略的存在，它的存在，大大友好了用户体验。那就是弹框Altert，类似安卓的Toast提醒等。由于很多设计已经不满足于系统自带的各种弹框样式，由于本人开发的众多APP也使用了各式各样的弹框，为了方便以后使用，我对Altert，ActionSheet，Toast进行了封装，您只需要用类方法调用即可。

##DWQAlterToastActionSheet组成
  
![DWQATS.png](http://upload-images.jianshu.io/upload_images/2231137-3b062d4c65f48ae3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 1.DWQActionSheet    :actionSheet的封装类

- 2.DWQALter            ：altert的封装类

- 3.DWQToastView    ：类似安卓toast的封装类

##DWQAlterToastActionSheet使用方式

- 1.将DWQAlterToastActionSheet拖入工程中

- 2.如果使用Toast，在需要的地方引入头文件
"DWQToastCenter.h"，如果需要使用ActionSheet，需要引入头文件
 "DWQActionSheet.h"，如果需要使用Altert，需要引入头文件"DWQAltert.h"

- 3.Toast 调用分为纯文字和带图片两中，示例如下：

```objective-c
1.[[DWQToastCenter defaultCenter]postToastWithMessage:@"ios高级开发工程师-杜文全"];

2.[[DWQToastCenter defaultCenter] postToastWithMessage:@"ios高级开发工程师-杜文全" image:[UIImage imageNamed:@"DWQ-LOGO.jpeg"]];

```
- 4.DWQActionSheet调用方式只有一种，通过传不同的参数来形成各种样式。示例代码如下：

```objective-c
+ (void)dwq_showActionSheetWithStyle:(DWQCustomActionSheetStyle)style
                       contentArray:(NSArray<NSString *> *)contentArray
                         imageArray:(NSArray<UIImage *> *)imageArray
                           redIndex:(NSInteger)redIndex
                              title:(NSString *)title
                      configuration:(void (^)(DWQActionSheet *tempView)) configuration
                  ClikckButtonIndex:(ButtonActionBlock)clikckButtonIndex;
```

- 5.DWQAltert调用方式有四种，通过传参数搭配组合可形成多种样式的弹框警告。具体可查看Demo。代码示例如下：

```objective-c
- (instancetype)dwq_showTitle:(NSString *)title
                     message:(NSString *)message
                       image:(UIImage *)image
                buttonTitles:(NSArray *)buttonTitles
           buttonTitlesColor:(NSArray <UIColor *>*)buttonTitlesColor;

/*!
 *  视图显示
 */
- (void)dwq_showAlertView;

/*!
 *  视图消失
 */
- (void)dwq_dismissAlertView;
```
##DWQAlterToastActionSheet效果展示



![DWQATS效果展示.gif](http://upload-images.jianshu.io/upload_images/2231137-93367afa2a69e900.gif?imageMogr2/auto-orient/strip)


##DWQAlterToastActionSheet下载地址
[DWQAlterToastActionSheetDemo](https://github.com/DevelopmentEngineer-DWQ/DWQAlterToastActionSheet)
