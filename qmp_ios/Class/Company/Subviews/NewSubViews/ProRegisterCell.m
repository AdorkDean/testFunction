//
//  ProRegisterCell.m
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProRegisterCell.h"
#import "ScrollCollectView.h"


@interface ProRegisterCell()

@property(nonatomic,strong)NSArray *titles;
@property(nonatomic,strong)NSArray *images;
@property(nonatomic,copy)void(^didSelectItem)(NSString *title);

@end


@implementation ProRegisterCell

+ (instancetype)cellWithTableView:(UITableView*)tableView titles:(NSArray*)titles  images:(NSArray*)images didSelectedItem:(void(^)(NSString *title))didSelectItem{
    
    ProRegisterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProRegistCellID"];
    if (!cell) {
        cell = [[ProRegisterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProRegistCellID"];        
        cell.didSelectItem = didSelectItem;
        cell.titles = titles;
        cell.images = images;
        [cell addViews];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)addViews{
    
    ScrollCollectView *scrollV = [[ScrollCollectView alloc]initWithFrame:CGRectMake(0, 5, self.width, 70) titles:self.titles images:self.images selectedImages:self.images  didSelectedItem:self.didSelectItem];
    scrollV.unSelectTitleColor = COLOR2D343A;
    scrollV.selectTitleColor = COLOR2D343A;
    scrollV.tag = 1000;
    [self.contentView addSubview:scrollV];
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    ScrollCollectView *collecV = [self.contentView viewWithTag:1000];
    collecV.frame = CGRectMake(0, 5, self.width, 70);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
