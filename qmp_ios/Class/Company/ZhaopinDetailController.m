//
//  ZhaopinDetailController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ZhaopinDetailController.h"
#import "ZhaopinHeaderView.h"

@interface ZhaopinDetailController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ZhaopinDetailController
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"招聘详情";
    [self setUI];

}

- (void)setUI{

    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"ZhaopinHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"ZhaopinHeaderViewID"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = nil;
}


#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 95.0f;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.1;

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ZhaopinHeaderView *headerV = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ZhaopinHeaderViewID"];
    headerV.zhaopinM = self.zhaopinM;
    return headerV;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    ZhaopinHeaderView *headerV = (ZhaopinHeaderView*)view;
    headerV.contentView.backgroundColor = [UIColor whiteColor];
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   NSAttributedString *attText = [self.zhaopinM.desc stringWithParagraphlineSpeace:8 textColor:H5COLOR textFont:[UIFont systemFontOfSize:15]];
    return [attText boundingRectWithSize:CGSizeMake(SCREENW-34, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height + 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    UILabel *contentLab = [cell.contentView viewWithTag:1000];
    if (!contentLab) {
        contentLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 20, SCREENW - 34, cell.contentView.height - 40)];
        [contentLab labelWithFontSize:15 textColor:H5COLOR];
        contentLab.numberOfLines = 0;
        [cell.contentView addSubview:contentLab];
        contentLab.tag = 1000;
    }
    NSAttributedString *attText = [self.zhaopinM.desc stringWithParagraphlineSpeace:8 textColor:H5COLOR textFont:[UIFont systemFontOfSize:15]];

    contentLab.attributedText = attText;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   

}



@end
