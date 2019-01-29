//
//  IpoInfoCell.m
//  qmp_ios
//
//  Created by QMP on 2018/1/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "IpoInfoCell.h"
#import "CompanyReportListViewController.h"
#import "NewsWebViewController.h"
#import "FileWebViewController.h"

@interface IpoInfoCell()

@end


@implementation IpoInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)setArr:(NSArray *)arr{
    _arr = arr;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat top = 20;
    CGFloat verEdge = 25;
    CGFloat height = 14;
    
    for (int i=0;i<arr.count;i++) {
        NSDictionary *dic = arr[i];
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(17, top + i*(height+verEdge), 150, height)];
        [nameLabel labelWithFontSize:13 textColor:H5COLOR];
        if ([PublicTool isNull:dic[@"ipo_code"]]) {
            nameLabel.text = dic[@"ipo_type"];
        }else{
            nameLabel.text = [NSString stringWithFormat:@"%@:%@",dic[@"ipo_type"],dic[@"ipo_code"]];
        }
        [self.contentView addSubview:nameLabel];
        CGFloat caiwuBtnLeft = SCREENW - 17 - 60;
        if (![PublicTool isNull:dic[@"ipo_pdf"]]) {
            UIButton *pdfBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - 17 - 55, 0, 55, 45)];
            pdfBtn.tag = 999 + i;
            pdfBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [pdfBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            [pdfBtn setTitle:@"招股书" forState:UIControlStateNormal];
            [pdfBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [self.contentView addSubview:pdfBtn];
            pdfBtn.centerY = nameLabel.centerY;
            [pdfBtn addTarget:self action:@selector(pdfBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            caiwuBtnLeft = pdfBtn.left - 10 - 55;
        }
        
        UIButton *caiwuBtn = [[UIButton alloc]initWithFrame:CGRectMake(caiwuBtnLeft, 0, 60, 45)];
        caiwuBtn.tag = 1000 + i;
        caiwuBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [caiwuBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [caiwuBtn setTitle:@"财务数据" forState:UIControlStateNormal];
        [caiwuBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.contentView addSubview:caiwuBtn];
        caiwuBtn.centerY = nameLabel.centerY;
        [caiwuBtn addTarget:self action:@selector(caiwuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if ([PublicTool isNull:dic[@"ipo_code"]]) {
            [caiwuBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
            [caiwuBtn setTitle:@"-" forState:UIControlStateNormal];

        }
        
        UIButton *reportBtn = [[UIButton alloc]initWithFrame:CGRectMake(caiwuBtn.left - 10 - 60, 0, 60, 45)];
        reportBtn.tag = 2000 + i;
        reportBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [reportBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [reportBtn setTitle:@"公司公告" forState:UIControlStateNormal];
        [self.contentView addSubview:reportBtn];
        reportBtn.centerY = nameLabel.centerY;
        [caiwuBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];

        [reportBtn addTarget:self action:@selector(reportBtnClick:) forControlEvents:UIControlEventTouchUpInside];
       
        NSArray *usaArr = @[@"美股",@"美交所",@"纽交所",@"纳斯达克"]; //美股没公告，可能有招股书

        if ([usaArr containsObject:dic[@"ipo_type"]]) {
            [reportBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
            [reportBtn setTitle:@"-" forState:UIControlStateNormal];
            reportBtn.userInteractionEnabled = NO;
        }
    }
}


- (void)caiwuBtnClick:(UIButton*)caiwuBtn{
    NSInteger index = caiwuBtn.tag - 1000;
    NSDictionary *dic = _arr[index];
    if (![PublicTool isNull:dic[@"ipo_link"]]) {
        URLModel *urlModel = [[URLModel alloc]init];
        urlModel.url = dic[@"ipo_link"];
        NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
        [[PublicTool topViewController].navigationController pushViewController:webView animated:YES];
    }else{
        [PublicTool viewCaiwuDataWithIpo_type:dic[@"ipo_type"] ipo_code:dic[@"ipo_code"]];
    }
    [QMPEvent event:@"pro_caiwuClick"];
}

- (void)reportBtnClick:(UIButton*)reportBtn{
    
    NSInteger index = reportBtn.tag - 2000;
    NSDictionary *dic = _arr[index];
    
    CompanyReportListViewController *reportVC = [[CompanyReportListViewController alloc] init];
    reportVC.company = self.companyModel.company_basic.company;
    reportVC.requestDict = self.requetDict;
    reportVC.status = dic[@"ipo_type"];
    reportVC.title = [NSString stringWithFormat:@"%@-公司公告",dic[@"ipo_type"]];
    [[PublicTool topViewController].navigationController pushViewController:reportVC animated:YES];
}


- (void)pdfBtnClick:(UIButton*)btn{
    NSInteger index = btn.tag - 999;
    NSDictionary *dic = _arr[index];

    FileItem *report = [[FileItem alloc]init];
    report.fileName = @"招股书";
    report.fileUrl = dic[@"ipo_pdf"];
    report.fileId = dic[@"fileid"];
    report.fileType = dic[@"filetype"];
    FileWebViewController *fileWeb = [[FileWebViewController alloc]init];
    fileWeb.fileItem = report;
    
    [[PublicTool topViewController].navigationController pushViewController:fileWeb animated:YES];
}


- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
