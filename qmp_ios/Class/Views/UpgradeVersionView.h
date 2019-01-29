//
//  UpgradeVersionView.h
//  qmp_ios
//
//  Created by QMP on 2018/7/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpgradeVersionView : UIView

@property (weak, nonatomic) IBOutlet UIView *bgWhiteV;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet UILabel *versionLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;


+ (void)showUpgradView:(NSString*)content showClose:(BOOL)showClose version:(NSString*)version;

@end
