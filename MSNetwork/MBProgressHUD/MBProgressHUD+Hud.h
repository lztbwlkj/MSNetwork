//
//  MBProgressHUD+Hud.h
//  MSProgressCategory
//
//  Created by lztb on 2019/8/22.
//  Copyright © 2019 lztbwlkj. All rights reserved.
//

#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

//具体默认属性在这里可以全局修改
//如果想单独修改可参考ViewController.m文件的实现方法

//默认window
#define kWindow [UIApplication sharedApplication].keyWindow

//内容View的背景色
#define kBezelViewColor  [UIColor colorWithWhite:0 alpha:1]
//window的窗体背景色
#define kBackgroundColor  [UIColor colorWithWhite:0 alpha:0.5]
//内容颜色
#define kContentColor  [UIColor whiteColor]
//
#define kClearClolor  [UIColor colorWithRed:1 green:1 blue:1 alpha:0]

#define kShowTime 1.5


@interface MBProgressHUD (Hud)

#pragma mark - UIActivityIndicatorView 样式
/**
 UIActivityIndicatorView加载样式

 @param hideBlock hide后的回调
 @return MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_loading:(nullable MBProgressHUDCompletionBlock)hideBlock;

/**
 UIActivityIndicatorView带文字的加载样式

 @param msg 提示的标题文字，可以为nil
 @param detail 提示详情文字 可以为nil
 @param view 展示的View
 @param block hide后的回调
 @return  MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_showMessage:(nullable NSString *)msg detailMsg:(nullable NSString *)detail onView:(nullable UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)block;

#pragma mark - 进度条样式

/**
 内边距进度条样式 ,（请手动设置progress属性）
 
 @param msg 提示文字，可以为nil
 @param detail 提示详情文字 可以为nil
 @param view 展示的父View
 @param block hide后的回调
 @return  MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_showDeterm:(nullable NSString *)msg detailMsg:(nullable NSString *)detail onView:(nullable UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)block;


/**
 进度条样式，（请手动设置progress属性）

 @param msg 提示文字，可以为nil
 @param detail 提示详情文字 可以为nil
 @param view 展示的父View
 @param block hide后的回调
 @return  MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_showBar:(nullable NSString *)msg detailMsg:(nullable NSString *)detail onView:(nullable UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)block;


/**
 外边距进度条样式（请手动设置progress属性）

 @param msg 提示文字，可以为nil
 @param detail 提示详情文字 可以为nil
 @param view 展示的父View
 @param block hide后的回调
 @return  MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_showAnnularDeterm:(nullable NSString *)msg detailMsg:(nullable NSString *)detail onView:(nullable UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)block;

#pragma mark - 只有文字的提示样式
/**
 屏幕顶部文字提示

 @param msg 提示文字，不能为nil
 @param view 展示的父View
 @param block hide后的回调
 @return  MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_showTopMessage:(nonnull NSString *)msg onView:(nullable UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)block;

/**
 屏幕中间文字提示

 @param msg 提示文字，不能为nil
 @param view 展示的父View
 @param block hide后的回调
 @return  MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_showMidMessage:(nonnull NSString *)msg onView:(nullable UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)block;

/**
 底部文字提示

 @param msg 提示文字，不能为nil
 @param view 展示的父View
 @param block hide后的回调
 @return  MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_showBotMessage:(nonnull NSString *)msg onView:(nullable UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)block;

#pragma mark - 图片效果展示
/**
 单个图片效果展示

 @param imageName 图片名称
 @param msg 提示文字，可以为nil
 @param view 展示的父View
 @param block hide后的回调
 @return  MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_showImage:(nonnull NSString *)imageName msg:(nullable NSString *)msg onView:(nullable UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)block;

/**
 动态图片（如果需要透明的内容颜色，或许需要改MBProgressHUD的源代码）
 尝试内容背景给透明，结果发现无效，一直有一个白色的effectView

 @param animatImages 图片数组
 @param msg 提示文字，可以为nil
 @param view 展示的父View
 @param block hide后的回调
 @return  MBProgressHUD对象
 */
+ (MBProgressHUD *)mb_showImages:(nonnull NSArray<UIImage *> *)animatImages msg:(nullable NSString *)msg onView:(nullable UIView *)view hideBlock:(nullable MBProgressHUDCompletionBlock)block;

#pragma mark - Hide
/**
 隐藏HudView

 @param anim 是否有动画
 */
+ (void)mb_hideHudView:(BOOL)anim;

/**
 anim参数为YES的隐藏HudView方法
 */
+ (void)mb_hide;
@end

NS_ASSUME_NONNULL_END
