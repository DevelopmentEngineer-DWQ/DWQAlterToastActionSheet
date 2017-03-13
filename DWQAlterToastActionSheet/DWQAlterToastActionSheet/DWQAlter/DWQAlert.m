//
//  DWQAlter.m
//  DWQAlterToastActionSheet
//
//  Created by 杜文全 on 16/11/24.
//  Copyright © 2016年 杜文全. All rights reserved.


#import "DWQAlert.h"
#import <Accelerate/Accelerate.h>
#import <float.h>
#import "CALayer+Animation.h"
#import "UIView+AutoLayout.h"
@interface UIImage (DWQAlertImageEffects)

- (UIImage*)DWQAlert_ApplyLightEffect;

- (UIImage*)DWQAlert_ApplyExtraLightEffect;

- (UIImage*)DWQAlert_ApplyDarkEffect;

- (UIImage*)DWQAlert_ApplyTintEffectWithColor:(UIColor*)tintColor;

- (UIImage*)DWQAlert_ApplyBlurWithRadius:(CGFloat)blurRadius
                              tintColor:(UIColor*)tintColor
                  saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                              maskImage:(UIImage*)maskImage;
@end
@implementation UIImage (DWQAlertImageEffects)
- (UIImage *)DWQAlert_ApplyLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    return [self DWQAlert_ApplyBlurWithRadius:1.3 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)DWQAlert_ApplyExtraLightEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self DWQAlert_ApplyBlurWithRadius:2 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)DWQAlert_ApplyDarkEffect
{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self DWQAlert_ApplyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)DWQAlert_ApplyTintEffectWithColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.45;
    UIColor *effectColor = tintColor;
    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self DWQAlert_ApplyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}

- (UIImage *)DWQAlert_ApplyBlurWithRadius:(CGFloat)blurRadius
                               tintColor:(UIColor *)tintColor
                   saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                               maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1)
    {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage)
    {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage)
    {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (int)radius, (int)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (int)radius, (int)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (int)radius, (int)radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // 开启上下文 用于输出图像
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // 开始画底图
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // 开始画模糊效果
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // 添加颜色渲染
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // 输出成品,并关闭上下文
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end



#define DWQAlertWidth              self.viewWidth - 50
#define DWQAlertPaddingV           11
#define DWQAlertPaddingH           18
#define DWQAlertRadius             13
#define DWQAlertButtonHeight       40

/*! RGB色值 */
#define DWQ_COLOR(R, G, B, A)       [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

@interface DWQAlert ()

@property (nonatomic,strong         ) UIView                  *subView;
@property (nonatomic, strong        ) UITapGestureRecognizer  *dismissTap;

@property (copy, nonatomic, readonly) NSString                *title;
@property (copy, nonatomic, readonly) NSString                *message;
@property (copy, nonatomic, readonly) UIImage                 *image;
@property (copy, nonatomic, readonly) NSArray                 *buttonTitles;
@property (copy, nonatomic, readonly) NSArray                 *buttonTitlesColor;

@property (strong, nonatomic        ) UIImageView             *containerView;
@property (strong, nonatomic        ) UIScrollView            *scrollView;
@property (strong, nonatomic        ) UILabel                 *titleLabel;
@property (strong, nonatomic        ) UIImageView             *imageView;
@property (strong, nonatomic        ) UILabel                 *messageLabel;
@property (strong, nonatomic        ) NSMutableArray          *buttons;
@property (strong, nonatomic        ) NSMutableArray          *lines;
@property (strong, nonatomic        ) UIImageView             *blurImageView;


@property (assign, nonatomic        ) CGFloat                  viewWidth;
@property (assign, nonatomic        ) CGFloat                  viewHeight;

@property (strong, nonatomic) NSArray *selfContainsArray;

@property (nonatomic, assign, getter=isAnimating) BOOL animating;

@end

@implementation DWQAlert
{
    CGFloat  _scrollBottom;
    CGFloat  _buttonsHeight;
    CGFloat  _maxContentWidth;
    CGFloat  _maxAlertViewHeight;
}

#pragma mark - ***** 初始化自定义View
- (instancetype)initWithCustomView:(UIView *)customView
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self.subView = customView;
        self.subView.translatesAutoresizingMaskIntoConstraints = false;
        [self performSelector:@selector(setupUI)];
    }
    return self;
}

#pragma mark - ***** 创建一个类似系统的警告框
- (instancetype)dwq_showTitle:(NSString *)title
                     message:(NSString *)message
                       image:(UIImage *)image
                buttonTitles:(NSArray *)buttonTitles
           buttonTitlesColor:(NSArray <UIColor *>*)buttonTitlesColor
{
    self.viewWidth    = SCREENWIDTH;
    self.viewHeight   = SCREENHEIGHT;
    
    if (self == [super initWithFrame:CGRectMake(0, 0, DWQAlertWidth, 0)])
    {
        _title             = [title copy];
        _image             = image;
        _message           = [message copy];
        _buttonTitles      = [NSArray arrayWithArray:buttonTitles];
        _buttonTitlesColor = [NSArray arrayWithArray:buttonTitlesColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrames:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [self performSelector:@selector(loadUI)];
    }
    return self;
}

- (void)loadUI
{
    _buttons                                      = @[].mutableCopy;
    _lines                                        = @[].mutableCopy;
    
    _containerView                                = [UIImageView new];
    _containerView.        userInteractionEnabled = YES;
    _containerView.layer.  cornerRadius           = DWQAlertRadius;
    _containerView.layer.  masksToBounds          = YES;
    _containerView.        backgroundColor        = [UIColor whiteColor];
    
    _scrollView                                   = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.           backgroundColor        = [UIColor whiteColor];
    [_containerView addSubview:_scrollView];
    
    [self addSubview:_containerView];
    
    
    [self performSelector:@selector(setupCommonUI)];
}

#pragma mark - ***** 加载自定义View
- (void)setupUI
{
    self.viewWidth                   = SCREENWIDTH;
    self.viewHeight                  = SCREENHEIGHT;
    
    self.frame                       = [UIScreen mainScreen].bounds;
    self.backgroundColor             = self.bgColor;
    
    self.subView.layer.shadowColor   = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    self.subView.layer.shadowOffset  = CGSizeZero;
    self.subView.layer.shadowOpacity = 1;
    self.subView.layer.shadowRadius  = 10.0f;
    self.subView.layer.borderWidth   = 0.5f;
    self.subView.layer.borderColor   = DWQ_COLOR(110, 115, 120, 1).CGColor;
    
    
    [self addSubview:self.subView];
    
    if ( !self.subView.translatesAutoresizingMaskIntoConstraints ) {
        [self.subView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.subView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        [self.subView autoSetDimension:ALDimensionHeight toSize:CGRectGetHeight(self.subView.frame)];
        
        [self.subView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:30 relation:NSLayoutRelationEqual];
        [self.subView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30 relation:NSLayoutRelationEqual];
        [self.subView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:50 relation:NSLayoutRelationGreaterThanOrEqual];
        [self.subView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:50 relation:NSLayoutRelationGreaterThanOrEqual];
    }
    
    [self performSelector:@selector(setupCommonUI)];
}

#pragma mark - ***** 公共方法
- (void)setupCommonUI
{
    /*! 设置默认的模糊背景样式为：DSAlertBlurEffectStyleLight */
    _blurEffectStyle = DWQAlertBlurEffectStyleLight;
    
    /*! 添加手势 */
    [self addGestureRecognizer:self.dismissTap];
    
    /*! 旋转屏幕通知 */
    //        [[NSNotificationCenter defaultCenter] addObserver:self
    //                                                 selector:@selector(changeFrames:)
    //                                                     name:UIDeviceOrientationDidChangeNotification
    //                                                   object:nil];
    
}

#pragma mark - ***** setter / getter
- (UITapGestureRecognizer *)dismissTap
{
    if (!_dismissTap)
    {
        _dismissTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTapAction:)];
    }
    return _dismissTap;
}

- (UIColor *)bgColor
{
    if (_bgColor == nil)
    {
        _bgColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    }
    return _bgColor;
}

- (UIImageView *)blurImageView
{
    if ( !_blurImageView )
    {
        _blurImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _blurImageView.image = [self screenShotImage];
        _blurImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _blurImageView.contentMode = UIViewContentModeScaleAspectFit;
        _blurImageView.clipsToBounds = true;
        _blurImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_blurImageView];
        [self sendSubviewToBack:_blurImageView];
    }
    return _blurImageView;
}

//- (void)setButtonTitleColor:(UIColor *)buttonTitleColor
//{
//    _buttonTitleColor = buttonTitleColor;
//}

- (void)setBgImageName:(NSString *)bgImageName
{
    _bgImageName                   = bgImageName;
    
    _containerView.backgroundColor = [UIColor clearColor];
    _scrollView.backgroundColor    = [UIColor clearColor];
    _containerView.image           = [UIImage imageNamed:bgImageName];
    _containerView.contentMode     = UIViewContentModeScaleAspectFill;
}

- (void)setIsTouchEdgeHide:(BOOL)isTouchEdgeHide
{
    _isTouchEdgeHide = isTouchEdgeHide;
}

- (void)setShowAnimate:(BOOL)showAnimate
{
    _showAnimate = showAnimate;
}

- (void)setBlurEffectStyle:(DWQAlertBlurEffectStyle)blurEffectStyle
{
    _blurEffectStyle = blurEffectStyle;
    
    if (self.blurEffectStyle == DWQAlertBlurEffectStyleLight)
    {
        self.blurImageView.image = [self.blurImageView.image DWQAlert_ApplyLightEffect];
    }
    else if (self.blurEffectStyle == DWQAlertBlurEffectStyleExtraLight)
    {
        self.blurImageView.image = [self.blurImageView.image DWQAlert_ApplyExtraLightEffect];
    }
    else if (self.blurEffectStyle == DWQAlertBlurEffectStyleDark)
    {
        self.blurImageView.image = [self.blurImageView.image DWQAlert_ApplyDarkEffect];
    }
    
    //    [self imageOutPut:^(UIImage *image) {
    //        self.blurImageView.image = image;
    //    }];
}

- (void)setAnimatingStyle:(DWQAlertAnimatingStyle)animatingStyle
{
    _animatingStyle = animatingStyle;
}

- (void)setUseAutoresizing:(BOOL)UseAutoresizing {
    _UseAutoresizing = UseAutoresizing;
    
    self.subView.translatesAutoresizingMaskIntoConstraints = UseAutoresizing;
}

#pragma mark - **** 手势消失方法
- (void)dismissTapAction:(UITapGestureRecognizer *)tapG
{
    NSLog(@"触摸了边缘隐藏View！");
    if (self.isTouchEdgeHide)
    {
        [self performSelector:@selector(dwq_dismissAlertView)];
    }
    else
    {
        NSLog(@"触摸了View边缘，但您未开启触摸边缘隐藏方法，请设置 isTouchEdgeHide 属性为 YES 后再使用！");
    }
}

#pragma mark - **** 视图显示方法
- (void)dwq_showAlertView
{
    DWQWeak;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    if ( !self.subView.translatesAutoresizingMaskIntoConstraints ) {
        [self autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    }else {
        
    }
    
    [self layoutMySubViews];
    
    /*! 设置默认样式为： */
    if (self.isShowAnimate)
    {
        _animatingStyle = DWQAlertAnimatingStyleScale;
    }
    /*! 如果没有开启动画，就直接单独写了一个动画样式 */
    else if (!self.isShowAnimate && self.animatingStyle)
    {
        self.showAnimate = YES;
        //        _animatingStyle = DSAlertAnimatingStyleScale;
    }
    else
    {
        NSLog(@"您没有开启动画，也没有设置动画样式，默认为没有动画！");
    }
    
    if (self.isShowAnimate)
    {
        if (weakSelf.subView)
        {
            [weakSelf showAnimationWithView:weakSelf.subView];
        }
        else if (self.containerView)
        {
            [weakSelf showAnimationWithView:weakSelf.containerView];
        }
    }
    else
    {
        if (self.subView)
        {
            if ( self.subView.translatesAutoresizingMaskIntoConstraints ) {
                self.subView.center = window.center;
            }else {
                
            }
        }
        else if (self.containerView)
        {
            [self performSelector:@selector(prepareForShow)];
            self.containerView.center = window.center;
        }
    }
}

#pragma mark - **** 视图消失方法
- (void)dwq_dismissAlertView
{
    
    if (self.isShowAnimate)
    {
        if (self.subView)
        {
            [self dismissAnimationView:self.subView];
        }
        else if (self.containerView)
        {
            [self dismissAnimationView:self.containerView];
        }
    }
    else
    {
        [self performSelector:@selector(removeSelf)];
        self.animating = NO;
    }
    
}

#pragma mark - 进场动画
- (void )showAnimationWithView:(UIView *)animationView
{
    self.animating = YES;
    
    DWQWeak;
    if (self.animatingStyle == DWQAlertAnimatingStyleScale)
    {
        [animationView scaleAnimationShowFinishAnimation:^{
            weakSelf.animating = NO;
        }];
    }
    else if (self.animatingStyle == DWQAlertAnimatingStyleShake)
    {
        [animationView.layer shakeAnimationWithDuration:1.0 shakeRadius:16.0 repeat:1 finishAnimation:^{
            weakSelf.animating = NO;
        }];
    }
    else if (self.animatingStyle == DWQAlertAnimatingStyleFall)
    {
        [animationView.layer fallAnimationWithDuration:0.35 finishAnimation:^{
            weakSelf.animating = NO;
        }];
    }
}

#pragma mark - 出场动画
- (void )dismissAnimationView:(UIView *)animationView
{
    DWQWeak;
    self.animating = YES;
    
    if (self.animatingStyle == DWQAlertAnimatingStyleScale)
    {
        [animationView scaleAnimationDismissFinishAnimation:^{
            [weakSelf performSelector:@selector(removeSelf)];
            weakSelf.animating = NO;
        }];
    }
    else if (self.animatingStyle == DWQAlertAnimatingStyleShake)
    {
        [animationView.layer floatAnimationWithDuration:0.35f finishAnimation:^{
            [weakSelf performSelector:@selector(removeSelf)];
            weakSelf.animating = NO;
        }];
    }
    else if (self.animatingStyle == DWQAlertAnimatingStyleFall)
    {
        [animationView.layer floatAnimationWithDuration:0.35f finishAnimation:^{
            [weakSelf performSelector:@selector(removeSelf)];
            weakSelf.animating = NO;
        }];
    }
    else
    {
        NSLog(@"您没有选择出场动画样式：animatingStyle，默认为没有动画样式！");
        [self performSelector:@selector(removeSelf)];
        self.animating = NO;
    }
    
}

#pragma mark - ***** 设置UI
- (void)prepareForShow
{
    [self performSelector:@selector(resetViews)];
    _scrollBottom           = 0;
    CGFloat insetY          = DWQAlertPaddingV;
    _maxContentWidth        = DWQAlertWidth-2*DWQAlertPaddingH;
    _maxAlertViewHeight     = self.viewHeight - 50;
    [self loadTitle];
    [self loadImage];
    [self loadMessage];
    _buttonsHeight          = DWQAlertButtonHeight*((_buttonTitles.count>2||_buttonTitles.count==0)?_buttonTitles.count:1);
    
    self.frame              = self.window.bounds;
    
    self.backgroundColor    = self.bgColor;
    
    _containerView.frame    = CGRectMake(0, 0, DWQAlertWidth, MIN(MAX(_scrollBottom+2*insetY+_buttonsHeight, 2*DWQAlertRadius+DWQAlertPaddingV), _maxAlertViewHeight));
    _scrollView.frame       = CGRectMake(0, insetY, CGRectGetWidth(_containerView.frame),MIN(_scrollBottom, CGRectGetHeight(_containerView.frame)-2*insetY-_buttonsHeight));
    _scrollView.contentSize = CGSizeMake(_maxContentWidth, _scrollBottom);
    
    [self performSelector:@selector(loadButtons)];
}

#pragma mark - 重置subviews
- (void)resetViews
{
    if (_titleLabel)
    {
        [_titleLabel removeFromSuperview];
        _titleLabel.text = @"";
    }
    if (_imageView)
    {
        [_imageView removeFromSuperview];
        _imageView.image = nil;
    }
    if (_messageLabel)
    {
        [_messageLabel removeFromSuperview];
        _messageLabel.text = @"";
    }
    if (_buttons.count > 0)
    {
        [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_buttons removeAllObjects];
    }
    if (_lines.count > 0)
    {
        [_lines makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_lines removeAllObjects];
    }
}

#pragma mark - 初始化标题
- (void)loadTitle
{
    if (!_title)
    {
        return;
    }
    if (!_titleLabel)
    {
        _titleLabel               = [UILabel new];
        _titleLabel.textColor     = [UIColor blackColor];
        _titleLabel.font          = [UIFont fontWithName:@"FontNameAmericanTypewriterBold" size:20];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
    }
    _titleLabel.text              = _title;
    [self addLabel:_titleLabel maxHeight:100];
    [self addLine:CGRectMake(DWQAlertPaddingH, _scrollBottom, _maxContentWidth, 0.5) toView:_scrollView];
    _scrollBottom += DWQAlertPaddingV;
}

#pragma mark - 初始化图片
- (void)loadImage
{
    if (!_image)
    {
        return;
    }
    if (!_imageView)
    {
        _imageView   = [UIImageView new];
    }
    _imageView.image = _image;
    CGSize size      = _image.size;
    if (size.width > _maxContentWidth)
    {
        size         = CGSizeMake(_maxContentWidth, size.height/size.width*_maxContentWidth);
    }
    _imageView.frame = CGRectMake(DWQAlertPaddingH+_maxContentWidth/2-size.width/2, _scrollBottom, size.width, size.height);
    [_scrollView addSubview:_imageView];
    
    _scrollBottom    = CGRectGetMaxY(_imageView.frame)+DWQAlertPaddingV;
}

#pragma mark - 初始化内容标签
- (void)loadMessage
{
    if (!_message)
    {
        return;
    }
    if (!_messageLabel)
    {
        _messageLabel               = [UILabel new];
        _messageLabel.textColor     = [UIColor blackColor];
        _messageLabel.font          = [UIFont systemFontOfSize:14];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
    }
    _messageLabel.text              = _message;
    [self addLabel:_messageLabel maxHeight:100000];
}

#pragma mark - 初始化按钮
- (void)loadButtons
{
    if (!_buttonTitles || _buttonTitles.count == 0)
    {
        return;
    }
    CGFloat buttonHeight = DWQAlertButtonHeight;
    CGFloat buttonWidth  = DWQAlertWidth;
    CGFloat top          = CGRectGetHeight(_containerView.frame)-_buttonsHeight;
    [self addLine:CGRectMake(0, top-0.5, buttonWidth, 0.5) toView:_containerView];
    
   // DWQWeak;
    if (_buttonTitlesColor.count)
    {
        //        [_buttonTitlesColor enumerateObjectsUsingBlock:^(UIColor *titleColor, NSUInteger idx, BOOL * _Nonnull stop) {
        
        for (NSUInteger j = 0; j < _buttonTitlesColor.count; j++)
        {
            if (1 == _buttonTitles.count)
            {
                [self addButton:CGRectMake(0, top, buttonWidth, buttonHeight) title:[_buttonTitles firstObject] tag:0  titleColor:_buttonTitlesColor[0]];
            }
            else if (2 == _buttonTitles.count)
            {
                [self addButton:CGRectMake(0, top, buttonWidth/2, buttonHeight) title:[_buttonTitles firstObject] tag:0 titleColor:_buttonTitlesColor[0]];
                [self addButton:CGRectMake(0+buttonWidth/2, top, buttonWidth/2, buttonHeight) title:[_buttonTitles lastObject] tag:1 titleColor:_buttonTitlesColor[1]];
                [self addLine:CGRectMake(0+buttonWidth/2-.5, top, 0.5, buttonHeight) toView:_containerView];
            }
            else
            {
                for (NSInteger i=0; i<_buttonTitles.count; i++)
                {
                    [self addButton:CGRectMake(0, top, buttonWidth, buttonHeight) title:_buttonTitles[i] tag:i titleColor:_buttonTitlesColor[i]];
                    top += buttonHeight;
                    if (_buttonTitles.count-1!=i)
                    {
                        [self addLine:CGRectMake(0, top, buttonWidth, 0.5) toView:_containerView];
                    }
                }
                [_lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [_containerView bringSubviewToFront:obj];
                }];
            }
            
        }
        
        
        
        //        }];
    }
    
}

#pragma mark - 添加按钮方法
- (void)addButton:(CGRect)frame title:(NSString *)title tag:(NSInteger)tag titleColor:(UIColor *)titleColor
{
    UIButton *button       = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    button.tag             = tag;
    
    if (titleColor)
    {
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    }
    else
    {
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    
    if (self.bgImageName)
    {
        [button setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [button setBackgroundImage:[self imageWithColor:DWQ_COLOR(135, 140, 145, 0.45)] forState:UIControlStateHighlighted];
    }
    else
    {
        [button setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [button setBackgroundImage:[self imageWithColor:DWQ_COLOR(135, 140, 145, 0.45)] forState:UIControlStateHighlighted];
    }
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:button];
    [_buttons addObject:button];
}

#pragma mark - 添加标签方法
- (void)addLabel:(UILabel *)label maxHeight:(CGFloat)maxHeight
{
    CGSize size   = [label sizeThatFits:CGSizeMake(_maxContentWidth, maxHeight)];
    label.frame   = CGRectMake(DWQAlertPaddingH, _scrollBottom, _maxContentWidth, size.height);
    [_scrollView addSubview:label];
    
    _scrollBottom = CGRectGetMaxY(label.frame)+DWQAlertPaddingV;
}

#pragma mark - 添加底部横线方法
- (void)addLine:(CGRect)frame toView:(UIView *)view
{
    UIView *line         = [[UIView alloc] initWithFrame:frame];
    line.backgroundColor = DWQ_COLOR(160, 170, 160, 0.5);
    [view addSubview:line];
    [_lines addObject:line];
}

#pragma mark - 按钮事件
- (void)buttonClicked:(UIButton *)button
{
    [self performSelector:@selector(dwq_dismissAlertView)];
    if (self.buttonActionBlock)
    {
        self.buttonActionBlock(button.tag);
    }
}

#pragma mark - 纯颜色转图片
- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect          = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    UIImage *image       = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize )size
{
    CGRect rect          = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    UIImage *image       = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 清除所有视图
- (void)removeSelf
{
    NSLog(@"【 %@ 】已经释放！",[self class]);
    [self performSelector:@selector(resetViews)];
    [self.buttons removeAllObjects];
    [self.lines removeAllObjects];
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.blurEffectStyle = 0;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//
//#pragma mark - 转屏通知处理
-(void)changeFrames:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            NSLog(@"UIDeviceOrientationPortrait");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"UIDeviceOrientationLandscapeLeft");
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"UIDeviceOrientationLandscapeRight");
            break;
        default:
            break;
    }
    
    [self.containerView.layer removeAllAnimations];
    self.animating = false;
    [self layoutMySubViews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.animating)
    {
        [self layoutMySubViews];
    }else {
        
    }
    
}

-(void )layoutMySubViews
{
    self.viewWidth                = [UIScreen mainScreen].bounds.size.width;
    self.viewHeight               = [UIScreen mainScreen].bounds.size.height;
    
    if (self.subView)
    {
        if ( self.subView.translatesAutoresizingMaskIntoConstraints ) {
            self.frame                = CGRectMake(0.f, 0.f, self.viewWidth, self.viewHeight);
            self.subView.frame        = CGRectMake(50.f, 0.f, self.viewWidth - 100.f, CGRectGetHeight(self.subView.frame));
            self.subView.center       = CGPointMake(self.viewWidth/2.f, self.viewHeight/2.f);
        }else {
            
        }
    }
    else
    {
        [self performSelector:@selector(prepareForShow)];
        self.containerView.center = CGPointMake(self.viewWidth/2.f, self.viewHeight/2.f);
    }
    
}

#pragma mark - class method
+ (void)dwq_showCustomView:(UIView *)customView
            configuration:(void (^)(DWQAlert *tempView)) configuration
{
    DWQAlert *temp = [[DWQAlert alloc] initWithCustomView:customView];
    if (configuration)
    {
        configuration(temp);
    }
    [temp dwq_showAlertView];
}

+ (void)dwq_showAlertWithTitle:(NSString *)title
                      message:(NSString *)message
                        image:(UIImage *)image
                 buttonTitles:(NSArray *)buttonTitles
            buttonTitlesColor:(NSArray <UIColor *>*)buttonTitlesColor
                configuration:(void (^)(DWQAlert *tempView)) configuration
                  actionClick:(void (^)(NSInteger index)) action
{
    DWQAlert *temp = [[DWQAlert alloc] dwq_showTitle:title
                                          message:message
                                            image:image
                                     buttonTitles:buttonTitles
                                buttonTitlesColor:buttonTitlesColor];
    if (configuration)
    {
        configuration(temp);
    }
    [temp dwq_showAlertView];
    
    temp.buttonActionBlock = action;
}

- (UIImage *)screenShotImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREENWIDTH + 50, SCREENHEIGHT * 2), YES, 1.f);
    //
    //    /*! 设置截屏大小 */
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    [[window layer] renderInContext:UIGraphicsGetCurrentContext() ];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return viewImage;
}

/*! 待优化 */
- (void )imageOutPut:(void(^)(UIImage *image)) outPutImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        /*! CIImage，不能用UIImage的CIImage属性 */
        CIImage *ciImage         = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"123.png"]];
        //        UIImage *tempImage = [self imageWithColor:[UIColor grayColor] andSize:[UIScreen mainScreen].bounds.size];
        //        CIImage *ciImage         = [[CIImage alloc] initWithImage:tempImage];
        
        // CIFilter(滤镜的名字)
        CIFilter *blurFilter     = [CIFilter filterWithName:@"CIGaussianBlur"];
        //    CIColor *color = [CIColor colorWithRed:1.0 green:0 blue:0];
        // 将图片放到滤镜中
        //    [blurFilter setValue:color forKey:kCIInputColorKey];
        [blurFilter setValue:ciImage forKey:kCIInputImageKey];
        
        // inputRadius参数: 模糊的程度 默认为10, 范围为0-100, 接收的参数为NSNumber类型
        
        // 设置模糊的程度
        [blurFilter setValue:@(10) forKey:kCIInputRadiusKey];
        //        [blurFilter setValue:@(10) forKey:kCIInputSharpnessKey];
        
        // 将处理好的图片导出
        CIImage *outImage        = [blurFilter valueForKey:kCIOutputImageKey];
        
        //理论上这些东西需要放到子线程去渲染，待优化
        // CIContext 上下文(参数nil，默认为CPU渲染, 如果想用GPU渲染来提高效率的话,则需要传参数)
        CIContext *context       = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}];
        
        // 将处理好的图片创建出来
        CGImageRef outputCGImage = [context createCGImage:outImage fromRect:[UIScreen mainScreen].bounds];
        
        UIImage *blurImage       = [UIImage imageWithCGImage:outputCGImage];
        
        // 释放CGImageRef
        CGImageRelease(outputCGImage);
        
        if (outPutImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                outPutImage(blurImage);
            });
        }
        
    });
}


@end

