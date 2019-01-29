//
//  ScreenShareController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ScreenShareController.h"

@interface ScreenShareController ()
{
    UIImageView *_imgView;
    NSMutableArray *_btnArr;
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIView *bottomV;

@property(nonatomic,copy)SelectedPlatform selectedPlatform;

@end

@implementation ScreenShareController
-(instancetype)init{
    ScreenShareController *vc = [[ScreenShareController alloc]initWithNibName:@"ScreenShareController" bundle:[BundleTool commonBundle]];
    return vc;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _btnArr = [NSMutableArray array];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    _scrollV.backgroundColor = [UIColor whiteColor];
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
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}


- (void)addView{
    
    [_btnArr removeAllObjects];
    
    NSArray *titles = @[@"微信朋友",@"微信朋友圈",@"微信收藏",@"存入本地"];
    NSArray *images = @[[BundleTool imageNamed:@"share_friend"],[BundleTool imageNamed:@"share_friendQuan"],[BundleTool imageNamed:@"share_collect"],[BundleTool imageNamed:@"share_down"]];
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
        [self disappear];
    }
}

- (IBAction)backBtnClick:(id)sender {
    [self disappear];
}

+(ScreenShareController*)showShareViewWithImage:(UIImage*)shareImg didTapPlatform:(SelectedPlatform)selectPlayform{
    
    ScreenShareController *shareVC = [[ScreenShareController alloc]init];
    shareVC.image = shareImg;
    shareVC.selectedPlatform = selectPlayform;
    [[PublicTool topViewController] presentViewController:shareVC animated:YES
                                               completion:nil];
    return shareVC;
}

-(void)setSelectedPlatform:(SelectedPlatform)selectedPlatform{
    _selectedPlatform = selectedPlatform;
}


-(void)disappear{
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}





@end
