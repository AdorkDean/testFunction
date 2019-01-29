//
//  PostLinkPopView.m
//  qmp_ios
//
//  Created by QMP on 2018/10/19.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "PostLinkPopView.h"

@interface PostLinkPopView ()
@property (nonatomic, weak) UIImageView *lv;
@property (nonatomic, weak) UIImageView *rv;
@end
@implementation PostLinkPopView

- (instancetype)init {
    self = [super init];
    if (self) {
//        _linkPopView.frame = CGRectMake(129, SCREENH-kScreenTopHeight-50+4-62, 128, 62);
//        _linkPopView.image = [self fixLinkPopImage];
        
        UIImageView *lv = [[UIImageView alloc] init];
        lv.frame = CGRectMake(0, SCREENH-kScreenTopHeight-50+4-62, 128, 62);
        lv.image = [self fixLinkPopImage:@"post_link_pop_l"];
        [self addSubview:lv];
        self.lv = lv;
        
        UIImageView *rv = [[UIImageView alloc] init];
        rv.frame = CGRectMake(0, SCREENH-kScreenTopHeight-50+4-62, 128, 62);
        rv.image = [self fixLinkPopImage:@"post_link_pop_r"];
        [self addSubview:rv];
        self.rv = rv;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(10, 10, 100, 13);
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        label.text = @"发现新链接：";
        [self addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.frame = CGRectMake(10, 27, 108, 15);
        label2.font = [UIFont systemFontOfSize:13];
        label2.textColor = [UIColor whiteColor];
        [self addSubview:label2];
        self.linkPopLabel = label2;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.lv.frame = CGRectMake(0, 0, self.width/2.0, self.height);
    self.rv.frame = CGRectMake(self.width/2.0, 0, self.width/2.0, self.height);
}
- (UIImage *)fixLinkPopImage:(NSString *)name {
    UIImage *im = [BundleTool imageNamed:name];
    return [im resizableImageWithCapInsets:UIEdgeInsetsMake(im.size.height*0.5-1, im.size.width * 0.5f-1, im.size.height*0.5+1, im.size.width * 0.5f+1) resizingMode:UIImageResizingModeTile];
}
@end
