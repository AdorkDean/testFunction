//
//  FinanPersonInfoVC.m
//  qmp_ios
//
//  Created by QMP on 2018/5/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FinanPersonInfoVC.h"
#import "EditCell.h"
#import "CompanyDetailModel.h"
#import "TakeImageTool.h"
#import <TZImagePickerController.h>
#import "PickPhotosView.h"
#import "FormEditTableViewCell.h"
#import <UIButton+WebCache.h>

@interface FinanPersonInfoVC () <UITableViewDelegate, UITableViewDataSource,
TZImagePickerControllerDelegate, PickPhotosViewDelegate, FormEditTableViewCellDelegate, UITextViewDelegate> {
    TakeImageTool *_imageTool;
}
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSMutableDictionary *cellDict;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) NSMutableArray *photoUrls;

@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) UIView *successView;

@end

@implementation FinanPersonInfoVC

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //保存填写的信息
    [USER_DEFAULTS setValue:self.cellDict forKey:@"PersonInfo"];
    [USER_DEFAULTS synchronize];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _imageTool = [[TakeImageTool alloc] init];
    self.title = @"填写个人信息";
    QMPLog(@"------%@",[USER_DEFAULTS valueForKey:@"PersonInfo"]);
    if ([USER_DEFAULTS valueForKey:@"PersonInfo"]) {
        self.cellDict = [NSMutableDictionary dictionaryWithDictionary:[USER_DEFAULTS valueForKey:@"PersonInfo"]];
    }else{
        [self.cellDict setValue:[WechatUserInfo shared].nickname?:@"" forKey:@"name"];
        [self.cellDict setValue:[WechatUserInfo shared].phone?:@"" forKey:@"wechat"];
    }
   
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:@"EditCellID"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    [self.tableView registerClass:[FormEditTableViewCell class] forCellReuseIdentifier:@"FormEditTableViewCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.tableView.tableFooterView = self.footerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.leftBarButtonItems = [self createBackButton];
}

- (NSArray*)createBackButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:LEFTBUTTONFRAME];
    [leftButton setImage:[BundleTool imageNamed:@"left-arrow"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;
    
    if (iOS11_OR_HIGHER) {
        
        leftButton.width = 30;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        return @[leftButtonItem];
    }
    return @[negativeSpacer,leftButtonItem];
}

- (void)popSelf{
    
    if (self.successView.superview) {
        [self gohomeVC];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)zhizhaoCellClick:(UIButton *)button {
    
    __weak typeof(button) weakButton = button;
    [_imageTool alertPhotoAction:^(UIImage *image, NSData *imgData) {
        [weakButton setTitle:@"" forState:UIControlStateNormal];
        [weakButton setBackgroundImage:image forState:UIControlStateNormal];
        [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            if ([fileUrl containsString:@"http"]) {
                [self.cellDict setValue:fileUrl forKey:@"card"];
            }
        }];
    }];
}

- (void)editCellTextChange:(UITextField *)textfield {
    UIView *v = textfield.superview;
    UIView *view = v.superview;
    if ([view isKindOfClass:[EditCell class]]) {
        EditCell *cell = (EditCell *)(v.superview);
        NSString *key = [self keyWithLeftText:cell.keyLabel.text];
        [self.cellDict setValue:textfield.text forKey:key];
    } else {
        FormEditTableViewCell *cell = (FormEditTableViewCell *)(v.superview);
        NSString *key = [self keyWithLeftText:cell.keyLabel.text];
        
        if ([key isEqualToString:@"position"] || [key isEqualToString:@"claim_reason"]) {
            if (textfield.text.length > 50) {
                [PublicTool showMsg:@"最多50字"];
                textfield.text = [textfield.text substringToIndex:50];
            }
        }
        //        for (UIButton *button in self.) {
        //            <#statements#>
        //        }
        //
        
        [self.cellDict setValue:textfield.text forKey:key];
    }
    
}
#pragma mark - PickPhotosViewDelegate
- (void)pickPhotosView:(PickPhotosView *)view photoViewClick:(NSInteger)index {
    [self zhizhaoCellClick:nil];
}
- (void)pickPhotosView:(PickPhotosView *)view deleteButtonClick:(NSInteger)index {
    //    - (void)zhizhaoCellClick:(UIButton *)button
    if (index >= self.photos.count) return;
    [self.photos removeObjectAtIndex:index];
    [self.assets removeObjectAtIndex:index];
    [self.tableView reloadData];
    
    [self.photoUrls removeAllObjects];
    NSMutableArray *urls = [NSMutableArray array];
    if (self.photos.count > 0) {
        [PublicTool showHudWithView:KEYWindow];
    }
    
    __block int i = 0;
    for (UIImage *image in self.photos) {
        [[NetworkManager sharedMgr] uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            if ([fileUrl containsString:@"http"]) {
                [urls addObject:fileUrl];
                if (i == self.photos.count-1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PublicTool dismissHud:KEYWindow];
                        self.photoUrls = urls;
                    });
                }
                
                i++;
            }
        }];
    }
}
#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    self.photos = [NSMutableArray arrayWithArray:photos];
    self.assets = [NSMutableArray arrayWithArray:assets];
    
    
    NSMutableArray *urls = [NSMutableArray array];
    if (self.photos.count > 0) {
        [PublicTool showHudWithView:KEYWindow];
    }
    
    __block int i = 0;
    for (UIImage *image in self.photos) {
        [[NetworkManager sharedMgr] uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
            if ([fileUrl containsString:@"http"]) {
                [urls addObject:fileUrl];
                if (i == self.photos.count-1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PublicTool dismissHud:KEYWindow];
                        self.photoUrls = urls;
                    });
                }
                
                i++;
            }
        }];
    }

    [self.tableView reloadData];
    
}

- (void)submitButtonClick {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.cellDict];
    
    if (((NSString *)dict[@"name"]).length <= 0) {
        [PublicTool showMsg:@"请填写姓名"];
        return;
    }
    if (((NSString *)dict[@"position"]).length <= 0) {
        [PublicTool showMsg:@"请填写职位"];
        return;
    }
    if (((NSString *)dict[@"wechat"]).length <= 0 ) {
        [PublicTool showMsg:@"请填写手机号"];
        return;
    }
    if ([PublicTool isNull:dict[@"card"]]) {
        [PublicTool showMsg:@"请上传名片或执照"];
        return;
    }
    if (![PublicTool checkTel:dict[@"wechat"]]) {
        return;
    }
    
    NSString *reason = dict[@"claim_reason"]?:@"";
    [dict setValue:[reason stringByAppendingString:self.reason?:@""] forKey:@"claim_reason"];
    

    [dict setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    
    [PublicTool showHudWithView:KEYWindow];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithDictionary:self.param];
    for (NSString *key in dict.allKeys) {
        [paramDic setValue:dict[key]?:@"" forKey:key];
    }
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/financeNeedsRelease" HTTPBody:paramDic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData) {
            [PublicTool showMsg:@"发布成功"];
            [self.view addSubview:self.successView];
        } else {
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.needClaim) {
        return 5;
    }
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 66;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, SCREENW, 66);
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 10, SCREENW-30, 36);
    label.numberOfLines = 0;
    label.textColor = HTColorFromRGB(0x333333);
    label.font = [UIFont boldSystemFontOfSize:12];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:@"*为保证投资人能够快速联系上您，工作人员需核实您的联系方式，请认真填写以下信息"];
    [text addAttributes:@{NSForegroundColorAttributeName:RED_TEXTCOLOR} range:NSMakeRange(0, 1)];
    label.attributedText = text;
    [view addSubview:label];
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [[self tableConfig] objectAtIndex:indexPath.row];
    
    NSString *key = dict[@"key"];
    if ([key isEqualToString:@"card"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLab = [cell.contentView viewWithTag:900];
        if (!titleLab) {
            titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 120, 40)];
            titleLab.font = [UIFont systemFontOfSize:14];
            titleLab.numberOfLines = 1;
            titleLab.textColor = NV_TITLE_COLOR;
            titleLab.text = dict[@"leftStr"];;
            [cell.contentView addSubview:titleLab];
            titleLab.tag = 900;
        }
        
        UILabel *desLab = [cell.contentView viewWithTag:999];
        if (!desLab) {
            NSString *text = @"上传名片或执照，可认领项目\n进行管理和发布融资需求";
            desLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 40, SCREENW-34-120 - 20, 45)];
            desLab.font = [UIFont systemFontOfSize:14];
            desLab.numberOfLines = 2;
            desLab.attributedText = [text stringWithParagraphlineSpeace:4 textColor:H9COLOR textFont:[UIFont systemFontOfSize:14]];
            desLab.textColor = H9COLOR;
            [cell.contentView addSubview:desLab];
            desLab.tag = 999;
        }
        
        UIButton *label = [cell.contentView viewWithTag:1000];
        if (!label) {
            label = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW-120-17, 10, 120, 80)];
            label.titleLabel.font = [UIFont systemFontOfSize:12];
            label.titleLabel.numberOfLines = 2;
            label.titleLabel.textAlignment = NSTextAlignmentCenter;
            [label setTitle:@"仅支持jpg、png\n小于5M" forState:UIControlStateNormal];
            [label setTitleColor:HCCOLOR forState:UIControlStateNormal];
            
            [label addTarget:self action:@selector(zhizhaoCellClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:label];
            label.tag = 1000;
            label.layer.borderWidth = 0.5;
            label.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        }
        UIView *line = [cell.contentView viewWithTag:1001];
        if (!line) {
            line = [[UIView alloc]initWithFrame:CGRectMake(17, 99, SCREENW, 1)];
            line.backgroundColor = LIST_LINE_COLOR;
            line.tag = 1001;
            [cell.contentView addSubview:line];
        }
        if (![PublicTool isNull: self.cellDict[@"card"]]) {
            [label setTitle:@"" forState:UIControlStateNormal];
            [label sd_setBackgroundImageWithURL:[NSURL URLWithString:self.cellDict[@"card"]] forState:UIControlStateNormal];
        }else{
            [label setTitle:@"仅支持jpg、png\n小于5M" forState:UIControlStateNormal];
        }
        return cell;
        
    } else if ([key isEqualToString:@"position"]) {
        FormEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FormEditTableViewCellID"];
        cell.isMultiSelection = NO;
        cell.keyLabel.text = dict[@"leftStr"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.valueTf.text = self.cellDict[dict[@"key"]];
        [cell.valueTf addTarget:self action:@selector(editCellTextChange:) forControlEvents:UIControlEventEditingChanged];
        
        int i = 0;
        for (NSString *title in @[@"创始人",@"联合创始人",@"融资顾问",@"市场商务"]) {
            UIButton *button = cell.selectsView.subviews[i];
            [button setTitle:title forState:UIControlStateNormal];
            i++;
        }
        cell.valueTf.userInteractionEnabled = NO;
        cell.delegate = self;
        return cell;
    } else if ([key isEqualToString:@"claim_reason"]) {
        FormEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FormEditTableViewCellID"];
        cell.isMultiSelection = YES;
        cell.keyLabel.text = dict[@"leftStr"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.valueTf.text = self.cellDict[dict[@"key"]];
        [cell.valueTf addTarget:self action:@selector(editCellTextChange:) forControlEvents:UIControlEventEditingChanged];
        
        int i = 0;
        for (NSString *title in @[@"发布融资",@"管理项目",@"市场推广",@"品牌运营"]) {
            UIButton *button = cell.selectsView.subviews[i];
            [button setTitle:title forState:UIControlStateNormal];
            i++;
        }
        cell.textView.placehoder = @"更多理由";
        cell.textView.delegate = self;
        cell.valueTf.userInteractionEnabled = NO;
        cell.delegate = self;
        cell.line.hidden = YES;
        return cell;
    } else {
        EditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditCellID"];
        cell.keyLabel.text = dict[@"leftStr"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.valueTf.text = self.cellDict[dict[@"key"]];
        [cell.valueTf addTarget:self action:@selector(editCellTextChange:) forControlEvents:UIControlEventEditingChanged];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[EditCell class]]) {
            EditCell *eCell = (EditCell *)cell;
            [eCell.valueTf becomeFirstResponder];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return 100;
    }
    
    NSDictionary *dict = [[self tableConfig] objectAtIndex:indexPath.row];
    
    NSString *key = dict[@"key"];
    
    if ([key isEqualToString:@"position"]) {
        return 80;
    } else if ([key isEqualToString:@"claim_reason"]) {
        return 160;
    }
    
    return 50;
}
#pragma mark - FormEditTableViewCellDelegate
- (void)formEditTableViewCell:(FormEditTableViewCell *)cell buttonClick:(UIButton *)button {
    [self editCellTextChange:cell.valueTf];
}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 50) {
        [PublicTool showMsg:@"最多50字"];
        textView.text = [textView.text substringToIndex:50];
    }
    self.reason = textView.text;
}

#pragma mark - Getter
- (NSArray *)tableConfig {
    return @[
             @{@"leftStr":@"姓名", @"rightStr":@"", @"key":@"name"},
             @{@"leftStr":@"手机号", @"rightStr":@"", @"key":@"wechat"},
             @{@"leftStr":@"职位", @"rightStr":@"", @"key":@"position"},
             @{@"leftStr":@"名片或执照", @"rightStr":@"", @"key":@"card"},
             @{@"leftStr":@"认领理由", @"rightStr":@"", @"key":@"claim_reason"}
             ];
}
- (NSMutableDictionary *)cellDict {
    if (!_cellDict) {
        _cellDict = [NSMutableDictionary dictionary];
    }
    return _cellDict;
}
- (NSString *)keyWithLeftText:(NSString *)str {
    for (NSDictionary *dict in [self tableConfig]) {
        if ([dict[@"leftStr"] isEqualToString:str]) {
            return dict[@"key"];
        }
    }
    return @"";
}
- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.frame = CGRectMake(0, 0, SCREENW, 90);
        
        UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        submitButton.frame = CGRectMake((SCREENW-220)/2.0, 35, 220, 40);
        submitButton.layer.masksToBounds = YES;
        submitButton.layer.cornerRadius = 20;
        submitButton.backgroundColor = BLUE_BG_COLOR;
        [submitButton setTitle:@"提交" forState:UIControlStateNormal];
        [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        submitButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:submitButton];
    }
    return _footerView;
}
- (NSMutableArray *)photoUrls {
    if (!_photoUrls) {
        _photoUrls = [NSMutableArray array];
    }
    return _photoUrls;
}

- (UIView *)successView {
    if (!_successView) {
        _successView = [[UIView alloc] initWithFrame:self.view.bounds];
        _successView.backgroundColor = TABLEVIEW_COLOR;
        
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = HTColorFromRGB(0x666666);
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"融资需求发布成功\n请耐心等待审核";
        
        label.frame = CGRectMake(0, 200, SCREENW, 42);
        [_successView addSubview:label];
        
        UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, SCREENH-40-40-kScreenTopHeight, 220, 40)];
        submitBtn.layer.masksToBounds = YES;
        submitBtn.layer.cornerRadius = 20;
        submitBtn.backgroundColor = BLUE_BG_COLOR;
        [submitBtn setTitle:@"返回" forState:UIControlStateNormal];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        submitBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [submitBtn addTarget:self action:@selector(gohomeVC) forControlEvents:UIControlEventTouchUpInside];
        [_successView addSubview:submitBtn];
        submitBtn.centerX = SCREENW/2.0;
    }
    return _successView;
}


- (void)gohomeVC {
    
    [self.successView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];}

@end
