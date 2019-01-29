//
//  CardUploadTool.m
//  qmp_ios
//
//  Created by QMP on 2018/4/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CardUploadTool.h"
#import "CardLeadProgressView.h"
#import "CardItem.h"


@interface CardUploadTool()

@property(nonatomic,assign)NSInteger totalCardNum;
@property(nonatomic,assign)NSInteger finishCardNum;
@property(nonatomic,copy)void (^uploadFinishOne)(void) ;
@property(nonatomic,strong)CardLeadProgressView *progressView;

@end

@implementation CardUploadTool

static CardUploadTool *cardTool = nil;
static dispatch_once_t onceToken = 0;

+(instancetype)shared{
    dispatch_once(&onceToken, ^{
        cardTool = [[CardUploadTool alloc]init];
    });
    return cardTool;
}

- (void)showUploadView{
    
    if (self.progressView.superview) {
        if (self.finishCardNum == self.totalCardNum) {
            [self.progressView removeFromSuperview];
        }
        return;
    }
    
    [[PublicTool topViewController].view addSubview:self.progressView];
    self.progressView.centerY = [PublicTool topViewController].view.height/2.0;
}



- (void)uploadCardsImages:(NSArray*)cardImgs finishOneImage:(void (^)(void)) finishOne{
    
    self.uploadFinishOne = finishOne;
    self.totalCardNum = cardImgs.count;
    self.finishCardNum = 0;
    
    self.progressView = [[BundleTool commonBundle] loadNibNamed:@"CardLeadProgressView" owner:nil options:nil].lastObject;
    self.progressView.frame = CGRectMake(0, 0, SCREENW, 200);
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.titleLab.text = [NSString stringWithFormat:@"本次上传人脉信息共%ld条",cardImgs.count];
    self.progressView.progressLab.text = @"0%";
    self.progressView.alertTitle.text = @"提示";
    
    [self showUploadView];
    for (UIImage *img in cardImgs) {
        
        [[NetworkManager sharedMgr] scanCardApiWithImage:img resultDic:^(NSDictionary *resultDic) {
            
            [PublicTool dismissHud:KEYWindow];
            
            if (resultDic) {
                
                QMPLog(@"名片=-------------%@",resultDic);
                CardItem *card = [[CardItem alloc]init];
                [card setValuesForKeysWithDictionary:resultDic];
                [self requesetUploadImg:card image:img];
                
                
            }
        }];
    }
}

- (void)requesetUploadImg:(CardItem*)card image:(UIImage*)image{
    
    [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
        
        self.finishCardNum ++;

        if (![PublicTool isNull:fileUrl]) {
            NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            [mDict setValue:card.cardName?card.cardName:@"" forKey:@"name"];
            [mDict setValue:card.phone?card.phone:@"" forKey:@"phone"];
            [mDict setValue:card.zhiwu?card.zhiwu:@"" forKey:@"zhiwu"];
            [mDict setValue:card.email?card.email:@"" forKey:@"email"];
            [mDict setValue:card.company?card.company:@"" forKey:@"company"];
            [mDict setValue:fileUrl forKey:@"web_url"];

            [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:QMPUserAddCard HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
               

                if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
                    if (self.uploadFinishOne) {
                        self.uploadFinishOne();
                    }
                    
                    if (![[PublicTool topViewController]isKindOfClass:NSClassFromString(@"CardListController")]) {
                        [self.progressView removeFromSuperview];
                    }
                    self.progressView.progressLab.text = [NSString stringWithFormat:@"%.0f%%",self.finishCardNum*100.0/self.totalCardNum];
                }
                if (self.finishCardNum == self.totalCardNum) {
                    self.totalCardNum = 0;
                    self.progressView.alertTitle.text = @"名片上传已完成";
                    self.progressView.progressLab.text = @"100%";
                    
                    if (!self.progressView.superview) {
                        [[PublicTool topViewController].view addSubview:self.progressView];
                        self.progressView.centerY = [PublicTool topViewController].view.height/2.0;
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3), dispatch_get_main_queue(), ^{
                        if (self.progressView.superview) {
                            [self.progressView removeFromSuperview];
                            
                        }
                    });
                }
            }];
        }
    }];
    
    
}


@end
