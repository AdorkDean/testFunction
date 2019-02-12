//
//  ScreenShareView.m
//  qmp_ios
//
//  Created by QMP on 2018/3/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ScreenShareView.h"

@interface ScreenShareView()
{
    UIImageView *_imgView;
    NSMutableArray *_btnArr;
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIView *bottomV;

@property(nonatomic,copy)SelectedPlatform selectedPlatform;

@end

@implementation ScreenShareView

-(void)awakeFromNib{

    [super awakeFromNib];
    
}

-(void)setImage:(UIImage *)image{
    _image = image;
    [self setUI];
}
- (void)setUI{
    
    _btnArr = [NSMutableArray array];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.64];
    
    _scrollV.backgroundColor = [UIColor clearColor];
    _scrollV.showsVerticalScrollIndicator = NO;
    
    CGFloat height = (SCREENW - 128)*self.image.size.height/self.image.size.width;
    _scrollV.width = SCREENW - 128;
    _scrollV.height = SCREENH - 88 - 80;
    _scrollV.bounces = NO;
    
    _scrollV.contentSize = CGSizeMake(_scrollV.width, height);
    _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENW - 128, height)];
    [_scrollV addSubview:_imgView];
    _imgView.image = self.image;
    
    [self addView];
    
    if (@available(iOS 11.0, *)) {
        
        _scrollV.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
    }
}

- (void)addView{
    
    [_btnArr removeAllObjects];
    
    NSArray *titles = @[@"微信朋友",@"微信朋友圈",@"微信收藏",@"存入本地"];
    NSArray *images = @[[UIImage imageNamed:@"share_friend"],[UIImage imageNamed:@"share_friendQuan"],[UIImage imageNamed:@"share_collect"],[UIImage imageNamed:@"share_down"]];
    CGFloat width = 44;
    CGFloat height = 44;
    CGFloat imgTop = 10;
    CGFloat edge = 29;
    CGFloat left = SCREENW - width*titles.count - edge*(titles.count-1) - 18;
    for (int i=0; i<titles.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(left+i*(width+edge), imgTop, width, height)];
        [btn setImage:images[i] forState:UIControlStateNormal];
        [self.bottomV addSubview:btn];
        [btn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000 + i;
        [_btnArr addObject:btn];
        
    }
}

- (void)shareBtnClick:(UIButton*)btn{
    
    NSInteger index = btn.tag - 1000;
    NSArray *titles = @[@"微信朋友",@"微信朋友圈",@"微信收藏",@"存入本地"];
    NSString *title = titles[index];
    if ([title isEqualToString:@"微信朋友"]) {
        self.selectedPlatform(ShareTypeWechatSession);
        [self disappear];
    }else if ([title isEqualToString:@"微信朋友圈"]) {
        self.selectedPlatform(ShareTypeWechatTimeLine);
        [self disappear];
    }else if ([title isEqualToString:@"微信收藏"]) {
        self.selectedPlatform(ShareTypeWechatFavorite);
        [self disappear];
    }else if ([title isEqualToString:@"存入本地"]) {
        //存储到本地
        UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        [PublicTool showMsg:@"保存成功"];
        [self disappear];
    }
}

- (IBAction)backBtnClick:(id)sender {
    [self disappear];
}


+(ScreenShareView*)showShareViewWithImage:(UIImage*)shareImg didTapPlatform:(SelectedPlatform)selectPlayform{

    ScreenShareView *shareVC = [[NSBundle mainBundle] loadNibNamed:@"ScreenShareView" owner:nil options:nil].lastObject;
    shareVC.frame = [UIScreen mainScreen].bounds;
    shareVC.image = shareImg;
    shareVC.selectedPlatform = selectPlayform;
    
    [KEYWindow addSubview:shareVC];
    
    return shareVC;
   
}

-(void)setSelectedPlatform:(SelectedPlatform)selectedPlatform{
    _selectedPlatform = selectedPlatform;
}


-(void)disappear{
    
    [self removeFromSuperview];;
}



@end
