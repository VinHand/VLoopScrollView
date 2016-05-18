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
#define AD_LoopTime 0.5 //在此修改 图片切换过程需要的时间

@interface VLoopScrollView()
/**
 *  BEF = before
 *  MID = middle
 *  AFT = after
 --- do not laugh (be my guest) lol
 */
@property (nonatomic, weak) UIImageView *imageView_BEF;

@property (nonatomic, weak) UIImageView *imageView_MID;

@property (nonatomic, weak) UIImageView *imageView_AFT;

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
    
    CGRect rect_BEF;
    CGRect rect_MID;
    CGRect rect_AFT;
    
    rect_BEF = CGRectMake(0*scro_width, 0, scro_width, scro_height);
    rect_MID = CGRectMake(1*scro_width, 0, scro_width, scro_height);
    rect_AFT  = CGRectMake(2*scro_width, 0, scro_width, scro_height);

    UIImageView *imageView_BEF = [[UIImageView alloc] init];
    imageView_BEF.backgroundColor = [UIColor whiteColor];
    imageView_BEF.frame = rect_BEF;
    [self addSubview:imageView_BEF];
    _imageView_BEF = imageView_BEF;
    
    UIImageView *imageView_MID = [[UIImageView alloc] init];
    imageView_MID.backgroundColor = [UIColor whiteColor];
    imageView_MID.frame = rect_MID;
    [self addSubview:imageView_MID];
    _imageView_MID = imageView_MID;
    
    UIImageView *imageView_AFT = [[UIImageView alloc] init];
    imageView_AFT.backgroundColor = [UIColor whiteColor];
    imageView_AFT.frame = rect_AFT;
    [self addSubview:imageView_AFT];
    _imageView_AFT = imageView_AFT;
    
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
        [_imageView_BEF sd_setImageWithURL:[NSURL URLWithString:_adImageArray.lastObject] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
        
        [_imageView_MID sd_setImageWithURL:[NSURL URLWithString:_adImageArray.firstObject] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
        
        
        //    特殊情况 数组元素只有一个的时候
        if (_adImageArray.count == 1) {
            
            [_imageView_AFT sd_setImageWithURL:[NSURL URLWithString:_adImageArray.firstObject] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
        }
        else
        {
            [_imageView_AFT sd_setImageWithURL:[NSURL URLWithString:_adImageArray[1]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
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
    NSInteger page_BEF = 0;
    NSInteger page_MID = 0;
    NSInteger page_AFT = 0;
    
    
    //    －－－－－－－－－－－ 计算得到 逻辑位置（下面用这个位置去加载图片） －－－－－－－－－－－
    if (self.contentOffset.x == 0)
    {
        //        往前滑了一格  (-)
        page_BEF = [self changePage:_currentPage - 2];
        page_MID = [self changePage:_currentPage - 1];
        page_AFT =  [self changePage:_currentPage];
        self.pageControl.currentPage = [self changePage:_currentPage - 1];
    }
    else if (self.contentOffset.x == scro_width * 2)
    {
        //        往后滑了一格  (+)
        page_BEF = [self changePage:_currentPage];
        page_MID = [self changePage:_currentPage + 1];
        page_AFT =  [self changePage:_currentPage + 2];
        self.pageControl.currentPage = [self changePage:_currentPage + 1];
    }
    else if (self.contentOffset.x == scro_width)
    {
        //        保持原来位置的时候  (not move)
        page_BEF = [self changePage:_currentPage - 1];
        page_MID = [self changePage:_currentPage];
        page_AFT =  [self changePage:_currentPage + 1];
    }
    
    //    －－－－－－－－－－－－－－设置图片 －－－－－－－－－－－－－－－－－－－－－－
    //    防止数组为空 (0就不进入了)
    if (_adImageArray.count)
    {
        //        数组元素只有1个的 特殊情况
        if (_adImageArray.count == 1) {
        //        图片只有一个的时候不需要设置图片，因为都一样
        }
        else
        {
            [_imageView_BEF sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_BEF]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            [_imageView_MID sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_MID]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            [_imageView_AFT sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_AFT]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
        }
//        middle 是主角
        _currentPage = page_MID;
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
    NSInteger page_BEF = 0;
    NSInteger page_MID = 0;
    NSInteger page_AFT = 0;
    
    
    if (_adImageArray.count > 1)
    {
        [UIView animateWithDuration:AD_LoopTime animations:^{
            self.contentOffset = CGPointMake(scro_width*2, 0);
        }];
        
        page_BEF = [self changePage:_currentPage];
        page_MID = [self changePage:_currentPage + 1];
        page_AFT  = [self changePage:_currentPage + 2];
        
        
        self.pageControl.currentPage = [self changePage:_currentPage + 1];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AD_LoopTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [_imageView_BEF sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_BEF]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            [_imageView_MID sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_MID]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            [_imageView_AFT sd_setImageWithURL:[NSURL URLWithString:_adImageArray[page_AFT]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageDelayPlaceholder];
            self.contentOffset = CGPointMake(scro_width, 0);
        });
        _currentPage = page_MID;
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
