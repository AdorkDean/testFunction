//
//  AreaCollCell.h
//  qmp_ios
//
//  Created by QMP on 2018/1/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AreaCollCell : UICollectionViewCell

@property(nonatomic,strong)UIButton *titleLab;
@property(nonatomic,strong)UIImageView *chaIcon;
@property(nonatomic,assign) BOOL editing;

-(void)showAddIcon:(BOOL)show text:(NSString*)text;

@end
