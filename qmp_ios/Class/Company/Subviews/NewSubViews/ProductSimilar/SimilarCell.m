//
//  SimilarCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/24.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SimilarCell.h"
#import "InsetsLabel.h"

@interface SimilarCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLab;
@property (weak, nonatomic) IBOutlet InsetsLabel *lunciLab;
@property (weak, nonatomic) IBOutlet UILabel *iconLab;
@property (weak, nonatomic) IBOutlet UILabel *hangyeLab;

@property (strong, nonatomic) id model;

@end


@implementation SimilarCell
-(void)awakeFromNib{
    
    [super awakeFromNib];
    
    self.iconImgV.layer.masksToBounds = YES;
    self.iconImgV.layer.cornerRadius = 5;
    self.iconImgV.layer.borderColor = [BORDER_LINE_COLOR CGColor];
    self.iconImgV.layer.borderWidth = 0.5;
    
    [_lunciLab labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2];
    _lunciLab.backgroundColor = LABEL_BG_COLOR;
    
    _nameLab.textColor = COLOR2D343A;
    _hangyeLab.textColor = COLOR737782;
}


+ (instancetype)cellWithCollectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath{
    SimilarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SimilarCellID" forIndexPath:indexPath];
    cell.iconLab.hidden = YES;
    return cell;
}


- (void)setYewuModel:(SearchCompanyModel *)yewuModel{
    
    _yewuModel = yewuModel;
    _model = yewuModel;
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:yewuModel.icon] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
    self.nameLab.text = yewuModel.product;
    self.subtitleLab.text = yewuModel.yewu;
   
    if ([PublicTool isNull:yewuModel.lunci]) {
        self.lunciLab.hidden = YES;
        self.lunciLab.text = @"1";
    }else{
        self.lunciLab.hidden = NO;
        self.lunciLab.text = yewuModel.lunci;
    }
    self.hangyeLab.hidden = YES;
    self.hangyeLab.text = @"1";
    
}

- (void)setTouziM:(PersonTouziModel *)touziM{
    
    _model = touziM;
    _touziM = touziM;
    
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:touziM.icon] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
    self.nameLab.text = touziM.product;
    self.hangyeLab.hidden = NO;
    self.subtitleLab.text = touziM.yewu;
    self.hangyeLab.text = touziM.hangye;
    self.lunciLab.hidden = YES;
    self.lunciLab.text = @"1";
}

- (void)setIconColor:(UIColor *)iconColor{
    if ([PublicTool isNull:[_model valueForKey:@"icon"]] || [[_model valueForKey:@"icon"] containsString:@"jigou_default.png"]) {
        _iconLab.hidden = NO;
        _iconLab.backgroundColor = iconColor;
        if ([[_model valueForKey:@"product"] length] > 1) {
            _iconLab.text = [[_model valueForKey:@"icon"] substringToIndex:1];
        }else{
            _iconLab.text = @"-";
        }
    }else{
        _iconLab.hidden = YES;
    }
}

@end
