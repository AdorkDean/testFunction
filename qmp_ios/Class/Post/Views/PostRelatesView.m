//
//  PostRelatesView.m
//  qmp_ios
//
//  Created by QMP on 2018/10/16.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "PostRelatesView.h"
#import "ActivityModel.h"
@interface PostActivityRelateView : UIButton
@property (nonatomic, strong) ActivityRelateModel *relate;

@property (nonatomic, copy) void (^deleteClick)(void);
@end

@implementation PostRelatesView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    for (int i = 0; i < 5; i++) {
        PostActivityRelateView *item = [[PostActivityRelateView alloc] init];
        item.hidden = YES;
        [self addSubview:item];
    }
}
- (CGFloat )reloadWithSelectedObjects:(NSArray *)objects {
    
    self.relates = objects;
   
    
    CGFloat h = 22;
    CGFloat margin_h = 15;
    CGFloat margin_v = 12;
    UIFont *font = [UIFont systemFontOfSize:12];
    CGFloat t = 7;
    CGFloat l = 0;
    CGFloat maxW = SCREENW - 34 - 7;
    NSInteger i = 0;
    
    for (PostActivityRelateView *relateView in self.subviews) {
        if (i >= objects.count) {
            relateView.hidden = YES;
            i++;
            continue;
        }
        
        relateView.hidden = NO;
        ActivityRelateModel *model = objects[i];
        CGFloat textW = [self calculateLabelWidthWithString:model.name height:ceil(font.lineHeight) font:font];
        CGFloat w = textW + 30;
        if (l + w > maxW) {
            l = 0;
            t = t + h + margin_v;
        }
        relateView.relate = model;
        relateView.frame = CGRectMake(l, t, w, h);
        l = l + w + margin_h;
        
        __weak typeof(self) weakSelf = self;
        relateView.deleteClick = ^{
            if (weakSelf.didDeleteObject) {
                weakSelf.didDeleteObject(model, i);
            }
        };
        
        i++;
    }
    return t + h;
}
- (CGFloat)calculateLabelWidthWithString:(NSString *)string height:(CGFloat)height font:(UIFont *)font {
    if (string.length == 0) {
        return 0.f;
    }
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    
    return ceil(size.width);
}

@end


@interface PostActivityRelateView ()

@property (nonatomic, strong) UIButton *deleteView;
@end

@implementation PostActivityRelateView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        [self setTitleColor:COLOR8C909B forState:UIControlStateNormal];
        self.backgroundColor = HTColorFromRGB(0xF6F7F8);
        [self addSubview:self.deleteView];
    }
    return self;
}
- (void)setRelate:(ActivityRelateModel *)relate {
    _relate = relate;

    [self setTitle:relate.name forState:UIControlStateNormal];
    [self setImage:[BundleTool imageNamed:relate.qmpIcon] forState:UIControlStateNormal];
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(7, 5, contentRect.size.height-10, contentRect.size.height-10);
}
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(23, 0, contentRect.size.width-23, contentRect.size.height);
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.deleteView.center = CGPointMake(self.width, 0);
}
- (void)deleteViewClick {
    if (self.deleteClick) {
        self.deleteClick();
    }
}
- (UIButton *)deleteView {
    if (!_deleteView) {
        _deleteView = [[UIButton alloc] init];
        _deleteView.frame = CGRectMake(0, 0, 20, 20);
        [_deleteView setImage:[BundleTool imageNamed:@"post_activity_delete"] forState:UIControlStateNormal];
        [_deleteView addTarget:self action:@selector(deleteViewClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteView;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        // 转换坐标系
        CGPoint newPoint = [self.deleteView convertPoint:point fromView:self];
        // 判断触摸点是否在button上
        if (CGRectContainsPoint(self.deleteView.bounds, newPoint)) {
            view = self.deleteView;
        }
    }
    return view;
}

@end
