//
//  ActivityNotifiCell.m
//  qmp_ios
//
//  Created by QMP on 2018/9/3.
//  Copyright © 2018年 Molly. All rights reserved.
//



#import "ActivityNotifiCell.h"
#import "InsetsLabel.h"

@implementation  ActivityNotifiModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues{
    
    [super setValuesForKeysWithDictionary:keyedValues];
    
    NSString *content =  keyedValues[@"activity"][@"content"];
    if ([PublicTool isNull:keyedValues[@"activity"][@"id"]]) {
        content = @"[动态已删除]";
    }else if([PublicTool isNull:content]){
        if (![PublicTool isNull:keyedValues[@"activity"][@"link_title"]]) {
            content = keyedValues[@"activity"][@"link_title"];
        }else if (![PublicTool isNull:keyedValues[@"activity"][@"link_url"]]){
            content = @"分享链接";
        }else{
            content = @"分享图片";
        }
    }
    NSString *comment = @"";
    if ([keyedValues[@"comment"] isKindOfClass:[NSDictionary class]]) {
        comment = [PublicTool isNull:keyedValues[@"comment"][@"comment"]]?@"":keyedValues[@"comment"][@"comment"];
    }else if([keyedValues[@"comment"] isKindOfClass:[NSString class]]){
        comment = [PublicTool isNull:keyedValues[@"comment"]]?@"":keyedValues[@"comment"];
    }
    self.commentAttributeText = [keyedValues[@"comment"] stringWithParagraphlineSpeace:4 textColor:COLOR2D343A textFont:[UIFont systemFontOfSize:15]];
    self.activityAttributeText = [content stringWithParagraphlineSpeace:4 textColor:COLOR737782 textFont:[UIFont systemFontOfSize:15]];
    
    if ([keyedValues[@"send_type"] integerValue] == 12) { //关注
        self.pushType = ActivityPushType_AttentPerson;
        self.totalHeight = 60;
   
    }else{
        
        CGFloat activityHeight = [content getSpaceLabelHeightwithSpeace:4 withFont:[UIFont systemFontOfSize:15] withWidth:SCREENW - 79 - 24];
        activityHeight =  activityHeight > 30 ? 40 : 16;
        self.activityContentHeight = activityHeight + 20;

        if ([keyedValues[@"send_type"] integerValue] == 11) { //评论
            self.pushType = ActivityPushType_Comment;
            
            self.commentContentHeight = [keyedValues[@"comment"] getSpaceLabelHeightwithSpeace:4 withFont:[UIFont systemFontOfSize:15] withWidth:SCREENW - 79];
            self.commentContentHeight = self.commentContentHeight > 30 ? self.commentContentHeight:16;
            self.totalHeight = 42 + self.commentContentHeight + 12 + self.activityContentHeight + 11;
            
        }else if ([keyedValues[@"send_type"] integerValue] == 13 || [keyedValues[@"send_type"] integerValue] == 14) { //投币和点赞
            self.pushType = [keyedValues[@"send_type"] integerValue] == 13 ? ActivityPushType_GiveCoin:ActivityPushType_Like;
            
            if ([PublicTool isNull:keyedValues[@"comment"]]) {
                self.commentContentHeight = 0;
                self.totalHeight = 42 + self.activityContentHeight + 11;
            }else{
                self.commentContentHeight = [keyedValues[@"comment"] getSpaceLabelHeightwithSpeace:4 withFont:[UIFont systemFontOfSize:15] withWidth:SCREENW - 79];
                self.totalHeight = 42 + self.commentContentHeight + 12 + self.activityContentHeight + 11;
            }
            
        }else if ([keyedValues[@"send_type"] integerValue] == 15) { //评论点赞
            self.pushType = ActivityPushType_CommentLike;
            
            self.commentContentHeight = [keyedValues[@"comment"] getSpaceLabelHeightwithSpeace:4 withFont:[UIFont systemFontOfSize:15] withWidth:SCREENW - 79];
            self.commentContentHeight = self.commentContentHeight > 30 ? self.commentContentHeight:16;
            self.totalHeight = 42 + self.commentContentHeight + 12 + self.activityContentHeight + 11;
            
        }
        
    }
}


@end



@interface ActivityNotifiCell()

@property (strong, nonatomic)UIImageView *headerIcon;
@property (strong, nonatomic)UILabel *nameLab;
@property (strong, nonatomic)UILabel *descLab; //描述
@property (strong, nonatomic)UIButton *coinBtn; //金币
@property (strong, nonatomic)UILabel *timeLab;
@property (strong, nonatomic)UILabel *commentLab; //评论内容
@property (strong, nonatomic)UIView  *line;
@property (strong, nonatomic)InsetsLabel *activityContentLab; //动态内容

@end

@implementation ActivityNotifiCell

+ (instancetype)cellWithTableView:(UITableView*)tableView{
    ActivityNotifiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityNotifiCellID"];
    if (!cell) {
        cell = [[ActivityNotifiCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActivityNotifiCellID"];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addViews];
    }
    return self;
}

- (void)addViews{
    
    self.headerIcon = [[UIImageView alloc]initWithFrame:CGRectMake(17, 12, 35, 35)];
    self.headerIcon.layer.cornerRadius = 17;
    self.headerIcon.layer.masksToBounds = YES;
    self.headerIcon.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.headerIcon.layer.borderWidth = 0.5;
    self.headerIcon.userInteractionEnabled = YES;
    [self.headerIcon addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterPersonDetail)]];
    [self.contentView addSubview:self.headerIcon];
    
    self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.headerIcon.right+10, 13, 30, 18)];
    [self.nameLab labelWithFontSize:16 textColor:COLOR2D343A];
    [self.contentView addSubview:self.nameLab];

    self.descLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.right+10, 0, 30, 18)];
    [self.descLab labelWithFontSize:15 textColor:H9COLOR];
    [self.contentView addSubview:self.descLab];
    self.descLab.centerY = self.nameLab.centerY;
    
    self.coinBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.descLab.right+10, 0, 60, 18)];
    [self.coinBtn setImage:[BundleTool imageNamed:@"coinIcon_small"] forState:UIControlStateNormal];
    [self.coinBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    self.coinBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:self.coinBtn];
    self.coinBtn.centerY = self.nameLab.centerY;
    
    self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREENW - 17 - 80, 0, 80, 18)];
    [self.timeLab labelWithFontSize:12 textColor:COLOR737782];
    self.timeLab.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.timeLab];
    self.timeLab.centerY = self.nameLab.centerY;
    
    self.commentLab = [[UILabel alloc]initWithFrame:CGRectMake( self.nameLab.left,self.nameLab.bottom+10, SCREENW-79, 18)];
    [self.commentLab labelWithFontSize:15 textColor:COLOR2D343A];
    self.commentLab.numberOfLines = -1;
    [self.contentView addSubview:self.commentLab];
    
    self.activityContentLab = [[InsetsLabel alloc]initWithFrame:CGRectMake( self.nameLab.left,self.nameLab.bottom+10, SCREENW-79, 18)];
    [self.activityContentLab labelWithFontSize:15 textColor:COLOR2D343A];
    self.activityContentLab.numberOfLines = 2;
    self.activityContentLab.backgroundColor = HTColorFromRGB(0xF5F5F5);
    [self.contentView addSubview:self.activityContentLab];
    self.activityContentLab.edgeInsets = UIEdgeInsetsMake(10, 12, 10, 12);
    
    self.line = [[UIView alloc]initWithFrame:CGRectMake(self.nameLab.left, self.height - 1, SCREENW - 62, 1)];
    self.line.backgroundColor = F5COLOR;
    [self.contentView addSubview:self.line];
    
}

- (void)setActivityNofiModel:(ActivityNotifiModel *)activityNofiModel{
    _activityNofiModel = activityNofiModel;
    if (activityNofiModel.anonymous.integerValue == 1) {
        self.headerIcon.image = [BundleTool imageNamed:@"anonymous"];
    }else{
        [self.headerIcon sd_setImageWithURL:[NSURL URLWithString:activityNofiModel.user_info[@"icon"]] placeholderImage:[BundleTool imageNamed:@"heading"]];
    }
    self.nameLab.text = activityNofiModel.user_info[@"nickname"];
    
    CGFloat nameWidth = [PublicTool widthOfString:self.nameLab.text height:CGFLOAT_MAX fontSize:16];
    NSString *time = [[activityNofiModel.send_time componentsSeparatedByString:@" "] count] > 1 ? [[activityNofiModel.send_time componentsSeparatedByString:@" "] firstObject] : activityNofiModel.send_time;
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    CGFloat timeWidth = [PublicTool widthOfString:time height:CGFLOAT_MAX fontSize:12];
    
    self.timeLab.text = time;
    self.timeLab.frame = CGRectMake(SCREENW - 17 - timeWidth, 0, timeWidth, 18);
    self.nameLab.frame = CGRectMake(self.headerIcon.right+10, 13, nameWidth, 18);
    self.descLab.frame = CGRectMake(self.nameLab.right+5, 13, 130, 18);

    if (activityNofiModel.pushType == ActivityPushType_AttentPerson) { //关注
        self.descLab.text = @"关注了你";
        self.coinBtn.hidden = YES;
        self.commentLab.hidden = YES;
        self.activityContentLab.hidden = YES;
        self.nameLab.centerY = self.headerIcon.centerY;
        self.descLab.frame = CGRectMake(self.nameLab.right+5, 13, 70, 18);

    }else{
        self.commentLab.hidden = NO;
        if(activityNofiModel.pushType == ActivityPushType_Comment){ //评论动态
            self.descLab.text = @"评论了你的动态";
            self.coinBtn.hidden = YES;
            self.commentLab.attributedText = activityNofiModel.commentAttributeText;
            self.activityContentLab.attributedText = activityNofiModel.activityAttributeText;
            
            self.descLab.frame = CGRectMake(self.nameLab.right+5, 13, 120, 18);
        }else if(activityNofiModel.pushType == ActivityPushType_CommentLike){ //评论点赞
            self.descLab.text = @"赞了你的评论";
            self.coinBtn.hidden = YES;
            self.commentLab.attributedText = activityNofiModel.commentAttributeText;
            self.activityContentLab.attributedText = activityNofiModel.activityAttributeText;

        }else if(activityNofiModel.pushType == ActivityPushType_Like){
            self.descLab.text = @"赞了你的动态";
            self.coinBtn.hidden = YES;
            self.commentLab.attributedText = activityNofiModel.commentAttributeText;
            self.activityContentLab.attributedText = activityNofiModel.activityAttributeText;
            self.descLab.frame = CGRectMake(self.nameLab.right+5, 13, 120, 18);
        }
        
        if ([PublicTool isNull:activityNofiModel.comment]) {
            self.commentLab.hidden = YES;
            self.activityContentLab.frame = CGRectMake(self.nameLab.left, self.nameLab.bottom+11, SCREENW - 79, activityNofiModel.activityContentHeight);
        }else{
            self.commentLab.frame = CGRectMake(self.nameLab.left, self.nameLab.bottom+10, SCREENW - 79, activityNofiModel.commentContentHeight);
            self.activityContentLab.frame = CGRectMake(self.nameLab.left, self.commentLab.bottom+11, SCREENW - 79, activityNofiModel.activityContentHeight);            
        }
        
        self.activityContentLab.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    self.coinBtn.centerY = self.nameLab.centerY;
    self.descLab.centerY = self.nameLab.centerY;
    self.timeLab.centerY = self.nameLab.centerY;
    self.line.top = activityNofiModel.totalHeight-1;
}

- (void)enterPersonDetail{
    if (self.activityNofiModel.anonymous.integerValue == 1) {
        return;
    }
    PersonModel *person = [[PersonModel alloc]init];
    person.personId = self.activityNofiModel.user_info[@"person_id"];
    person.unionid = self.activityNofiModel.user_info[@"unionid"];
    [PublicTool goPersonDetail:person];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
