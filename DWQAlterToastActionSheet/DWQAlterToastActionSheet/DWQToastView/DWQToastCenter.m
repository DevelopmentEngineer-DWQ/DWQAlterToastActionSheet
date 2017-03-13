
//  DWQAlterToastActionSheet
//
//  Created by 杜文全 on 16/11/24.
//  Copyright © 2016年 杜文全. All rights reserved.

#import "DWQToastCenter.h"
#import "UIView+DWQCategory.h"


#pragma mark -
@interface DWQToastView : UIView {
	CGRect _messageRect;
	NSString *_text;
	UIImage *_image;
}

- (id) init;
- (void) setMessageText:(NSString*)str;
- (void) setImage:(UIImage*)image;

@end


#pragma mark -
@implementation DWQToastView

- (id) init{
	if(!(self = [super initWithFrame:CGRectMake(0, 0, 100, 100)])) return nil;
	_messageRect = CGRectInset(self.bounds, 10, 10);
	self.backgroundColor = [UIColor clearColor];
	return self;
	
}



- (void) _drawRoundRectangleInRect:(CGRect)rect withRadius:(CGFloat)radius{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	
	CGRect rrect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFill);
}




- (void) drawRect:(CGRect)rect{
	[[UIColor colorWithWhite:0 alpha:0.8] set];
	[self _drawRoundRectangleInRect:rect withRadius:10];
	[[UIColor whiteColor] set];
	[_text drawInRect:_messageRect
			 withFont:[UIFont boldSystemFontOfSize:14]
		lineBreakMode:NSLineBreakByWordWrapping
			alignment:NSTextAlignmentCenter];
	
	CGRect r = CGRectZero;
	r.origin.y = 15;
	r.origin.x = (NSInteger)((rect.size.width-_image.size.width)/2);
	r.size = _image.size;
	
	[_image drawInRect:r];
}

#pragma mark Setter Methods
- (void) adjust{
	
	CGSize s = [_text sizeWithFont:[UIFont boldSystemFontOfSize:14]
				 constrainedToSize:CGSizeMake(160,200)
					 lineBreakMode:NSLineBreakByWordWrapping];
	
	float imageAdjustment = 0;
	if (_image) {
		imageAdjustment = 7+_image.size.height;
	}
	
	self.bounds = CGRectMake(0, 0, s.width+40, s.height+15+15+imageAdjustment);
	
	_messageRect.size = s;
	_messageRect.size.height += 5;
	_messageRect.origin.x = 20;
	_messageRect.origin.y = 15+imageAdjustment;
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
	
}
- (void) setMessageText:(NSString*)str{
	_text = str;
	[self adjust];
}
- (void) setImage:(UIImage*)img{
	_image = img;
	[self adjust];
}

@end


#pragma mark -
@implementation DWQToastCenter

#pragma mark Init & Friends
+ (DWQToastCenter*) defaultCenter {
	static DWQToastCenter *defaultCenter = nil;
	if (!defaultCenter) {
		defaultCenter = [[DWQToastCenter alloc] init];
	}
	return defaultCenter;
}
- (id) init{
	if(!(self=[super init])) return nil;
	
	_toasts = [[NSMutableArray alloc] init];
	_toastView = [[DWQToastView alloc] init];
	_active = NO;
	
	
	_toastFrame = [UIApplication sharedApplication].keyWindow.bounds;

	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

	return self;
}


#pragma mark Show toast Message
- (void) showtoasts{
	
	if([_toasts count] < 1) {
		_active = NO;
		return;
	}
	
	_active = YES;
	_toastView.transform = CGAffineTransformIdentity;
	_toastView.alpha = 0;
	[[UIApplication sharedApplication].keyWindow addSubview:_toastView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_toastView];
	
	
	NSArray *ar = [_toasts objectAtIndex:0];
	
	UIImage *img = nil;
	if([ar count] > 1) img = [[_toasts objectAtIndex:0] objectAtIndex:1];
	
	[_toastView setImage:img];

	if([ar count] > 0) [_toastView setMessageText:[[_toasts objectAtIndex:0] objectAtIndex:0]];
	
	
	
	_toastView.center = CGPointMake(_toastFrame.origin.x+_toastFrame.size.width/2, _toastFrame.origin.y+_toastFrame.size.height/2);
		
	
	CGRect rr = _toastView.frame;
	rr.origin.x = (int)rr.origin.x;
	rr.origin.y = (int)rr.origin.y;
	_toastView.frame = rr;
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	_toastView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_toastView.transform = CGAffineTransformScale(_toastView.transform, 2, 2);
	
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationStep2)];
	_toastView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_toastView.frame = CGRectMake((int)_toastView.frame.origin.x, (int)_toastView.frame.origin.y, _toastView.frame.size.width, _toastView.frame.size.height);
	_toastView.alpha = 1;
	[UIView commitAnimations];
	
}
- (void) animationStep2{
	[UIView beginAnimations:nil context:nil];

	// depending on how many words are in the text
	// change the animation duration accordingly
	// avg person reads 200 words per minute
	NSArray * words = [[[_toasts objectAtIndex:0] objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	double duration = MAX(((double)[words count]*60.0/200.0),1);
	
	[UIView setAnimationDelay:duration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationStep3)];
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	_toastView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_toastView.transform = CGAffineTransformScale(_toastView.transform, 0.5, 0.5);
	
	_toastView.alpha = 0;
	[UIView commitAnimations];
}
- (void) animationStep3{
	
	[_toastView removeFromSuperview];
	[_toasts removeObjectAtIndex:0];
	[self showtoasts];
	
}
- (void) postToastWithMessage:(NSString*)message image:(UIImage*)image{
	[_toasts addObject:[NSArray arrayWithObjects:message,image,nil]];
	if(!_active) [self showtoasts];
}
- (void) postToastWithMessage:(NSString*)message{
	[self postToastWithMessage:message image:nil];
}


#pragma mark System Observation Changes
CGRect subtractRect(CGRect wf,CGRect kf);
CGRect subtractRect(CGRect wf,CGRect kf){
	
	
	
	if(!CGPointEqualToPoint(CGPointZero,kf.origin)){
		
		if(kf.origin.x>0) kf.size.width = kf.origin.x;
		if(kf.origin.y>0) kf.size.height = kf.origin.y;
		kf.origin = CGPointZero;
		
	}else{
		
		
		kf.origin.x = abs(kf.size.width - wf.size.width);
		kf.origin.y = abs(kf.size.height -  wf.size.height);
		
		
		if(kf.origin.x > 0){
			CGFloat temp = kf.origin.x;
			kf.origin.x = kf.size.width;
			kf.size.width = temp;
		}else if(kf.origin.y > 0){
			CGFloat temp = kf.origin.y;
			kf.origin.y = kf.size.height;
			kf.size.height = temp;
		}
		
	}
	return CGRectIntersection(wf, kf);
	
	
	
}
- (void) keyboardWillAppear:(NSNotification *)notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect kf = [aValue CGRectValue];
	CGRect wf = [UIApplication sharedApplication].keyWindow.bounds;
	
	[UIView beginAnimations:nil context:nil];
	_toastFrame = subtractRect(wf,kf);
	_toastView.center = CGPointMake(_toastFrame.origin.x+_toastFrame.size.width/2, _toastFrame.origin.y+_toastFrame.size.height/2);

	[UIView commitAnimations];

}
- (void) keyboardWillDisappear:(NSNotification *) notification {
	_toastFrame = [UIApplication sharedApplication].keyWindow.bounds;

}
- (void) orientationWillChange:(NSNotification *) notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *v = [userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
	UIInterfaceOrientation o = [v intValue];
	
	
	
	
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	
	[UIView beginAnimations:nil context:nil];
	_toastView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_toastView.frame = CGRectMake((int)_toastView.frame.origin.x, (int)_toastView.frame.origin.y, (int)_toastView.frame.size.width, (int)_toastView.frame.size.height);
	[UIView commitAnimations];
	
}

@end
