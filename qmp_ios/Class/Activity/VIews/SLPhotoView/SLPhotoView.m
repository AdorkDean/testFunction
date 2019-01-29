//
//  SLPhotoView.m
//  SLWeibo
//
//  Created by Sleen Xiu on 16/1/11.
//  Copyright © 2016年 cn.Xsoft. All rights reserved.
//

#import "SLPhotoView.h"
#import "UIImageView+WebCache.h"
@interface SLPhotoView()
@property (nonatomic, weak) UIImageView *tipView;
@property (nonatomic, weak) CALayer *avatarBorder;
@end

@implementation SLPhotoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 添加一个GIF小图片
//        UIImage *image = [UIImage imageNamed:@"timeline_image_gif"];
        UIImageView *tipView = [[UIImageView alloc] init];
        tipView.bounds = CGRectMake(0, 0, 24, 14);
        [self addSubview:tipView];
        self.tipView = tipView;
        
        self.backgroundColor = TABLEVIEW_COLOR;
//        CALayer *avatarBorder = [CALayer layer];
//        avatarBorder.frame = self.bounds;
//        avatarBorder.borderWidth = 1.0;
//        avatarBorder.borderColor = [kColorHEX(@"F5F8FA") CGColor];
//        avatarBorder.shouldRasterize = YES;
//        avatarBorder.rasterizationScale = [UIScreen mainScreen].scale;
//        [self.layer addSublayer:avatarBorder];
//        self.avatarBorder = avatarBorder;
        self.clipsToBounds = YES;
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.avatarBorder.frame = self.bounds;
}

- (void)setPhoto:(NSString *)photo
{
    _photo = photo;
    
    // 控制gifView的可见性
    self.tipView.hidden = NO;
    if (!_is_article) {
//        if (photo.is_gif) {
//            self.tipView.image = [UIImage xsl_imageWithOriginal:@"gif_tip"];
//        } else if (photo.is_long) {
//            self.tipView.image = [UIImage xsl_imageWithOriginal:@"long_tip"];
//        } else {
            self.tipView.image = [UIImage new];
            self.tipView.hidden = YES;
//        }
    }else {
        self.tipView.hidden = YES;
    }
    
    self.userInteractionEnabled = NO;
    
    NSString *str = [photo isKindOfClass:[NSString class]] ? photo:[(NSDictionary*)photo valueForKey:@"url"];

    self.userInteractionEnabled = YES;

    
    // 下载图片
    [self sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSLog(@"------%@",error);
    }];
//    [self sd_setImageWithURL:[HYHelper hy_urlWithImageStr:str]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tipView.layer.anchorPoint = CGPointMake(1, 1);
    self.tipView.layer.position = CGPointMake(self.frame.size.width-4, self.frame.size.height-4);
    
}

@end

