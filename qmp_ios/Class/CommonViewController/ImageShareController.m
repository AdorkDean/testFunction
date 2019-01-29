//
//  ImageShareController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ImageShareController.h"

@interface ImageShareController ()
{
    UIImageView *_imgView;
    
    __weak IBOutlet UIView *_bottomView;
    __weak IBOutlet UIScrollView *_scrollV;
    NSMutableArray *_btnArr;
    
}

@property(nonatomic,copy)SelectedPlatform selectedPlatform;

@end

@implementation ImageShareController
-(instancetype)init{
    ImageShareController *vc = [[ImageShareController alloc]initWithNibName:@"ImageShareController" bundle:[BundleTool commonBundle]];
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _btnArr = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    _scrollV.backgroundColor = [UIColor clearColor];
    _scrollV.showsVerticalScrollIndicator = NO;
    CGFloat height = SCREENW*self.image.size.height/self.image.size.width;
    _scrollV.width = SCREENW;
    _scrollV.height = SCREENH - 88;
    _scrollV.bounces = NO;
    
    _scrollV.contentSize = CGSizeMake(_scrollV.width, height);
    _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, height)];
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
        [_bottomView addSubview:btn];
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

+(ImageShareController*)showShareViewWithImage:(UIImage*)shareImg didTapPlatform:(SelectedPlatform)selectPlayform{

    ImageShareController *shareVC = [[ImageShareController alloc]init];
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
