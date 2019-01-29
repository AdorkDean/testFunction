//
//  CommunityClaimView.h
//  CommonLibrary
//
//  Created by QMP on 2019/1/24.
//  Copyright © 2019 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommunityClaimView : UIView
@property (weak, nonatomic) IBOutlet UIButton *claimBtn;

+ (void)showClaimView;

@end

NS_ASSUME_NONNULL_END
