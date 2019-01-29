//
//  AuthenticaHeaderView.m
//  qmp_ios
//
//  Created by QMP on 2018/3/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "AuthenticaHeaderView.h"

@interface AuthenticaHeaderView()
@property (weak, nonatomic) IBOutlet UIImageView *iconHeader;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *comAndZhiweiLab;
@property (weak, nonatomic) IBOutlet UILabel *lingyuLab;

@end

@implementation AuthenticaHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    _iconHeader.layer.masksToBounds = YES;
    _iconHeader.layer.cornerRadius = 30;
    
}

- (void)setPerson:(PersonModel *)person{
    
    _person = person;
    
    [_iconHeader sd_setImageWithURL:[NSURL URLWithString:person.icon] placeholderImage:[UIImage imageNamed:@"heading"]];
    NSString *name = [PublicTool isNull:person.name] ? @"-":person.name;
    
    if (person.ename.length && ![person.name containsString:@"("] && ![person.name containsString:@"（"]) {
        name = [NSString stringWithFormat:@"%@(%@)",person.name,person.ename];
        
    }
    
    if (person.name && [name containsString:@"("]) {
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:name];
        NSRange range = [name rangeOfString:@"("];
        [attText addAttributes:@{NSForegroundColorAttributeName:H5COLOR,NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(range.location, name.length - range.location)];
        _nameLab.attributedText = attText;
        
    }else{
        _nameLab.text = name;
        
    }
    if (person.claim_type.integerValue == 2) { //公司和职位有数据
        _comAndZhiweiLab.text = [NSString stringWithFormat:@"%@ %@",person.company,person.position];
        
    }else{
        ZhiWeiModel *zhiwei;
        if (self.person.work_exp.count) {
            zhiwei = self.person.work_exp[0];
            _comAndZhiweiLab.text = [NSString stringWithFormat:@"%@ | %@",zhiwei.name,zhiwei.zhiwu];

        }else{
            _comAndZhiweiLab.text = @"- | -";

        }
    }
    
    _lingyuLab.text = @"无返回数据";    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
