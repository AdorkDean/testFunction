//
//  HapmapFieldCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HapMapAreaModel.h"

@interface HapmapFieldCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(HapMapAreaModel*)areaM;

@property(nonatomic,strong) HapMapAreaModel *areaModel;

@property (copy, nonatomic)void(^clickBigClass)(NSString* name);
@property (copy, nonatomic)void(^clickSubClass)(NSString* name);


- (void)refreshUI:(HapMapAreaModel*)areaModel;

@end
