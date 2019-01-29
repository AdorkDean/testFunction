//
//  CompanysDetailRegisterInfoCell.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/12.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanysDetailRegisterInfoCell.h"
#import "copyLabel.h"
#import "FactoryUI.h"

#define bgColor  RGB(210,209,215,1)
#define TintColor  RGBa(50, 49, 55, 1)

@interface CompanysDetailRegisterInfoCell ()
//@property (nonatomic,strong) UIView *lineV4;
@end

@implementation CompanysDetailRegisterInfoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI{
    
    //法人代表
    _lab = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREENW-30, 44)];
    _lab.font = [UIFont systemFontOfSize:14];
    _lab.numberOfLines = 1;
    [_lab setTextColor:TintColor];
    _lab.lineBreakMode = NSLineBreakByTruncatingTail;//保留整个单词，后边是...
    [self.contentView addSubview:_lab];
//    _lineV4 = [[UIView alloc]initWithFrame:CGRectMake(10, _lab.frame.origin.y+_lab.frame.size.height-0.5f, SCREENW-20, 0.5f)];
//    _lineV4.backgroundColor = bgColor;
//    [self.contentView addSubview:_lineV4];
    
    CGFloat searchW = 26.f;
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 10.f - searchW, 10.f, searchW, searchW)];
    [searchBtn setBackgroundImage:[BundleTool imageNamed:@"search-yellow"] forState:UIControlStateNormal];
    [self.contentView addSubview:searchBtn];
    self.searchBtn = searchBtn;
}

-(void)refreshUI:(NSString *)value andKey:(NSString *)key
{
    
    if (value) {
        _lab.text = [NSString stringWithFormat:@"%@：%@",key,value];
        _lab.userInteractionEnabled = YES;
        
        NSArray *huanhangArr = @[@"注册地点",@"公司名称",@"法人代表"];
        if ([huanhangArr containsObject:key]) {
            _lab.numberOfLines = 0;
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineBreakMode:NSLineBreakByCharWrapping];
            NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style};
            CGFloat w = SCREENW-20;
            
            CGSize size = [_lab.text boundingRectWithSize:CGSizeMake(w, 30*2) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            if (ceil(size.height)<30) {
                [_lab setFrame:CGRectMake(15, 0, w, 44)];
            }else{
                [_lab setFrame:CGRectMake(15, 0, w, 60)];
            }

        }else{
            _lab.numberOfLines = 1;
        }
    }
}


@end
