//
//  VLoopScrollView.h
//  VLoopScrollView
//
//  Created by vincent on 16/5/17.
//  Copyright © 2016年 VinHand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLoopScrollView : UIScrollView<UIScrollViewDelegate>
/**
 *  Give it your params
 *
 *  @param imageArray : Your array of imageURLs
 */
- (void)logicalOfADScrollWithImageArray:(NSArray *)imageArray;

/**
 *  if you want repeat then add it
 */
- (void) addRepeatTimer;

/**
 *  remember remove after add Timer
 */
- (void)removeTimer;

/**
 *  about PageControl
 *
 *  @param number      total number of pages
 *  @param currentPage
 */
- (void)addPageControlWithNumberOfPage:(NSInteger)number currentPage:(NSInteger)currentPage controller:(UIViewController *)vc;

@end
