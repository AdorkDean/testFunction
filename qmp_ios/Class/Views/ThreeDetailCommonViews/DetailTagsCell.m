//
//  DetailTagsCell.m
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DetailTagsCell.h"
#import "TagsFrame.h"

@interface DetailTagsCell()

@property(nonatomic,copy)NSString *tagString;
@property(nonatomic,strong)NSArray *tagArr;
@property(nonatomic,assign)BOOL isSpread;


@end


@implementation DetailTagsCell

- (id)initWithTagString:(NSString*)tagsString clickShrinkTag:(void(^)(BOOL isSpread,TagsFrame *tagFrame))didClickShrinkTag clickAddTag:(void(^)(void))didClickAddTag clickTag:(void(^)(NSString *tag))didClickTag{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"]) {
        self.contentView.backgroundColor = RGB(255, 255, 255, 1);//cell背景
        self.contentView.layer.cornerRadius = 3;
        self.contentView.layer.masksToBounds = YES;
        
        self.didClickShrinkTag = didClickShrinkTag;
        self.didClickAddTag = didClickAddTag;
        self.didClickTag = didClickTag;
        self.isSpread = NO;
        self.canNotAddTag = YES;
        self.tagString = tagsString;
        self.isCompany = NO;

        if (didClickTag) {
            self.isCompany = YES;
        }
        [self setupViews];
    }
    return self;
}

+ (id)cellWithTableView:(UITableView *)tableView tagString:(NSString*)tagsString clickShrinkTag:(void(^)(BOOL isSpread,TagsFrame *tagFrame))didClickShrinkTag clickAddTag:(void(^)(void))didClickAddTag clickTag:(void(^)(NSString *tag))didClickTag{
    
    static NSString *identifier = @"tags";
    DetailTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
   
    if (cell == nil) {
        
        cell = [[DetailTagsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.contentView.backgroundColor = RGB(255, 255, 255, 1);//cell背景
        cell.contentView.layer.cornerRadius = 3;
        cell.contentView.layer.masksToBounds = YES;
        
        cell.didClickShrinkTag = didClickShrinkTag;
        cell.didClickAddTag = didClickAddTag;
        cell.didClickTag = didClickTag;
        cell.isSpread = NO;

    }
    
    cell.tagString = tagsString;
    [cell setupViews];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

+ (id)cellWithTableView:(UITableView *)tableView tagString:(NSString*)tagsString isCompany:(BOOL)company clickShrinkTag:(void(^)(BOOL isSpread,TagsFrame *tagFrame))didClickShrinkTag clickAddTag:(void(^)(void))didClickAddTag clickTag:(void(^)(NSString *tag))didClickTag{
    
    static NSString *identifier = @"tags";
    DetailTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[DetailTagsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.contentView.backgroundColor = RGB(255, 255, 255, 1);//cell背景
        cell.contentView.layer.cornerRadius = 3;
        cell.contentView.layer.masksToBounds = YES;
        
        cell.didClickShrinkTag = didClickShrinkTag;
        cell.didClickAddTag = didClickAddTag;
        cell.didClickTag = didClickTag;
        cell.isSpread = NO;
        
    }
    cell.isCompany = company;
    cell.tagString = tagsString;
    [cell setupViews];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)refreshTagsString:(NSString*)tagString{
    _tagString = tagString;
    [self setupViews];
}

-(void)setupViews{
    
    [self dealData:self.isSpread];
    [self addViews];
}

- (void)addViews{
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIColor *layerColor = self.isCompany?BLUE_TITLE_COLOR:COLOR737782;
    UIColor *titleColor = self.isCompany?BLUE_TITLE_COLOR:COLOR2D343A;
    
    for (NSInteger i=0; i<self.tagFrame.tagsArray.count; i++) {
        
        UIButton *tagsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tagsBtn.tag = 400 + i;
        tagsBtn.userInteractionEnabled = YES;//用户交互
        [tagsBtn setTitle:self.tagFrame.tagsArray[i] forState:UIControlStateNormal];
        [tagsBtn setTitleColor:titleColor forState:UIControlStateNormal];
        tagsBtn.titleLabel.font = TagsTitleFont;
        tagsBtn.layer.borderColor = layerColor.CGColor;
        tagsBtn.layer.borderWidth = 0.5f;
        tagsBtn.layer.cornerRadius = 2;
        tagsBtn.layer.masksToBounds = YES;
        
        tagsBtn.frame = CGRectFromString(self.tagFrame.tagsFrames[i]);
        if ([self.tagFrame.tagsArray[i] isEqualToString:@"加画像"]) {
            [tagsBtn setTitle:@"画像" forState:UIControlStateNormal];
            [tagsBtn setImage:[BundleTool imageNamed:@"company_addTag"] forState:UIControlStateNormal];
            [tagsBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:2];
            tagsBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
            [tagsBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        }else if ([self.tagFrame.tagsArray[i] isEqualToString:@"加更多"] || [self.tagFrame.tagsArray[i] isEqualToString:@"加收起"]) {
            if ([self.tagFrame.tagsArray[i] isEqualToString:@"加更多"]) {
                [tagsBtn setImage:[BundleTool imageNamed:@"tag_downIcon"] forState:UIControlStateNormal];
                [tagsBtn setTitle:@"更多" forState:UIControlStateNormal];

            }else{
                [tagsBtn setImage:[BundleTool imageNamed:@"tag_upIcon"] forState:UIControlStateNormal];
                [tagsBtn setTitle:@"收起" forState:UIControlStateNormal];
            }
            [tagsBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:2];
            tagsBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
            [tagsBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        }
        
        [self.contentView addSubview:tagsBtn];
        [tagsBtn addTarget:self action:@selector(tagBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)dealData:(BOOL)showAll{
    
    NSString *tagsStr = _tagString;
    tagsStr = [tagsStr stringByReplacingOccurrencesOfString:@"||" withString:@"|"];

    NSArray *tags = [tagsStr componentsSeparatedByString:@"|"];
    
    if (self.canNotAddTag == NO) {
        
        if (tagsStr.length <= 5) {
            tags = @[@"加画像"];
        }
    }
   
    NSMutableArray *tagsArr = [NSMutableArray array];
    //只显示2行
    TagsFrame *tagframe = [self getHeightFromArr:tags];
    for (int i=0; i<tagframe.tagsArray.count; i++) {
        CGRect frame = CGRectFromString(tagframe.tagsFrames[i]);
        
        if (frame.origin.y >= (12+(12+24)*2)) {
            break;
        }
        [tagsArr addObject:tagframe.tagsArray[i]];
        
    }
    //有查看更多
    if (tagsArr.count < [[tagsStr componentsSeparatedByString:@"|"] count]) {
        
        //查看更多
        if (!showAll) {
            NSString *tagStr = tagsArr.lastObject;
            if (tagStr.length < 3) {
                [tagsArr removeLastObject];
            }
            [tagsArr replaceObjectAtIndex:tagsArr.count-1 withObject:@"加更多"];
        }else{  //收起
            tagsArr = [NSMutableArray arrayWithArray:tags];
            [tagsArr addObject:@"加收起"];
        }
        
    }
    
    self.tagFrame = [self getHeightFromArr:tagsArr];
}

- (void)tagBtnClick:(UIButton*)tagBtn{
    
    NSInteger index = tagBtn.tag - 400;
    NSString *title = tagBtn.titleLabel.text;
    
    if (index == 0 && [title containsString:@"画像"]) {
        
        if (self.didClickAddTag) {
            self.didClickAddTag();
        }

    }else if(index == self.tagFrame.tagsArray.count-1 && ([title containsString:@"更多"] || [title containsString:@"收起"])){ //最后一个
        self.isSpread = [title containsString:@"更多"] ? YES:NO;
        [self setupViews];
        
        if (self.didClickShrinkTag) {
            self.didClickShrinkTag(self.isSpread, self.tagFrame);
        }
        
    }else{
        if (self.didClickTag) {
            self.didClickTag(self.tagFrame.tagsArray[index]);
        }
    }
    
}

- (TagsFrame *)getHeightFromArr:(NSArray *)tagsArr{
    
    TagsFrame *frame = [[TagsFrame alloc] init];
    if (tagsArr.count>0) {
        
        frame.tagsArray = tagsArr;
        
    }
    return frame;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
