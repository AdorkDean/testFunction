//
//  CollectionListViewController.h
//  QimingpianSearch
//
//  Created by Molly on 16/8/2.
//  Copyright © 2016年 qimingpian. All rights reserved.
//网页收藏   我的-> 

#import <UIKit/UIKit.h>

@protocol CollectListVCDelegate<NSObject>
@optional
- (void)collectListHasException:(NSString *)status withData:(NSDictionary *)dict;
@end

@interface CollectionListViewController : BaseViewController{

    NSMutableArray *arrSites;
    NSUserDefaults *sharedUserDefaults;
}
@property (nonatomic, weak) id<CollectListVCDelegate> delegate;

//@property (weak, nonatomic) UINavigationController *currentNav;


@end
