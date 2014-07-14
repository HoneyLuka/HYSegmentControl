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

@property (nonatomic, strong) UIImageView *underLine;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, assign) int selectIndex;

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

- (void)setupButtonNames:(NSArray *)names
{
    if (names.count) {
        self.names = names;
        [self setupButtons];
        [self setUnderLineToIndex:self.selectIndex animated:NO completion:nil];
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
        [button setTitleColor:self.fontColor forState:UIControlStateNormal];
        button.titleLabel.font = self.font;
        [button setTitle:name forState:UIControlStateNormal];
        
        CGSize size = [name sizeWithFont:self.font constrainedToSize:constrainSize lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect buttonFrame = CGRectMake(currentX, 0, size.width, CGRectGetHeight(self.bounds));
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

- (CGFloat)getXToIndex:(int)index
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

- (CGFloat)getButtonWidthAtIndex:(int)index
{
    if (index >= self.buttons.count) {
        return 0;
    }
    UIButton *button = self.buttons[index];
    return CGRectGetWidth(button.bounds);
}

- (void)setUnderLineToIndex:(int)index animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    if (index >= self.buttons.count) {
        return;
    }
    
    self.userInteractionEnabled = NO;
    
    CGFloat x = [self getXToIndex:index];
    CGFloat width = [self getButtonWidthAtIndex:index];
    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            self.underLine.frame = CGRectMake(x, CGRectGetHeight(self.bounds)-self.underLineHeight, width, self.underLineHeight);
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
            
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        self.underLine.frame = CGRectMake(x, CGRectGetHeight(self.bounds)-self.underLineHeight, width, self.underLineHeight);
        self.userInteractionEnabled = YES;
        if (completion) {
            completion(YES);
        }
    }
    
}

- (void)setScrollViewScrollToIndex:(int)index animated:(BOOL)animated
{
    if (index >= self.buttons.count ||
        index < 0) {
        
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

- (void)buttonClick:(UIButton *)button
{
    int buttonTag = button.tag;
    
    if (self.selectIndex == buttonTag) {
        return;
    }
    
    [self setSelectIndexTo:buttonTag];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentControl:didSelectButtonAtIndex:)]) {
        [self.delegate segmentControl:self didSelectButtonAtIndex:self.selectIndex];
    }
}

- (void)setSelectIndexTo:(int)index
{
    if (self.selectIndex == index) {
        return;
    }
    self.selectIndex = index;
    
    __weak HYSegmentControl *weakSelf = self;
    [self setUnderLineToIndex:index animated:YES completion:^(BOOL finished) {
        [weakSelf setScrollViewScrollToIndex:index animated:YES];
    }];
}

- (void)setIndexTo:(int)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (index == self.selectIndex) {
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    if (index >= self.buttons.count ||
        index < 0) {
        
        return;
    }
    
    self.selectIndex = index;
    
    __weak HYSegmentControl *weakSelf = self;
    [self setUnderLineToIndex:index animated:animated completion:^(BOOL finished) {
        [weakSelf setScrollViewScrollToIndex:index animated:animated];
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)calculateScrollViewContentSize
{
    CGFloat width = self.spacing;
    
    for (UIButton *button in self.buttons) {
        width += CGRectGetWidth(button.bounds) + self.spacing;
    }
    
    self.scrollView.contentSize = CGSizeMake(width, CGRectGetHeight(self.bounds));
}

- (void)initProperty
{
    self.spacing = 15.f;
    self.font = [UIFont systemFontOfSize:15.f];
    self.fontColor = [UIColor blackColor];
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
    
    self.underLine = [[UIImageView alloc]init];
    self.underLine.backgroundColor = self.underLineColor;
    [self.scrollView addSubview:self.underLine];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    [self setSelectIndexTo:index];
}

@end
