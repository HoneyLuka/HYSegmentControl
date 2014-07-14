//
//  ViewController.m
//  HYSegmentControl
//
//  Created by Shadow on 14-6-30.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import "ViewController.h"
#import "HYSegmentControl.h"

@interface ViewController () <UIScrollViewDelegate, HYSegmentControlDelegate>

@property (nonatomic, strong) HYSegmentControl *control;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *insideViewsArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.control = [[HYSegmentControl alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 30)];
    self.control.bgColor = [UIColor whiteColor];
//    self.control.bgImage = [UIImage imageNamed:@"contentview_sectionheader"];
//    self.control.spacing = 25.f;
//    self.control.fontColor = [UIColor lightGrayColor];
//    self.control.underLineColor = [UIColor greenColor];
//    self.control.underLineHeight = 5.f;
    [self.control setupButtonNames:@[@"今天", @"明天", @"后天", @"大后天", @"大大后天", @"大大大后天", @"大大大大后天"]];
    [self.view addSubview:self.control];
    self.control.delegate = self;
    
    [self setupScrollView];
    [self setInsideViews];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.control scrollViewDidEndDecelerating:scrollView];
}

- (void)segmentControl:(HYSegmentControl *)control didSelectButtonAtIndex:(int)index
{
    CGPoint contentOffset = CGPointMake(CGRectGetWidth(self.view.bounds) * index, 0);
    [self.scrollView setContentOffset:contentOffset animated:YES];
}

- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20.f + CGRectGetHeight(self.control.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 20.f - CGRectGetHeight(self.control.bounds))];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * 7, CGRectGetHeight(self.scrollView.bounds));
}



- (void)setInsideViews
{
    for (int i = 0; i < 7; i++) {
        UILabel *view = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.text = [NSString stringWithFormat:@"%d", i];
        view.textAlignment = NSTextAlignmentCenter;
        view.textColor = [UIColor whiteColor];
        view.font = [UIFont systemFontOfSize:20.f];
        view.backgroundColor = [UIColor blueColor];
        [self.scrollView addSubview:view];
        CGPoint center = CGPointMake(CGRectGetWidth(self.scrollView.bounds)/2 + CGRectGetWidth(self.scrollView.bounds)*i, CGRectGetHeight(self.scrollView.bounds)/2);
        view.center = center;
        
        if (!self.insideViewsArray) {
            self.insideViewsArray = [NSMutableArray array];
        }
        [self.insideViewsArray addObject:view];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * 7, CGRectGetHeight(self.scrollView.bounds));
    int i = 0;
    for (UIView *view in self.insideViewsArray) {
        CGPoint center = CGPointMake(CGRectGetWidth(self.scrollView.bounds)/2 + CGRectGetWidth(self.scrollView.bounds)*i, CGRectGetHeight(self.scrollView.bounds)/2);
        view.center = center;
        i++;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
