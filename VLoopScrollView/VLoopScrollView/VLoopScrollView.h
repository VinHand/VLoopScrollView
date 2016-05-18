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
- (void) v_logicalOfADScrollWithImageArray:(NSArray *)imageArray;

/**
 *  if you want repeat then add it
 */
- (void) v_addRepeatTimer;

/**
 *  remember remove after add Timer
 */
- (void) v_removeTimer;

/**
 *  about PageControl
 *
 *  @param number      total number of pages
 *  @param currentPage
 */
- (void) v_addPageControlWithNumberOfPage:(NSInteger)number currentPage:(NSInteger)currentPage controller:(UIViewController *)vc;

@end
