//
//  WebViewController.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/25.
//  Copyright © 2016年 qimingpian. All rights reserved.
//用于百度一下等 搜索

#import <UIKit/UIKit.h>
@interface WebViewController : BaseViewController

@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *titleLabStr;//标题string
@property (strong, nonatomic) UIImage *printscreenImage;

-(void)rongziShare;
- (void)buildPrintscreenView;
-(void)refreshPage;
@end
