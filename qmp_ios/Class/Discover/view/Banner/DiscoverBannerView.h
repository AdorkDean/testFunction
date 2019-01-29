//
//  DiscoverBannerView.h
//  qmp_ios
//
//  Created by QMP on 2018/6/20.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscoverBannerView : UIView

@property (nonatomic, strong) NSArray *dataSource; /**< 数据源 */

- (DiscoverBannerView*)initWithFrame:(CGRect)frame didSelectedIndex:(void (^)(NSInteger index))didSelectedIndex;


@end
