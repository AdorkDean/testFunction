//
//  ShareTo.h
//  QimingpianSearch
//
//  Created by Molly on 16/8/6.
//  Copyright © 2016年 qimingpian. All rights reserved.
//
//新分享UI

//后期：将分享参数进行集成，简化


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol ShareDelegate <NSObject>

- (void)shareSuccess;
- (void)shareFaild;

@end
typedef void(^ShareResult)(BOOL shareSuccess);
@interface ShareTo : NSObject

@property (weak, nonatomic) id<ShareDelegate> delegate;
@property (copy, nonatomic)ShareResult shareResult;

//新 分享UI
- (void)shareToOtherApp:(NSString *)detailStr aTitleSessionStr:(NSString *)titleSessionStr aTitleTimelineStr:(NSString *)titleTimelineStr aIcon:(id)icon aOpenUrl:(NSString *)urlStr onViewController:(UIViewController *)viewController shareResult:(ShareResult) shareResult;

- (void)shareWithDetailStr:(NSString *)detailStr sessionTitle:(NSString *)sessionTitle timelineTitle:(NSString *)timelineTitle copyString:(NSString*)copyString aIcon:(id)icon aOpenUrl:(NSString *)urlStr onViewController:(UIViewController *)viewController shareResult:(ShareResult) shareResult;

/** 指定分享到微信好友*/
- (void)shareToWechat:(NSString *)detailStr aTitleSessionStr:(NSString *)titleSessionStr aTitleTimelineStr:(NSString *)titleTimelineStr aIcon:(id)icon aOpenUrl:(NSString *)urlStr shareResult:(ShareResult) shareResult;

- (void)shareImgToOtherApp:(id)shareImgOrImgUrl;
- (void)shareOrginImgToApp:(id)shareImgOrImgUrl;

//详情页 截图的分享
- (void)shareDetailImage:(UIImage*)shareImg;

- (void)shareScreenShotImage:(UIImage*)shareImg;

@end
