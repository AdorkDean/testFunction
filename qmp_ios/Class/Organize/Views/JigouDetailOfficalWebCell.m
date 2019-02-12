//
//  JigouIntroduceCell.m
//  qmp_ios
//
//  Created by QMP on 2017/9/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "JigouDetailOfficalWebCell.h"
#import "NewsWebViewController.h"
#import "CompanyInfoView.h"

@interface JigouDetailOfficalWebCell()
@property (weak, nonatomic) IBOutlet UILabel *officeWeb;
@property(nonatomic,strong) OrganizeItem *organizeItem;
@end
@implementation JigouDetailOfficalWebCell

+ (JigouDetailOfficalWebCell *)cellWithTableView:(UITableView *)tableView {
    JigouDetailOfficalWebCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JigouDetailOfficalWebCellID"];
    if (cell == nil) {
        cell = (JigouDetailOfficalWebCell *)[[[NSBundle mainBundle] loadNibNamed:@"JigouDetailOfficalWebCell" owner:self options:nil] lastObject];
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    _officeWeb.textColor = BLUE_TITLE_COLOR;
    _officeWeb.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterWebUrl)];
    [_officeWeb addGestureRecognizer:tap];
    
}

- (CGFloat)setOrganize:(OrganizeItem*)organizeItem{
    _organizeItem = organizeItem;
    
    CGFloat webHeight = 0;
    if (organizeItem.gw_link.length == 0) {
        _officeWeb.text = @"-";
        _officeWeb.userInteractionEnabled = NO;
        webHeight = 18;
    }else{
        _officeWeb.text = organizeItem.gw_link;
        _officeWeb.userInteractionEnabled = YES;
        webHeight = [PublicTool heightOfString:organizeItem.gw_link width:SCREENW - 74 font:_officeWeb.font];

    }
    
    //官网height
    self.height = webHeight + 45;
    return webHeight + 45;
}


- (void)enterWebUrl{
    [self enterToBaidu:self.organizeItem.gw_link];
}

/**
 跳转到百度
 
 @param key
 */
- (void)enterToBaidu:(NSString *)key{
    
    URLModel *urlModel = [[URLModel alloc]init];
    urlModel.url = [NSString stringWithFormat:@"%@",[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
    webView.fromVC = @"baidu";
    [self.vc.navigationController pushViewController:webView animated:YES];
    
}
/**
 长按简介复制
 
 @param longPress
 */
- (void)longPressJianjieLbl:(UILongPressGestureRecognizer *)longPress{
    UILabel *lbl = (UILabel *)longPress.view;
    
    NSString *urlStr = _organizeItem.short_url;
    if ([urlStr hasPrefix:@"http://"]||[urlStr hasPrefix:@"https://"]) {
        
        [PublicTool storeShortUrlToLocal:urlStr];
        
    }
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [NSString stringWithFormat:@"%@ 来自@企名片%@",lbl.text,urlStr];
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}
// 点击显示简介全部
- (void)tapEnterInfoDetail:(UITapGestureRecognizer *)tap{
    CompanyInfoView *companyInfoView = [CompanyInfoView instanceCompanyInfoView:CGRectMake(0, 0, SCREENW, SCREENH) withName:self.organizeItem.name withInfo:self.organizeItem.miaoshu];
    
    companyInfoView.shortUrlStr = self.organizeItem.short_url;


    [KEYWindow addSubview:companyInfoView];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
