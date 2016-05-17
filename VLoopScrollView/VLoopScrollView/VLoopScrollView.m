//
//  VLoopScrollView.m
//  VLoopScrollView
//
//  Created by vincent on 16/5/17.
//  Copyright © 2016年 VinHand. All rights reserved.
//

#import "VLoopScrollView.h"
//  use sd usually
#import "UIImageView+WebCache.h"


#define scro_width  self.frame.size.width
#define scro_height self.frame.size.height

#define pageControl_width 100
#define pageControl_height 30

#define AD_betweenLoopTime 2   //在此修改 图片切换间隔时间
#define AD_LoopTime 0.5 //在此修改 图片切换速度（时间越短速度越快）

@interface VLoopScrollView()

@property (nonatomic, weak) UIImageView *imageView_before;

@property (nonatomic, weak) UIImageView *imageView_middle;

@property (nonatomic, weak) UIImageView *imageView_after;

@property (nonatomic, weak) UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *adScrollTimer;



@property (nonatomic, strong) NSArray *adImageArray;

@property (nonatomic, assign) NSInteger currentPage;

@end



@implementation VLoopScrollView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor orangeColor];
        self.delegate = self;
        [self setupUI];
        [self detailAdjust];
        
    }
    return self;
}

- (void)detailAdjust
{
    /**
     *  默认带翻页效果，隐藏滚动条（上下，左右），隐藏弹簧效果
     */
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.bounces = NO;
    //    初始位置是 中间的页面
    self.contentOffset = CGPointMake(scro_width, 0);
    
}


- (void)setupUI
{
    
    CGRect rectBefore;
    CGRect rectMiddle;
    CGRect rectAfter;
    
    rectBefore = CGRectMake(0*scro_width, 0, scro_width, scro_height);
    rectMiddle = CGRectMake(1*scro_width, 0, scro_width, scro_height);
    rectAfter  = CGRectMake(2*scro_width, 0, scro_width, scro_height);

    UIImageView *imageView_before = [[UIImageView alloc] init];
    imageView_before.backgroundColor = [UIColor orangeColor];
    imageView_before.frame = rectBefore;
    [self addSubview:imageView_before];
    _imageView_before = imageView_before;
    
    UIImageView *imageView_middle = [[UIImageView alloc] init];
    imageView_before.backgroundColor = [UIColor orangeColor];
    imageView_middle.frame = rectMiddle;
    [self addSubview:imageView_middle];
    _imageView_middle = imageView_middle;
    
    UIImageView *imageView_after = [[UIImageView alloc] init];
    imageView_after.backgroundColor = [UIColor orangeColor];
    imageView_after.frame = rectAfter;
    [self addSubview:imageView_after];
    _imageView_after = imageView_after;
    
}

- (void)logicalOfADScrollWithImageArray:(NSArray *)imageArray
{
    _pageControl.numberOfPages = imageArray.count;
    _adImageArray = imageArray;
    
    //    currentPage 就是逻辑上的位置  初始就是 0 顺序就是 last, 0,  1 .........
    _currentPage = 0;
    _pageControl.currentPage = _currentPage;
    
    //    防止数组为空
    if (_adImageArray.count)
    {
        [self.imageView_before sd_setImageWithURL:[NSURL URLWithString:_adImageArray.lastObject] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
        
        [self.imageView_middle sd_setImageWithURL:[NSURL URLWithString:_adImageArray.firstObject] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
        
        
        //    特殊情况 数组元素只有一个的时候
        if (_adImageArray.count == 1) {
            
            [self.imageView_after sd_setImageWithURL:[NSURL URLWithString:_adImageArray.firstObject] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
        }
        else
        {
            [self.imageView_after sd_setImageWithURL:[NSURL URLWithString:_adImageArray[1]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
        }
    }
}

- (void)addPageControlWithNumberOfPage:(NSInteger)number currentPage:(NSInteger)currentPage controller:(UIViewController *)vc
{
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    
    pageControl.frame = CGRectMake((scro_width - pageControl_width)/2, scro_height + 64 - pageControl_height, pageControl_width, pageControl_height);
    pageControl.numberOfPages = number;
    pageControl.currentPage = currentPage;
    _currentPage = currentPage;
    
    [vc.view addSubview:pageControl];
    _pageControl = pageControl;
}


- (void) addRepeatTimer
{
    if (!_adScrollTimer) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:AD_betweenLoopTime target:self selector:@selector(repeatMove) userInfo:nil repeats:YES];
        _adScrollTimer = timer;
    }
}

- (void)removeTimer
{
    [_adScrollTimer invalidate];
}

//    轮播图片
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%s",__func__);
    /**
     初始位置
     middle = 0
     before = 最后一个
     after = 1
     */
    NSInteger page_before = 0;
    NSInteger page_middle = 0;
    NSInteger page_after  = 0;
    
    
    //    －－－－－－－－－－－ 调整 逻辑位置 －－－－－－－－－－－
    if (self.contentOffset.x == 0)
    {
        //        往前滑了一格  (-)
        page_before = [self changePage:_currentPage - 2];
        page_middle = [self changePage:_currentPage - 1];
        page_after =  [self changePage:_currentPage];
        self.pageControl.currentPage = [self changePage:_currentPage - 1];
    }
    else if (self.contentOffset.x == scro_width * 2)
    {
        //        往后滑了一格  (+)
        page_before = [self changePage:_currentPage];
        page_middle = [self changePage:_currentPage + 1];
        page_after =  [self changePage:_currentPage + 2];
        self.pageControl.currentPage = [self changePage:_currentPage + 1];
    }
    else if (self.contentOffset.x == scro_width)
    {
        //        保持原来位置的时候  (not move)
        page_before = [self changePage:_currentPage - 1];
        page_middle = [self changePage:_currentPage];
        page_after =  [self changePage:_currentPage + 1];
    }
    //    －－－－－－－－－－－－－－设置图片 －－－－－－－－－－－－－－－－－－－－－－
    //    防止数组为空 (0就不进入了)
    if (_adImageArray.count)
    {
        //        数组元素只有1个的 特殊情况
        if (_adImageArray.count == 1) {
            
        }
        else
        {
            [self.imageView_before sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_before]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            [self.imageView_middle sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_middle]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            [self.imageView_after sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_after]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
        }
        _currentPage = page_middle;
    }
    else
    {
        _currentPage = 0;
    }
    
    //        视角还是回到中间
    self.contentOffset = CGPointMake(scro_width, 0);
    
    NSLog(@"--- location is %ld",(long)_currentPage);
}

- (void)repeatMove
{
    //    NSLog(@"%s",__func__);
    NSInteger page_before = 0;
    NSInteger page_middle = 0;
    NSInteger page_after  = 0;
    
    
    if (_adImageArray.count > 1)
    {
        [UIView animateWithDuration:AD_LoopTime animations:^{
            self.contentOffset = CGPointMake(scro_width*2, 0);
        }];
        
        page_before = [self changePage:_currentPage];
        page_middle = [self changePage:_currentPage + 1];
        page_after  =  [self changePage:_currentPage + 2];
        
        
        self.pageControl.currentPage = [self changePage:_currentPage + 1];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AD_LoopTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.imageView_before sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_before]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            [self.imageView_middle sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_middle]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            [self.imageView_after sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_after]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            self.contentOffset = CGPointMake(scro_width, 0);
        });
        _currentPage = page_middle;
        NSLog(@"--- currentPage is %ld",(long)_currentPage);
    }
    else if (_adImageArray.count == 1)
    {
//        图片只有一个的时候
        [UIView animateWithDuration:AD_LoopTime animations:^{
            self.contentOffset = CGPointMake(scro_width*2, 0);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AD_LoopTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.contentOffset = CGPointMake(scro_width, 0);
        });
    }
}

//    防止page 出现 < 0 或是超出 图片最大数量
- (NSInteger)changePage:(NSInteger)page
{
    if (page < 0) {
        page = page + _adImageArray.count;
    }
    if (page > _adImageArray.count - 1) {
        page = page - _adImageArray.count;
    }
    return page;
}



@end
