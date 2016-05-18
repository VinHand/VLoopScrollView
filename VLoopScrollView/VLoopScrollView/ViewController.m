//
//  ViewController.m
//  VLoopScrollView
//
//  Created by vincent on 16/5/17.
//  Copyright © 2016年 VinHand. All rights reserved.
//
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "VLoopScrollView.h"

@interface ViewController ()

@property (nonatomic, strong) VLoopScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //    解决 scrollView contentsize 诡异问题（防止自动调整）
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //    让坐标原点点变成（0.64）
//        self.navigationController.navigationBar.translucent = NO;
    
    [self setupUI];
    
}

- (void)setupUI
{
//    位置按自己需求定
    VLoopScrollView *scro = [[VLoopScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 200)];
    scro.contentSize = CGSizeMake(SCREEN_WIDTH * 3, 200);
    [self.view addSubview:scro];
    _scrollView = scro;
    
    
    //      测试图片url数组
    //      图片可以从1，2，3 ........ 很多 都兼容 (自己加吧 ～ sorry)
    NSArray *testArray = @[@"",@"",@""];
    
    //    方法：1  ， 把数组传过去就好
    [_scrollView v_logicalOfADScrollWithImageArray:testArray];
    
    //    方法：2  ， 定时滚动  (if add than remove)
    [_scrollView v_addRepeatTimer];
    
    //    方法：3  ， currentPage：按需求定 （这里是加到了当前控制器的View上）
    [_scrollView v_addPageControlWithNumberOfPage:testArray.count currentPage:0 controller:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //    方法：4  （记得释放掉） ********************************** 重要的事情 说三遍（吹牛逼） ～
    [_scrollView v_removeTimer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
