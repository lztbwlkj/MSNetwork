//
//  MBProgressHUD+Hud.m
//  MSProgressCategory
//
//  Created by lztb on 2019/8/22.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "MBProgressHUD+Hud.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define CURRENT_SIZE(_size) _size / 375.0 * SCREEN_WIDTH

@implementation MBProgressHUD (Hud)
static UIView *showView;


+ (MBProgressHUD *)mb_loading:(MBProgressHUDCompletionBlock)hideBlock{
    return [self showMessage:nil detailMsg:nil mode:MBProgressHUDModeIndeterminate
                             onView:kWindow hideBlock:hideBlock];
}


+ (MBProgressHUD *)mb_showMessage:(NSString *)msg detailMsg:(NSString *)detail onView:(UIView *)view hideBlock:(MBProgressHUDCompletionBlock)block{
    return [self showMessage:msg detailMsg:detail mode:MBProgressHUDModeIndeterminate
                             onView:view  hideBlock:block];
}

+ (MBProgressHUD *)mb_showDeterm:(NSString *)msg detailMsg:(NSString *)detail onView:(UIView *)view hideBlock:(MBProgressHUDCompletionBlock)block{
    return [self showMessage:msg detailMsg:detail mode:MBProgressHUDModeDeterminate
                      onView:view  hideBlock:block];
}

+ (MBProgressHUD *)mb_showBar:(NSString *)msg detailMsg:(NSString *)detail onView:(UIView *)view hideBlock:(MBProgressHUDCompletionBlock)block{
    return [self showMessage:msg detailMsg:detail mode:MBProgressHUDModeDeterminateHorizontalBar
                      onView:view  hideBlock:block];
}

+ (MBProgressHUD *)mb_showAnnularDeterm:(NSString *)msg detailMsg:(NSString *)detail onView:(UIView *)view hideBlock:(MBProgressHUDCompletionBlock)block{
    return [self showMessage:msg detailMsg:detail mode:MBProgressHUDModeAnnularDeterminate
                      onView:view  hideBlock:block];
}


+ (MBProgressHUD *)mb_showTopMessage:(NSString *)msg onView:(UIView *)view hideBlock:(MBProgressHUDCompletionBlock)block{
    return [self showLoadBriefMessage:msg onView:view position:1 hideBlock:block];
}
+ (MBProgressHUD *)mb_showMidMessage:(NSString *)msg onView:(UIView *)view hideBlock:(MBProgressHUDCompletionBlock)block {
    return [self showLoadBriefMessage:msg onView:view position:0 hideBlock:block] ;

}
+ (MBProgressHUD *)mb_showBotMessage:(NSString *)msg onView:(UIView *)view hideBlock:(MBProgressHUDCompletionBlock)block{
    return [self showLoadBriefMessage:msg onView:view position:-1 hideBlock:block];
}



+ (MBProgressHUD *)mb_showImage:(NSString *)imageName msg:(NSString *)msg onView:(UIView *)view hideBlock:(MBProgressHUDCompletionBlock)block {
    showView = view != nil? view:kWindow;
    
    MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:showView animated:YES];
    UIImageView *littleView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    littleView.image = [UIImage imageNamed:imageName];
    hud.customView = littleView;
    hud.contentColor = kContentColor;
    hud.bezelView.color = kBezelViewColor;
    hud.removeFromSuperViewOnHide = YES;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.label.text = msg;
    hud.minSize = CGSizeMake(80, 80);
    hud.backgroundView.backgroundColor = kClearClolor;
    hud.mode = MBProgressHUDModeCustomView;
    hud.completionBlock = block;
    
    [hud hideAnimated:YES afterDelay:kShowTime];
    
    return hud;
}

+ (MBProgressHUD *)mb_showImages:(NSArray<UIImage *> *)animatImages msg:(NSString *)msg onView:(UIView *)view hideBlock:(MBProgressHUDCompletionBlock)block {
    showView = view != nil? view:kWindow;

    MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:showView animated:YES];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.bezelView.color = kBezelViewColor;
    hud.contentColor = kContentColor;
    hud.mode = MBProgressHUDModeCustomView;
    hud.label.text = msg;
    UIImageView *littleView = [[UIImageView alloc] init];
    littleView.clipsToBounds = YES;
    littleView.animationImages = animatImages;
    littleView.animationDuration = 1.0;
    littleView.backgroundColor = kClearClolor;
    [littleView startAnimating];
    hud.customView = littleView;

    hud.opaque = NO;
    hud.completionBlock = ^{
        [littleView stopAnimating];
        block();
    };
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

#pragma mark - HideView
+ (void)mb_hideHudView:(BOOL)anim{
    [MBProgressHUD hideHUDForView:showView animated:anim];
}
+ (void)mb_hide{
    [MBProgressHUD hideHUDForView:showView animated:YES];
}

#pragma mark - Text
/**
 菊花样式展示文字
 */
+(MBProgressHUD *) showMessage:(NSString *)msg detailMsg:(NSString *)detail mode:(MBProgressHUDMode)mode onView:(UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)hideBlock{
    showView = view != nil? view:kWindow;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:showView animated:YES];
    hud.backgroundView.backgroundColor = kBackgroundColor;
    hud.bezelView.color = kBezelViewColor;
    hud.contentColor = kContentColor;
    hud.animationType = MBProgressHUDAnimationZoomOut;
    hud.mode = mode;

    hud.label.text = msg;
    hud.detailsLabel.text = detail;

    hud.label.font = [UIFont systemFontOfSize:15];
    hud.detailsLabel.font = [UIFont systemFontOfSize:13];
    hud.margin = 15.0f;
    hud.completionBlock = hideBlock;
    hud.minSize = CGSizeMake(80, 80);
    
    hud.removeFromSuperViewOnHide = YES;

    return hud;
}


+ (MBProgressHUD *)showLoadBriefMessage:(NSString *)message onView:(UIView *)view position:(NSInteger)position hideBlock:(MBProgressHUDCompletionBlock)block{
    showView = view != nil? view:kWindow;
    MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:showView animated:YES];
    switch (position) {
            case 1:{
                hud.offset = CGPointMake(0, -CURRENT_SIZE(CGRectGetHeight(showView.frame)/3));
            }
            break;
            case -1:{
                hud.offset = CGPointMake(0, CURRENT_SIZE(CGRectGetHeight(showView.frame)/3));
            }
            break;
    }
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:14];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.mode = MBProgressHUDModeText;
    hud.contentColor = kContentColor;
    hud.bezelView.color = kBezelViewColor;
    hud.margin = 8.f;
    hud.removeFromSuperViewOnHide = YES;
    hud.completionBlock = block;
    [hud hideAnimated:YES afterDelay:kShowTime];
    return hud;
}



@end
