//
//  ShareView.h
//  qmp_ios
//
//  Created by QMP on 2017/8/23.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedPlatform)(ShareType shareType);
@interface ShareView : UIView

@property (copy, nonatomic)SelectedPlatform selectedPlatform;

+(ShareView*)showShareViewDidTapPlatform:(SelectedPlatform)selectPlayform;
+(ShareView*)showShareViewCanCopyURL:(BOOL)copyURL didTapPlatform:(SelectedPlatform)selectPlayform;

@end
