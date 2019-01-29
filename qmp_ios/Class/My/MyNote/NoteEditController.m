//
//  CommenNoteEditController.m
//  qmp_ios
//
//  Created by QMP on 2018/5/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "NoteEditController.h"
#import "HMTextView.h"
#import "SearchCompanyModel.h"
#import "BindCompanyView.h"

@interface NoteEditController () <UITextViewDelegate>
{
    HMTextView *_textView;
    UILabel *_bindLabel;
    BOOL firstEnter;
    BindCompanyView *_bindView;
    UIView *_selectionView;  //内容种类
}
@property(nonatomic,strong)NSMutableArray *selectedCompArr;
@property(nonatomic,strong)NSMutableArray *totalCompanyArr;
@property(nonatomic,strong)NSMutableArray *threeBtnArr;

@end

@implementation NoteEditController

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];    
    [self.view endEditing:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (firstEnter) {
        
        [_textView becomeFirstResponder];
        firstEnter = NO;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TABLEVIEW_COLOR;
    
    if (self.searchComM) {
        [self.selectedCompArr addObject:self.searchComM.product];
        [self.totalCompanyArr addObject:self.searchComM];
    }
    [self addView];
    
    firstEnter = YES;
    [self buildBarButton];
    
}
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 2000) {
        UIViewController *vc = [[UIApplication sharedApplication].windows lastObject].rootViewController;
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"字数限制为最多2000字，请调整后再发送。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:action];
        [vc presentViewController:alertVC animated:YES completion:nil];
        
        textView.text = [textView.text substringToIndex:2000];
    }
}
#pragma mark --UI--
- (void)addView{
    
    CGFloat height = SCREENW > 375 ? 220 : 190;
    UIView *textBgV = [[UIView alloc]initWithFrame:CGRectMake(0,0, SCREENW, height)];
    textBgV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textBgV];
    
    _textView = [[HMTextView alloc]initWithFrame:CGRectMake(13, 10, SCREENW-26, height-10)];
    _textView.placehoderColor = HTColorFromRGB(0xa9a9a9);
    _textView.placehoder = @"在此输入内容";
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.delegate = self;
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 6;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    _textView.typingAttributes = attributes;
    
    [textBgV addSubview:_textView];
    
    _bindView = [[BindCompanyView alloc]initWithFrame:CGRectMake(0, textBgV.bottom + 10, SCREENW, 60)];
    _bindView.backgroundColor = [UIColor whiteColor];
    _bindView.selectedCompArr = self.selectedCompArr;
    _bindView.totalCompanyArr = self.totalCompanyArr;
    _bindView.companyCount =  1;
    [self.view addSubview:_bindView];
    [_bindView reloadCollectionData];
    _bindView.hidden = NO;

    if (self.searchComM) { 
        _bindView.userInteractionEnabled = NO;
        _bindView.notShowDelBtn = YES;
        
    }
}

- (void)publishSelecWayBtnClick:(UIButton*)wayBtn{
    if (wayBtn.selected) {
        return;
    }
    for (UIButton *btn in self.threeBtnArr) {
        if (btn.selected) {
            btn.selected = NO;
        }
    }
    wayBtn.selected = YES;
}

- (void)buildBarButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(17, kScreenTopHeight - 33, 80, 20)];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:H5COLOR forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [leftButton addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn = [[UIButton alloc]init];
    UIBarButtonItem *zhanweiBtnItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItems = @[item,zhanweiBtnItem];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 17 - 80, kScreenTopHeight - 33, 80.f, 20.f)];
    NSString *title = @"保存";
    [rightBtn setTitle:title forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [rightBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pressSaveBarBtn) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.title = @"添加笔记";
}

#pragma mark --Event---
- (void)cancelBtnClick{
    
    [self.view endEditing:YES];
    
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)pressSaveBarBtn{
    
    if ([PublicTool isNull:_textView.text]) {
        NSString *title = @"内容不能为空";
        [PublicTool showMsg:title];
        return;
    }
    
    [self publishComment];
    
}


- (void)publishComment{

    if (_textView.text.length > 2000 && _textView.text.length != 0) {
        UIViewController *vc = [[UIApplication sharedApplication].windows lastObject].rootViewController;
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"字数限制为最多2000字，请调整后再发送。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:action];
        [vc presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    [PublicTool showHudWithView:KEYWindow];
    
    NSString *text = [_textView.text?:@"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:text forKey:@"comment"];
    [paramDict setValue:@"product" forKey:@"project_type"];

    if (self.selectedCompArr) {
        for (SearchCompanyModel *model in self.totalCompanyArr) {
            if ([self.selectedCompArr containsObject:model.product]) {
                [paramDict setValue:model.productId?:@"" forKey:@"project_id"];
                [paramDict setValue:model.product?:@"" forKey:@"project"];
                break;
            }
        }
    }
    [paramDict setValue:@"2" forKey:@"anonymous"]; //私人笔记

    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"dynamic/createDynamic" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
       
        if (resultData) {
            [PublicTool showMsg:@"发布成功"];
            if (self.publishFinish) {
                self.publishFinish();
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserPostActivitySuccess" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [PublicTool showMsg:@"发布失败"];
        }
    }];
    
}

- (void)publishNote{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:_textView.text forKey:@"notes"];
    
    [AppNetRequest addNewNoteWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if (resultData && [resultData[@"message"] isEqualToString:@"success"]) {
            
            if (self.navigationController.childViewControllers.count > 1) {
                [PublicTool showMsg:@"保存成功"];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                [PublicTool showMsg:@"保存成功,请在我的笔记中查看"];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
        }else{
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}
#pragma mark --懒加载--
- (NSMutableArray *)selectedCompArr{
    if (!_selectedCompArr) {
        _selectedCompArr = [NSMutableArray array];
    }
    return _selectedCompArr;
}

- (NSMutableArray *)totalCompanyArr{
    if (!_totalCompanyArr) {
        _totalCompanyArr = [NSMutableArray array];
    }
    return _totalCompanyArr;
}


@end
