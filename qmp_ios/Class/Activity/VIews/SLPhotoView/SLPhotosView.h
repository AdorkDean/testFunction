//
//  SLPhotosView.h
//  SLWeibo
//
//  Created by Sleen Xiu on 16/1/11.
//  Copyright © 2016年 cn.Xsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@protocol SLPhotoViewsDelegate;
@class ActivityImageModel;
@interface SLPhotosView : UIView <MJPhotoBrowserDelegate>
/**
 *  需要展示的图片(数组里面装的都是IWPhoto模型)
 */
@property (nonatomic, strong) NSArray<NSString *> *photos;
@property (nonatomic, strong) NSArray<ActivityImageModel *> *photoModels;
@property (nonatomic, copy) NSString *articleId;
/**
 *  根据图片的个数返回相册的最终尺寸
 */
+ (CGSize)photosViewSizeWithPhotosCount:(int)count;
+ (CGSize)qmp_photosViewSizeWithPhotosCount:(int)count;
+ (CGSize)qmp_photosViewSizeWithPhotosCount:(int)count maxWidth:(CGFloat)width;
+ (CGSize)qmp_onePhotoViewSizeWithImageModel:(ActivityImageModel *)image;
@property (nonatomic, assign) BOOL is_article;
@property (nonatomic, weak) id<SLPhotoViewsDelegate> delegate;
@end


@protocol SLPhotoViewsDelegate <NSObject>
@optional
- (void)photoViewsDidClickImage:(NSInteger)index;
- (void)photoViewsAllImagesLooked;
@end
