//
//  ProductContactDetailVC.m
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductContactDetailVC.h"
#import "CardEditingTableViewCell.h"
#import "SearchDetailViewController.h"

#import "ShareTo.h"
@interface ProductContactDetailVC ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    
}
@property(nonatomic,strong)NSArray *sectionTitle;

@end

@implementation ProductContactDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.friend1) {
        self.card = [[CardItem alloc]init];
        self.card.contacts = self.friend1.nickname;
        self.card.telephone = self.friend1.bind_phone;
        self.card.wechat = self.friend1.wechat;
        self.card.email = self.friend1.email;
        self.card.company = self.friend1.company;
        self.card.zhiwei = self.friend1.position;
        self.card.detail = self.friend1.detail;
    }
    self.title = self.card.contacts?:@"详情";

    [self addView];
    
}

- (void)addView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"CardEditingTableViewCell" bundle:nil] forCellReuseIdentifier:@"CardEditingTableViewCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark - tableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 10)];
    headerV.backgroundColor = TABLEVIEW_COLOR;
    return headerV;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.sectionTitle.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"CardEditingTableViewCellID";
    CardEditingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.infoTextField.tag = indexPath.row + 1000;;
    NSString *sectionTitle = self.sectionTitle[indexPath.row];
    if ([sectionTitle isEqualToString:@"姓名"]) {
        cell.infoLbl.text = @"姓名";
        cell.infoTextField.text = self.card.contacts? self.card.contacts : @"";
        cell.infoTextField.textColor = self.friend1||![PublicTool isNull:self.card.person_id] ? BLUE_TITLE_COLOR : NV_TITLE_COLOR;

    }else  if ([sectionTitle isEqualToString:@"电话"]) {
        cell.infoLbl.text = @"电话";
        cell.infoTextField.text = self.card.telephone? self.card.telephone : @"";
        cell.infoTextField.textColor = BLUE_TITLE_COLOR;

    }else  if ([sectionTitle isEqualToString:@"微信"]) {
        cell.infoLbl.text = @"微信";
        cell.infoTextField.text = self.card.wechat? self.card.wechat : @"";
        cell.infoTextField.textColor = BLUE_TITLE_COLOR;

    }else  if ([sectionTitle isEqualToString:@"邮箱"]) {
        cell.infoLbl.text = @"邮箱";
        cell.infoTextField.text = self.card.email? self.card.email : @"";
        cell.infoTextField.textColor = BLUE_TITLE_COLOR;
    }else  if ([sectionTitle isEqualToString:@"公司"]) {
        cell.infoLbl.text = @"公司";
        cell.infoTextField.text = [PublicTool isNull:self.card.company] ? @"-":self.card.company;
        cell.infoTextField.textColor = BLUE_TITLE_COLOR;

    }else  if ([sectionTitle isEqualToString:@"项目"]) {
        cell.infoLbl.text = @"项目";
        cell.infoTextField.text = [PublicTool isNull:self.card.product] ? @"-":self.card.product;
        cell.infoTextField.textColor = BLUE_TITLE_COLOR;
        
    }else  if ([sectionTitle isEqualToString:@"职位"]) {
        cell.infoLbl.text = @"职位";
        cell.infoTextField.text = self.card.zhiwei ? self.card.zhiwei : @"";
        cell.infoTextField.textColor = NV_TITLE_COLOR;
    }
    
    cell.rightButton.hidden = YES;
    cell.infoTextField.userInteractionEnabled = NO;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *sectionTitle = self.sectionTitle[indexPath.row];
    if ([sectionTitle isEqualToString:@"电话"]) {
        if (![PublicTool isNull:self.card.telephone]) {
            [PublicTool dealPhone:self.card.telephone];
        }
        
    }else if ([sectionTitle isEqualToString:@"微信"]) {
        if (![PublicTool isNull:self.card.wechat]) {
            [PublicTool dealWechat:self.card.wechat];
        }
        
    }else if ([sectionTitle isEqualToString:@"邮箱"]) {
        if (![PublicTool isNull:self.card.email]) {
            [PublicTool dealEmail:self.card.email];
        }
        
    }else if([sectionTitle isEqualToString:@"公司"]||[sectionTitle isEqualToString:@"项目"]||[sectionTitle isEqualToString:@"机构"]){
        [self tapCompanyTextView];
    }else if([sectionTitle isEqualToString:@"姓名"]){
        if (self.friend1) {
            if (![PublicTool isNull:self.friend1.person_id]) {
                [[AppPageSkipTool shared]appPageSkipToPersonDetail:self.friend1.person_id];
            }else if (![PublicTool isNull:self.friend1.unionid]) {
                [[AppPageSkipTool shared]appPageSkipToUserDetail:self.friend1.unionid];
            }
        }else if(![PublicTool isNull:self.card.person_id]){
            [[AppPageSkipTool shared] appPageSkipToPersonDetail:self.card.person_id];
        }
    }

}

- (void)tapCompanyTextView{
    
    NSString *detail = self.card.detail;
    if ([PublicTool isNull:detail] || detail.length<10) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToDetail:detail];
}


#pragma mark - public
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([PublicTool isNull:textField.text]) {
        return NO;
    }
    
    switch (textField.tag - 1000) {
        case 0: { //项目
        }
        case 4: {//
            NSString *company = self.card.detail;
            [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:company]];

        }break;
        case 2:{ //打电话
            [PublicTool makeACall:textField.text];
            break;
        }
        default:
            break;
    }
    
    return NO;
}
#pragma mark - 懒加载
- (NSArray *)sectionTitle{
    if (!_sectionTitle) {
        if (self.friend1) { //通讯录
            if (self.friend1.type.integerValue == 1) {
                _sectionTitle = @[@"姓名",@"公司",@"职位",@"电话",@"邮箱"];
            }else if (self.friend1.type.integerValue == 2) {
                _sectionTitle = @[@"姓名",@"公司",@"职位",@"微信",@"邮箱"];
            }else if (self.friend1.type.integerValue == 3) {
                _sectionTitle = @[@"姓名",@"公司",@"职位",@"电话",@"微信",@"邮箱"];
            }
        }else{
            if([self.card.type containsString:@"product"]){
                _sectionTitle = @[@"项目",@"姓名",@"公司",@"职位",@"电话",@"微信",@"邮箱"];
            }else if([self.card.type containsString:@"agency"]){
                _sectionTitle = @[@"机构",@"姓名",@"职位",@"电话",@"微信",@"邮箱"];
            }else{
                _sectionTitle = @[@"姓名",@"公司",@"职位",@"电话",@"微信",@"邮箱"];
            }
        }
    }
    return _sectionTitle;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
}
//
//-(UIView *)footView{
//
//    if (!_footView) {
//        CGFloat height = SCREENW > 375 ? 250:300;
//        _footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, height)];
//
//    }
//    return _footView;
//}


@end
