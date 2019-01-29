//
//  SLPhotosView.m
//  SLWeibo
//
//  Created by Sleen Xiu on 16/1/11.
//  Copyright © 2016年 cn.Xsoft. All rights reserved.
//

#import "SLPhotosView.h"
#import "SLPhotoView.h"
#import "ActivityModel.h"
//#import "UIImageView+LCCKExtension.h"

#define SLPhotoMargin 4
#define SLPhotoW (SCREENW - 17*2 - SLPhotoMargin*2)/3.0
#define SLPhotoH (SCREENW - 17*2 - SLPhotoMargin*2)/3.0

@interface SLPhotoView () 
@end
@implementation SLPhotosView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // 初始化9个子控件
        for (int i = 0; i<9; i++) {
            SLPhotoView *photoView = [[SLPhotoView alloc] init];
            photoView.contentMode = UIViewContentModeScaleAspectFill;
            photoView.userInteractionEnabled = YES;
            photoView.alpha = 1.0;
            photoView.tag = i;
//            photoView.backgroundColor = [UIColor clearColor];
            [photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap:)]];
            [self addSubview:photoView];
        }
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)photoTap:(UITapGestureRecognizer *)recognizer {
//    if ([self.delegate respondsToSelector:@selector(photoViewsDidClickImage:)]) {
//        [self.delegate photoViewsDidClickImage:recognizer.view.tag];
//    }

    int count = (int)self.photoModels.count;
    count = count > 9 ? 9 : count;
    
    // 1.封装图片数据
    NSMutableArray *myphotos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 一个MJPhoto对应一张显示的图片
        MJPhoto *mjphoto = [[MJPhoto alloc] init];
        
        if (i >= self.subviews.count) {
            return;
        }
        
        mjphoto.srcImageView = self.subviews[i]; // 来源于哪个UIImageView
        mjphoto.srcView = self.subviews[i];
//        NSString *photo = self.photos[i];
        
        ActivityImageModel *im = _photoModels[i];
        mjphoto.url = [NSURL URLWithString:im.url];
//        if ([photo isKindOfClass:[NSString class]]) {
//            mjphoto.url = [NSURL URLWithString:photo]; // 图片路径
//        }else if ([photo isKindOfClass:[NSDictionary class]]) {
//            mjphoto.url = [NSURL URLWithString:[(NSDictionary*)photo valueForKey:@"url"]]; // 图片路径
//        }

        [myphotos addObject:mjphoto];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.photos = myphotos; // 设置所有的图片
    browser.barStyle = [UIApplication sharedApplication].statusBarStyle;
    browser.currentPhotoIndex = recognizer.view.tag; // 弹出相册时显示的第一张图片是？
    [browser show];
    browser.delegate = self;
    
}
- (void)setPhotoModels:(NSArray<ActivityImageModel *> *)photoModels {
    _photoModels = photoModels;
    
    for (int i = 0; i<self.subviews.count; i++) {
        // 取出i位置对应的imageView
        SLPhotoView *photoView = self.subviews[i];
        photoView.is_article = _is_article;
        // 判断这个imageView是否需要显示数据
        if (i < _photoModels.count) {
            // 显示图片
            photoView.hidden = NO;
            
            // 传递模型数据
            if (_photoModels.count == 1) {
                ActivityImageModel *im = [_photoModels firstObject];
                photoView.is_onlyOne = YES;
                photoView.clipsToBounds = YES;

                if (im.width > im.height) {
                    CGFloat a = (SCREENW * 2 / 3) / im.width * im.height;
                    a = MAX((SCREENW-34)*0.33, a);
                    photoView.frame = CGRectMake(0, 0, (SCREENW * 2 / 3), a);
                } else {
                    CGFloat a = ((SCREENW-34)*0.5) / im.width * im.height;
                    a = MIN(a, (SCREENW-34)*0.8);
                    photoView.frame = CGRectMake(0, 0, (SCREENW-34)*0.5, a);
                }
                
                photoView.photo = im.smallUrl;
                
            }
            else {
                photoView.is_onlyOne = NO;
                photoView.clipsToBounds = YES;
                
                int maxColumns = (_photoModels.count == 4) ? 2 : 3;
                int col = i % maxColumns;
                int row = i / maxColumns;
                CGFloat photoX = col * (SLPhotoW + SLPhotoMargin);
                CGFloat photoY = row * (SLPhotoH + SLPhotoMargin);
                photoView.frame = CGRectMake(photoX, photoY, SLPhotoW, SLPhotoH);
                
                ActivityImageModel *im = _photoModels[i];
                photoView.photo = im.squareUrl;
                
            }
            
            //            photoView.lcck_cornerRadius = 4;
        } else { // 隐藏imageView
            photoView.hidden = YES;
        }
    }
}
- (void)setPhotos:(NSArray<NSString *> *)photos {
    _photos = photos;
    
    for (int i = 0; i<self.subviews.count; i++) {
        // 取出i位置对应的imageView
        SLPhotoView *photoView = self.subviews[i];
        photoView.is_article = _is_article;
        // 判断这个imageView是否需要显示数据
        if (i < photos.count) {
            // 显示图片
            photoView.hidden = NO;
            
            // 传递模型数据
            
          
            if (photos.count == 1) {
                photoView.is_onlyOne = YES;
                photoView.clipsToBounds = YES;
                CGFloat scale = SCREENW / 375.0;
                photoView.frame = CGRectMake(0, 0, 230*scale, 175*scale);
            }
            else {
                photoView.is_onlyOne = NO;
                photoView.clipsToBounds = YES;
                
                int maxColumns = (photos.count == 4) ? 2 : 3;
                int col = i % maxColumns;
                int row = i / maxColumns;
                CGFloat photoX = col * (SLPhotoW + SLPhotoMargin);
                CGFloat photoY = row * (SLPhotoH + SLPhotoMargin);
                photoView.frame = CGRectMake(photoX, photoY, SLPhotoW, SLPhotoH);
                
            }
            
            
            photoView.photo = photos[i];
//            photoView.lcck_cornerRadius = 4;
        } else { // 隐藏imageView
            photoView.hidden = YES;
        }
    }
}
#pragma mark - MJPhotoBrowserDelegate
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index {
    NSLog(@"%s", __func__);
}
- (void)photoBrowserDidPhotosAllLooked:(MJPhotoBrowser *)photoBrowser {
    NSLog(@"%s", __func__);
    if ([self.delegate respondsToSelector:@selector(photoViewsAllImagesLooked)]) {
        [self.delegate photoViewsAllImagesLooked];
    }
}
#pragma mark - class public
+ (CGSize)photosViewSizeWithPhotosCount:(int)count
{
    if (count == 1) {
        return CGSizeMake(200, 180);
    }
    
    // 一行最多有3列
    int maxColumns = (count == 4) ? 2 : 3;
    
    //  总行数
    int rows = (count + maxColumns - 1) / maxColumns;
    
    rows = (count > 9) ? 3 : rows;
    
    // 高度
    CGFloat photosH = rows * SLPhotoH + (rows - 1) * SLPhotoMargin;
    
    // 总列数
    int cols = (count >= maxColumns) ? maxColumns : count;
    // 宽度
    CGFloat photosW = cols * SLPhotoW + (cols - 1) * SLPhotoMargin;
    return CGSizeMake(photosW, photosH);
}
+ (CGSize)qmp_photosViewSizeWithPhotosCount:(int)count
{
    if (count == 1) {
        CGFloat scale = SCREENW / 375.0;
        return CGSizeMake(230*scale, 175*scale);
    }
//    if (count == 2) {
//        CGFloat scale = 110/166.0;
//        return CGSizeMake((SCREENW-34), (SCREENW-34-9)/2.0*scale);
//    }
//    if (count == 3) {
//        CGFloat scale = 90/108.0;
//        return CGSizeMake((SCREENW-34), (SCREENW-34-16)/3.0*scale);
//    }
    return [self photosViewSizeWithPhotosCount:count];
}
+ (CGSize)qmp_onePhotoViewSizeWithImageModel:(ActivityImageModel *)image {
    if (image.width > image.height) {
        CGFloat a = (SCREENW * 2 / 3) / image.width * image.height;
        a = MAX((SCREENW-34)*0.33, a);
        return CGSizeMake((SCREENW * 2 / 3), a);
    } else {
        CGFloat a = (SCREENW-34)*0.5 / image.width * image.height;
        a = MIN(a, (SCREENW-34)*0.8);
        return CGSizeMake((SCREENW-34)*0.5, a);
    }
}

+ (CGSize)qmp_photosViewSizeWithPhotosCount:(int)count maxWidth:(CGFloat)width {
    if (count == 0) {
        return CGSizeZero;
    }
    int maxColumns = (count == 4) ? 2 : 3;
    
    CGFloat photoWH = (width - SLPhotoMargin * 2)/3.0;
    
    //  总行数
    int rows = (count + maxColumns - 1) / maxColumns;
    
    rows = (count > 9) ? 3 : rows;
    
    // 高度
    CGFloat photosH = rows * photoWH + (rows - 1) * SLPhotoMargin;
    
    // 总列数
    int cols = (count >= maxColumns) ? maxColumns : count;
    // 宽度
    CGFloat photosW = cols * photoWH + (cols - 1) * SLPhotoMargin;
    return CGSizeMake(photosW, photosH);
}
@end
