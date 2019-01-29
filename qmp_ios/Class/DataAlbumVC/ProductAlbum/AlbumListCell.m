//
//  AlbumListCell.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "AlbumListCell.h"
#import <YYText.h>
@interface AlbumListCell()
{
    UIImageView *_imgView;
    NSMutableArray *_iconVArr;
    UIImageView *_hotFlagV;
    YYLabel *_titleLab;
    UILabel *_namesLab;
}
@end
@implementation AlbumListCell

+ (instancetype)cellWithTableView:(UITableView*)tableView{
    AlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumListCellID"];
    if (!cell) {
        cell = [[AlbumListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AlbumListCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addViews];
    }
    return self;
}

- (void)addViews{
    
    _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(16, 15, 70, 70)];
    _imgView.layer.cornerRadius = 5;
    _imgView.clipsToBounds = YES;
    _imgView.backgroundColor = HTColorFromRGB(0xE3E4E7);
    [self.contentView addSubview:_imgView];
    
    CGFloat width = 20;
    CGFloat edge = 4;//(70 -8 -width*2)/2;
    width = (70 - 8 - 4)/2.0;
    for (int i=0; i<4; i++) {
        int row = i/2;
        int colum = i%2;
        UIImageView *iconV= [[UIImageView alloc]initWithFrame:CGRectMake(4+colum*(width+edge), 4+row*(width+edge), width, width)];
//        iconV.contentMode = UIViewContentModeScaleAspectFit;
        iconV.layer.cornerRadius = 2;
        iconV.clipsToBounds = YES;
        [_imgView addSubview:iconV];
        [_iconVArr addObject:iconV];
    }
    
    _hotFlagV = [[UIImageView alloc]initWithFrame:CGRectMake(_imgView.right+15, 15, 18, 18)];
    _hotFlagV.image = [BundleTool imageNamed:@"hot"];
    [self.contentView addSubview:_hotFlagV];
    
    
    _titleLab = [[YYLabel alloc]initWithFrame:CGRectMake(_imgView.right+15, 17, SCREENW-(_imgView.right+10+17), 50)];
    _titleLab.numberOfLines = 2;
    if (@available(iOS 8.2, *)) {
        _titleLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    }else{
        _titleLab.font = [UIFont systemFontOfSize:15];
    }
    _titleLab.textColor = HTColorFromRGB(0x333333);
    [self.contentView addSubview:_titleLab];
    
    _namesLab = [[UILabel alloc]initWithFrame:CGRectMake(_imgView.right+15, _titleLab.bottom+8, _titleLab.width,50)];
    _namesLab.numberOfLines = 2;
    _namesLab.font = [UIFont systemFontOfSize:14];
    _namesLab.textColor = HTColorFromRGB(0x999999);
    [self.contentView addSubview:_namesLab];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(16, 99, SCREENW - 32, 1)];
    line.backgroundColor = LIST_LINE_COLOR;
    [self.contentView addSubview:line];
    
}


-(void)setGroupM:(GroupModel *)groupM{
    _groupM = groupM;
    if (![PublicTool isNull:groupM.img_url]) {
        [_imgView sd_setImageWithURL:[NSURL URLWithString:groupM.img_url]];
//        [_imgView.subviews makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
        
        for (UIImageView *view in _imgView.subviews) {
            view.hidden = YES;
        }
    }else{
        [_imgView sd_cancelCurrentAnimationImagesLoad];
        _imgView.image = nil;
        int i = 0;
        for (UIImageView *view in _imgView.subviews) {
            if (i >= groupM.product.count) {
                view.hidden = YES;
                i++;
                continue;
            }
            view.hidden = NO;
            NSDictionary *dict = groupM.product[i];
            [view sd_setImageWithURL:[NSURL URLWithString:dict[@"icon"]] placeholderImage:[BundleTool imageNamed:@"share_user_holder"]];
            i++;
        }
    }
    
    
    
    NSString *title = [groupM.name stringByAppendingString:[NSString stringWithFormat:@"(%@)",groupM.count]];
    UIFont *font;
    if (@available(iOS 8.2, *)) {
        font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    }else{
        font = [UIFont systemFontOfSize:15];
    }
    NSAttributedString *attText = [title stringWithParagraphlineSpeace:6 textColor:HTColorFromRGB(0x333333) textFont:font];
    NSMutableAttributedString *attMutaText = [[NSMutableAttributedString alloc]initWithAttributedString:attText];
//    [attMutaText addAttributes:@{NSForegroundColorAttributeName:HTColorFromRGB(0x737782),NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(attText.length - groupM.count.length-3, groupM.count.length+3)];
    
    if ([groupM.hot_flag integerValue] == 1) {
         [attMutaText insertAttributedString:[self hotAttrImage] atIndex:0];
        _hotFlagV.hidden = NO;
    } else {
        _hotFlagV.hidden = YES;
    }
    YYTextContainer *c = [YYTextContainer containerWithSize:CGSizeMake(SCREENW-(_imgView.right+15+16), 60)];
    c.maximumNumberOfRows = 2.0;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:c text:attMutaText];
    
//    _titleLab.attributedText = attMutaText;
    _titleLab.textLayout = layout;
//    [_titleLab sizeToFit];
    _titleLab.frame = CGRectMake(_imgView.right+15, 17, SCREENW-(_imgView.right+15+16), layout.textBoundingSize.height);
   
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (NSDictionary *dict in groupM.product) {
        [tmpArr addObject:dict[@"product"]];
    }
    NSString *products = [tmpArr componentsJoinedByString:@"、"];
    _namesLab.text = products;
    if (_titleLab.height > 30) {  // fontSize * 2
        _namesLab.numberOfLines = 1;
    } else {
        _namesLab.numberOfLines = 2;
    }
    [_namesLab sizeToFit];
    _namesLab.frame = CGRectMake(_imgView.right+15, _titleLab.bottom+8, SCREENW-(_imgView.right+15+16), _namesLab.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSMutableAttributedString *)hotAttrImage {
    UIImage *image = [BundleTool imageNamed:@"hot"];
    image = [UIImage new];
    NSMutableAttributedString *attr = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(18, 18) alignToFont:[UIFont systemFontOfSize:15] alignment:YYTextVerticalAlignmentBottom];
    return attr;
}
@end
