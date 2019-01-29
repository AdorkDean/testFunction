//
//  CardEditingViewController.h
//  qmp_ios
//
//  Created by Molly on 16/9/27.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardItem.h"

typedef void(^CardEditFinish)(CardItem *card);


@interface CardEditingViewController : BaseViewController



@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) CardItem *card;
@property (assign, nonatomic) BOOL isUpload; //YES:添加  NO:编辑

@property (copy, nonatomic)CardEditFinish cardEditFinish;

@end
