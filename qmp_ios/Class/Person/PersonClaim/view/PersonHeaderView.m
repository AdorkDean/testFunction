//
//  PersonHeaderView.m
//  qmp_ios
//
//  Created by QMP on 2018/3/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonHeaderView.h"
#import "InsetsLabel.h"

@interface PersonHeaderView()

@property (weak, nonatomic) IBOutlet UIImageView *headerIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet InsetsLabel *roleLab;
@property (weak, nonatomic) IBOutlet UILabel *zhiweiLab;
@property (weak, nonatomic) IBOutlet UILabel *wechatLab;

@property (weak, nonatomic) IBOutlet UILabel *phoneLab;
@property (weak, nonatomic) IBOutlet UILabel *emailLab;

@end


@implementation PersonHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    _roleLab.layer.masksToBounds = YES;
    _roleLab.layer.cornerRadius = 10;
    _roleLab.textColor = BLUE_TITLE_COLOR;
    
    self.headerIcon.layer.masksToBounds = YES;
    self.headerIcon.layer.cornerRadius = 35.0f;
    self.headerIcon.layer.borderWidth = 0.5;
    self.headerIcon.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.phoneLab.textColor = H6COLOR;
    self.contactNoSeeView.hidden = YES;
    
    [self.noseeContactBtn setTitleColor:H9COLOR forState:UIControlStateNormal];
    [self.noseeContactBtn setImage:[UIImage imageNamed:@"cell_arrow"] forState:UIControlStateNormal];
    [self.noseeContactBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:5];
    
    [self.companyBtn addTarget:self action:@selector(companyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.wechatLab addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyWechat:)]];
    [self.phoneLab addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyPhone:)]];
    [self.emailLab addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyEmail:)]];

    self.friendShipBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
    self.friendShipBtn.layer.borderWidth = 0.5;
    self.friendShipBtn.layer.masksToBounds = YES;
    self.friendShipBtn.layer.cornerRadius = 12;
    
    [self.companyBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    self.renzhengIcon.hidden = YES;
}


- (void)setPerson:(PersonModel *)person{
    
    _person = person;
    
    [_headerIcon sd_setImageWithURL:[NSURL URLWithString:person.icon] placeholderImage:[UIImage imageNamed:@"heading"]];
    NSString *name = [PublicTool isNull:person.name] ? @"-":person.name;
    
    if (person.name && [name containsString:@"("]) {
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:name];
        NSRange range = [name rangeOfString:@"("];
        [attText addAttributes:@{NSForegroundColorAttributeName:H5COLOR,NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(range.location, name.length - range.location)];
        _nameLab.attributedText = attText;
        
    }else{
        _nameLab.text = name;
        
    }
    if (person.claim_type.integerValue == 2) { //公司和职位有数据
       
        [self.companyBtn setTitle:person.company forState:UIControlStateNormal];
        _zhiweiLab.text = person.position;
   
    }else{
        if (self.fromUnauthenEdit) {
            
            [self.companyBtn setTitle:[NSString stringWithFormat:@"%@",person.position] forState:UIControlStateNormal];
            _zhiweiLab.text = person.zhiwu;
            self.companyBtn.userInteractionEnabled = NO;
            [self.companyBtn setTitleColor:H9COLOR forState:UIControlStateNormal];
            
        }else{
            ZhiWeiModel *zhiwei;
            if (self.person.work_exp.count) {
                zhiwei = self.person.work_exp[0];
                [self.companyBtn setTitle:[NSString stringWithFormat:@"%@",zhiwei.name] forState:UIControlStateNormal];
                _zhiweiLab.text = zhiwei.zhiwu;
            }else{
                [self.companyBtn setTitle:@"-" forState:UIControlStateNormal];
                _zhiweiLab.text = @"-";
            }
        }
       
    }
    
    
    //角色 cyz => 创业者 ；investor => 投资人；FA => FA ；specialist =>专家 ；media =>媒体 ; other => 其他
    NSMutableString *roleString = [NSMutableString string];
    
    for (NSString *roleStr in person.role) {
        if ([roleStr isEqualToString:@"cyz"]) {
            [roleString appendString:@"创业者 "];
        }else if ([roleStr isEqualToString:@"investor"]) {
            [roleString appendString:@"投资人 "];
        }else if ([roleStr isEqualToString:@"FA"]) {
            [roleString appendString:@"FA "];
        }else if ([roleStr isEqualToString:@"specialist"]) {
            [roleString appendString:@"专家 "];
        }else if ([roleStr isEqualToString:@"media"]) {
            [roleString appendString:@"媒体 "];
        }else if ([roleStr isEqualToString:@"other"]) {

        }else{

        }
    }
    
    if (roleString.length) {
        [roleString deleteCharactersInRange:NSMakeRange(roleString.length-1, 1)];
        _roleLab.text = roleString;

    }else{
        _roleLab.text = @"";
        _roleLab.hidden = YES;
    }

    _wechatLab.text = [PublicTool nilStringReturn:person.wechat];
    _emailLab.text = [PublicTool nilStringReturn:person.email];
    _phoneLab.text = [PublicTool nilStringReturn:person.phone];

    //好友关系
    if ([person.personId isEqualToString:[WechatUserInfo shared].person_id] || person.claim_type.integerValue != 2) {
        self.friendShipBtn.hidden = YES;
        return;
    }
    
    [self.friendShipBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];

    self.friendShipBtn.hidden = YES;
    
}

- (void)copyWechat:(UILongPressGestureRecognizer*)press{
    UILabel *label = (UILabel*)press.view;
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = label.text;
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}
- (void)copyPhone:(UILongPressGestureRecognizer*)press{
    UILabel *label = (UILabel*)press.view;
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = label.text;
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}
- (void)copyEmail:(UILongPressGestureRecognizer*)press{
    UILabel *label = (UILabel*)press.view;
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = label.text;
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}

- (void)companyBtnClick{
    
    if (self.person.claim_type.integerValue == 2) { //公司和职位有数据
        
        [self toDetailVC:self.person.detail];
        
    }else{
        
        if (self.person.work_exp.count == 0) {
            return;
        }
        ZhiWeiModel *zhiwei = self.person.work_exp[0];

        [self toDetailVC:zhiwei.detail];
    }
    
}

- (void)toDetailVC:(NSString*)detail{
    
    if ([PublicTool isNull:detail]) {
        return;
    }
    [[AppPageSkipTool shared] appPageSkipToDetail:detail];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
