//
//  ZhaopinHeaderView.m
//  qmp_ios
//
//  Created by QMP on 2018/4/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ZhaopinHeaderView.h"


@interface ZhaopinHeaderView()
{
    __weak IBOutlet UILabel *_zhiweiLab;
    __weak IBOutlet UILabel *_cityLab;
    
    __weak IBOutlet UILabel *_timeLab;
    __weak IBOutlet UILabel *_salaryLab;
}
@end


@implementation ZhaopinHeaderView

-(void)setZhaopinM:(ZhaopinModel *)zhaopinM{
    _zhiweiLab.text = zhaopinM.title;
    _cityLab.text = [PublicTool nilStringReturn:zhaopinM.city];
    _timeLab.text = [PublicTool nilStringReturn:zhaopinM.experience];
    _salaryLab.text = [PublicTool nilStringReturn:zhaopinM.ori_salary];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
