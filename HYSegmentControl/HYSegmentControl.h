//
//  HYSegmentControl.h
//  HYSegmentControl
//
//  Created by Shadow on 14-6-30.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYSegmentControl;
@protocol HYSegmentControlDelegate <NSObject>

@optional
- (void)segmentControl:(HYSegmentControl *)control didSelectButtonAtIndex:(NSInteger)index;

@end

@interface HYSegmentControl : UIView

@property (nonatomic, weak) id<HYSegmentControlDelegate> delegate;

/**
 按钮之间的间距, 默认是15.f
 */
@property (nonatomic, assign) CGFloat spacing;

/**
 按钮字体, 默认是系统字体15.f
 */
@property (nonatomic, strong) UIFont *font;

/**
 按钮字体颜色, 默认是blackColor
 */
@property (nonatomic, strong) UIColor *fontColor;

/**
 按钮最小宽度，默认是40.f
 */
@property (nonatomic, assign) CGFloat buttonMinWidth;

/**
 按钮选中字体颜色, 默认是orange
 */
@property (nonatomic, strong) UIColor *highlightFontColor;

/**
 提示线颜色, 默认是orangeColor
 */
@property (nonatomic, strong) UIColor *underLineColor;

/**
 提示线高度, 默认是2.f
 */
@property (nonatomic, assign) CGFloat underLineHeight;

/**
 视图背景颜色, 默认是白色. 和bgImage互斥.
 */
@property (nonatomic, strong) UIColor *bgColor;

/**
 视图背景图片, 默认为nil. 和bgColor互斥.
 */
@property (nonatomic, strong) UIImage *bgImage;

/**
 使用该方法设置元素项, 数组内元素为NSString.
 
 !注意: 如果需要使用上边的属性来自定义控件的外观, 请在修改后再调用这个方法.
 (这个方法调用后再修改控件的属性可能无效.)
 */
- (void)setupButtonNames:(NSArray *)names;

/**
 用这个方法设置当前选中项(不会触发delegate)
 */
- (void)setCurrentIndex:(NSInteger)index;

#pragma mark - ScrollView Method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end
