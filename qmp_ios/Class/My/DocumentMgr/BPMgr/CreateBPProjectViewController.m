//
//  CreateBPProjectViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/5/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CreateBPProjectViewController.h"
#import "EditCell.h"
#import "TextViewTableViewCell.h"
#import "MyInfoTableViewCell.h"
#import "HMTextView.h"
#import "OnePickerView.h"
@interface CreateBPProjectViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) NSArray *tableConfigs;
@property (nonatomic, strong) NSMutableDictionary *cellParamDict;
@property (nonatomic, strong) NSArray *lingyu;

@end

@implementation CreateBPProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"创建关联项目";
    
    [self initTableView];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/showuserhangye" HTTPBody:@{} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        if (resultData) {
            //所有的领域 筛选出未选择的
            NSMutableArray *totalArr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"data"]) {
                [totalArr addObject:dic[@"name"]];
            }
            self.lingyu = totalArr;
        }
    }];
}

- (void)initTableView {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"MyInfoTableViewCellID"];
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:@"EditCellID"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    [self.tableView registerClass:[TextViewTableViewCell class] forCellReuseIdentifier:@"TextViewTableViewCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 120)];
//    [view addSubview:self.submitButton];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(17, 8, 300, 40);
    label1.font = [UIFont systemFontOfSize:12];
    label1.textColor = H9COLOR;
    label1.numberOfLines = 0;
//    label1.text = @"*创建项目可以被所有用户查看\n*企名片会完善创建的项目数据";
    NSAttributedString *str = [self attributedStringWithString:@"*创建项目可以被所有用户查看\n*企名片会完善创建的项目数据"
                                                          font:label1.font
                                                   lineSpacing:6
                                                         color:label1.textColor];
    label1.attributedText = str;
    
    [view addSubview:label1];
    
    self.tableView.tableFooterView = view;
    
    self.tableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.submitButton];
    self.submitButton.top = SCREENH - 50 - 40 - kScreenTopHeight;
}
#pragma mark - Event
- (void)submitButtonClick {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.cellParamDict];
    
    if ([PublicTool isNull:param[@"product"]]) {
        [PublicTool showMsg:@"请填写项目名称"];
        return;
    }
    if ([PublicTool isNull:param[@"yewu"]]) {
        [PublicTool showMsg:@"请填写一句话介绍"];
        return;
    }
    if ([PublicTool isNull:param[@"hangye1"]]) {
        [PublicTool showMsg:@"请填写行业领域"];
        return;
    }
    [param setValue:@"8" forKey:@"source"];
    [param setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/addc2" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            
        }else{
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
    
    NSMutableDictionary *param2 = [NSMutableDictionary dictionary];
    [param2 setValue:self.reportModel.reportId forKey:@"id"];
    [param2 setValue:self.reportModel.name forKey:@"bp_name"];
    [param2 setValue:@"edit" forKey:@"type"];
    [param2 setValue:[WechatUserInfo shared].unionid forKey:@"unionid"];
    [param2 setValue:param[@"product"] forKey:@"product"];
    
    [PublicTool showHudWithView:KEYWindow];
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/editReceivedBp" HTTPBody:param2 completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if (resultData) {
            [self.navigationController popViewControllerAnimated:YES];
            if (self.didFinishedbandProject) {
                self.didFinishedbandProject();
            }
            [PublicTool showMsg:@"关联成功"];
        }else{
            [PublicTool showMsg:REQUEST_ERROR_TITLE];
        }
    }];
}
- (void)editCellTextChange:(UITextField *)textField {
    UIView *v = textField.superview;
    EditCell *cell = (EditCell *)(v.superview);
    NSString *key = [self keyWithCellTitle:cell.keyLabel.text];
    [self.cellParamDict setValue:textField.text forKey:key];
}
- (void)textViewDidChange:(HMTextView *)textView {
    NSString *key = textView.cellKey;
    if ([key isEqualToString:@"desc"] && textView.text.length > 500) {
        [PublicTool showMsg:@"500字以内"];
        textView.text = [textView.text substringToIndex:500];
        return;
    }
    if ([key isEqualToString:@"yewu"] && textView.text.length > 30) {
        [PublicTool showMsg:@"30字以内"];
        textView.text = [textView.text substringToIndex:30];
        return;
    }

    [self.cellParamDict setValue:textView.text forKey:textView.cellKey];
}
#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableConfigs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *row = self.tableConfigs[indexPath.row];
    NSString *title = row[@"title"];
    NSString *cell = row[@"cell"];
    NSString *key = row[@"key"];
    
    if ([cell isEqualToString:@"EditCell"]) {
        EditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.valueTf.text = self.cellParamDict[key];
        cell.keyLabel.text = title;
        [cell.valueTf addTarget:self action:@selector(editCellTextChange:) forControlEvents:UIControlEventEditingChanged];
        return cell;
    } else if ([cell isEqualToString:@"MyInfoTableViewCell"]) {
        MyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyInfoTableViewCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.keyLbl.text = title;
        cell.valueLbl.text = self.cellParamDict[key];
        return cell;
    } else {
        TextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewTableViewCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.keyLabel.text = title;
        cell.textView.placehoder = row[@"placeholder"];
        cell.textView.delegate = self;
        cell.textView.layer.borderWidth = 0.0;
        cell.textView.cellKey = key;
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *row = self.tableConfigs[indexPath.row];
    NSString *title = row[@"title"];
    if ([title isEqualToString:@"一句话介绍"]) {
        return kTextViewTableViewCellHeight;
    }
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *row = self.tableConfigs[indexPath.row];
    NSString *title = row[@"title"];
    NSString *key = row[@"key"];
    if ([title isEqualToString:@"一句话介绍"] || [PublicTool isNull:title]) {
        
    } else if ([title isEqualToString:@"行业领域"]) {
        __weak typeof(self) weakSelf = self;
        OnePickerView *pickerV = [[OnePickerView alloc]initDatePackerWithResponse:^(NSString *selectedStr) {
            [weakSelf.cellParamDict setValue:selectedStr forKey:key];
            [weakSelf.tableView reloadData];
        } dataSource:self.lingyu];
        [pickerV show];
    }
}

#pragma mark - Getter
- (UIButton *)submitButton {
    if (!_submitButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((SCREENW-220)/2.0, 66, 220, 40);
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 20;
        button.backgroundColor = BLUE_BG_COLOR;
        [button setTitle:@"提交" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [button addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _submitButton = button;
    }
    return _submitButton;
}
- (NSArray *)tableConfigs {
    if (!_tableConfigs) {
        _tableConfigs = @[
                          @{@"title":@"项目名称",@"placeholder":@"", @"key":@"product", @"other":@"",@"cell":@"EditCell"},
                          @{@"title":@"一句话介绍",@"placeholder":@"例：在线教育平台，30字以内", @"key":@"yewu", @"other":@"",@"cell":@"TextViewTableViewCell"},
                          @{@"title":@"行业领域",@"placeholder":@"", @"key":@"hangye1", @"other":@"",@"cell":@"MyInfoTableViewCell"},
                          ];
    }
    return _tableConfigs;
}
- (NSMutableDictionary *)cellParamDict {
    if (!_cellParamDict) {
        _cellParamDict = [NSMutableDictionary dictionary];
    }
    return _cellParamDict;
}

- (NSString *)keyWithCellTitle:(NSString *)title {
    for (NSDictionary *dict in self.tableConfigs) {
        if ([dict[@"title"] isEqualToString:title]) {
            return dict[@"key"];
        }
    }
    return @"other";
}
- (NSAttributedString *)attributedStringWithString:(NSString *)string font:(UIFont *)font lineSpacing:(CGFloat)space color:(UIColor *)color {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = space;
     NSMutableAttributedString *mAstr = [[NSMutableAttributedString alloc] initWithString:string
                                                                              attributes:@{NSFontAttributeName:font,
                                                                                           NSParagraphStyleAttributeName: style,
                                                                                           NSForegroundColorAttributeName: color,
                                                                                           }];
    [mAstr setAttributes:@{NSFontAttributeName:font,
                           NSParagraphStyleAttributeName: style,NSForegroundColorAttributeName: RED_DARKCOLOR} range:NSMakeRange(0, 1)];
    [mAstr setAttributes:@{NSFontAttributeName:font,
                           NSParagraphStyleAttributeName: style,NSForegroundColorAttributeName: RED_DARKCOLOR} range:NSMakeRange(15, 1)];
    return mAstr;
}
@end
