//
//  HYSegmentControl.m
//  HYSegmentControl
//
//  Created by Shadow on 14-6-30.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import "HYSegmentControl.h"

@interface HYSegmentControl ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, copy) NSArray *names;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, strong) UIView *underLine;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation HYSegmentControl

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self initProperty];
    [self setupSubViews];
  }
  return self;
}

- (void)setBgImage:(UIImage *)bgImage
{
  if (_bgImage != bgImage) {
    _bgImage = bgImage;
    self.bgColor = nil;
    self.bgImageView.backgroundColor = nil;
    self.bgImageView.image = bgImage;
  }
}

- (void)setBgColor:(UIColor *)bgColor
{
  if (_bgColor != bgColor) {
    _bgColor = bgColor;
    self.bgImage = nil;
    self.bgImageView.image = nil;
    self.bgImageView.backgroundColor = bgColor;
  }
}

- (void)setUnderLineColor:(UIColor *)underLineColor
{
  if (_underLineColor != underLineColor) {
    _underLineColor = underLineColor;
    self.underLine.backgroundColor = underLineColor;
  }
}

- (void)setupButtonNames:(NSArray *)names
{
  if (names.count) {
    self.names = names;
    [self setupButtons];
    [self reset];
  }
}

- (void)setupButtons
{
  if (self.buttons) {
    [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.buttons removeAllObjects];
  } else {
    self.buttons = [NSMutableArray array];
  }
  
  CGSize constrainSize = CGSizeMake(1000, CGRectGetHeight(self.bounds));
  
  CGFloat currentX = self.spacing;
  
  int buttonIndex = 0;
  
  for (NSString *name in self.names) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button setTitleColor:self.fontColor forState:UIControlStateNormal];
    button.titleLabel.font = self.font;
    [button setTitle:name forState:UIControlStateNormal];
    
    CGSize size = [name sizeWithFont:self.font constrainedToSize:constrainSize lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect buttonFrame = CGRectMake(currentX, 0, MAX(size.width, self.buttonMinWidth), CGRectGetHeight(self.bounds));
    button.frame = buttonFrame;
    
    [self.scrollView addSubview:button];
    [self.buttons addObject:button];
    
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    button.tag = buttonIndex;
    buttonIndex++;
    
    currentX += CGRectGetWidth(buttonFrame) + self.spacing;
  }
  [self calculateScrollViewContentSize];
}

- (void)reset
{
  [self setCurrentIndex:0];
}

- (CGFloat)getXToIndex:(NSInteger)index
{
  if (index >= self.buttons.count ||
      index < 0) {
    return 0;
  }
  
  CGFloat x = self.spacing;
  
  for (int i = 0; i < index; i++) {
    UIButton *button = self.buttons[i];
    x += CGRectGetWidth(button.bounds) + self.spacing;
  }
  return x;
}

- (CGFloat)getButtonWidthAtIndex:(NSInteger)index
{
  if (index >= self.buttons.count) {
    return 0;
  }
  UIButton *button = self.buttons[index];
  return CGRectGetWidth(button.bounds);
}

- (void)initProperty
{
  self.spacing = 15.f;
  self.font = [UIFont systemFontOfSize:15.f];
  self.fontColor = [UIColor blackColor];
  self.buttonMinWidth = 40.f;
  self.highlightFontColor = [UIColor orangeColor];
  self.underLineColor = [UIColor orangeColor];
  self.underLineHeight = 2.f;
  self.bgColor = [UIColor whiteColor];
}

- (void)setupSubViews
{
  self.bgImageView = [[UIImageView alloc]initWithFrame:self.bounds];
  self.bgImageView.backgroundColor = self.bgColor;
  self.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self addSubview:self.bgImageView];
  
  self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
  self.scrollView.showsHorizontalScrollIndicator = NO;
  self.scrollView.showsVerticalScrollIndicator = NO;
  self.scrollView.bounces = NO;
  
  self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
  [self addSubview:self.scrollView];
  
  self.underLine = [[UIView alloc]init];
  self.underLine.backgroundColor = self.underLineColor;
  [self.scrollView addSubview:self.underLine];
}

- (void)calculateScrollViewContentSize
{
  CGFloat width = self.spacing;
  
  for (UIButton *button in self.buttons) {
    width += CGRectGetWidth(button.bounds) + self.spacing;
  }
  
  self.scrollView.contentSize = CGSizeMake(width, CGRectGetHeight(self.bounds));
}

- (void)setUnderLinePosition:(CGFloat)offsetX width:(CGFloat)width
{
  self.underLine.frame = CGRectMake(offsetX, CGRectGetHeight(self.bounds)-self.underLineHeight, width, self.underLineHeight);
}

- (void)setScrollViewScrollToIndex:(NSInteger)index animated:(BOOL)animated
{
  if (index >= self.buttons.count ||
      index < 0 || self.scrollView.contentSize.width <= CGRectGetWidth(self.bounds)) {
    return;
  }
  
  UIButton *button = self.buttons[index];
  CGFloat offsetX = button.center.x - CGRectGetWidth(self.bounds)/2;
  if (offsetX > self.scrollView.contentSize.width - CGRectGetWidth(self.bounds)) {
    offsetX = self.scrollView.contentSize.width - CGRectGetWidth(self.bounds);
  } else if (offsetX < 0) {
    offsetX = 0;
  }
  
  [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)setCurrentIndex:(NSInteger)index
{
  [self setCurrentIndex:index percent:0];
}

- (void)setCurrentIndex:(NSInteger)index percent:(CGFloat)percent
{
  CGFloat nowX = [self getXToIndex:index];
  CGFloat nowWidth = [self getButtonWidthAtIndex:index];
  
  if (index < self.buttons.count - 1) {
    self.selectIndex = percent > 0.5 ? index + 1 : index;
    [self highlightButtonAtIndex:percent > 0.5 ? index + 1 : index];
    
    CGFloat nextX = [self getXToIndex:index + 1];
    CGFloat nextWidth = [self getButtonWidthAtIndex:index + 1];
    [self setUnderLinePosition:(nextX - nowX) * percent + nowX
                         width:(nextWidth - nowWidth) * percent + nowWidth];
  } else {
    self.selectIndex = index;
    [self highlightButtonAtIndex:index];
    [self setUnderLinePosition:nowX width:nowWidth];
  }
}

- (void)highlightButtonAtIndex:(NSInteger)index
{
  if (index >= self.buttons.count || index < 0) {
    return;
  }
  
  for (UIButton *tempButton in self.buttons) {
    [tempButton setTitleColor:self.fontColor forState:UIControlStateNormal];
  }
  
  UIButton *button = self.buttons[index];
  [button setTitleColor:self.highlightFontColor forState:UIControlStateNormal];
}

#pragma mark - Action

- (void)notifyDelegate
{
  if ([self.delegate respondsToSelector:@selector(segmentControl:didSelectButtonAtIndex:)]) {
    [self.delegate segmentControl:self didSelectButtonAtIndex:self.selectIndex];
  }
}

- (void)buttonClick:(UIButton *)button
{
  NSInteger buttonTag = button.tag;
  
  if (self.selectIndex == buttonTag) {
    return;
  }
  
  self.selectIndex = buttonTag;
  [self notifyDelegate];
}

#pragma mark - ScrollView Method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  NSInteger width = CGRectGetWidth(scrollView.bounds);
  NSInteger offsetX = scrollView.contentOffset.x;
  CGFloat percentNum = offsetX % width;
  if (percentNum > width) {
    percentNum = width;
  } else if (percentNum < 0) {
    percentNum = 0;
  }
  
  CGFloat percent =  percentNum / width;
  NSInteger index = scrollView.contentOffset.x / width;
  if (index < 0) {
    index = 0;
  }
  
  if (index >= self.buttons.count) {
    index = self.buttons.count - 1;
  }
  
  [self setCurrentIndex:index percent:percent];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  if (!scrollView.isTracking) {
    [self notifyDelegate];
    [self setScrollViewScrollToIndex:self.selectIndex animated:YES];
  }
}

@end
