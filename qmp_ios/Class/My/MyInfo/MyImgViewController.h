//
//  MyImgViewController.h
//  qmp_ios
//
//  Created by molly on 2017/3/21.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyImgViewControllerDelegate <NSObject>

- (void)updateInfoSuccess:(NSString *)value withKey:(NSString *)key;
@end


@interface MyImgViewController : UIViewController

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *value;
@property (weak, nonatomic) id <MyImgViewControllerDelegate> delegate;

@end
