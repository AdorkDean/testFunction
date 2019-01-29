//
//  QMPRecentEventCell2.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/11/1.
//  Copyright © 2018 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonLibrary/BingGouProModel.h>
#import <CommonLibrary/SmarketEventModel.h>

@class QMPRecentEvent2;
NS_ASSUME_NONNULL_BEGIN
@interface QMPRecentEventCell2 : UITableViewCell
+ (QMPRecentEventCell2 *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) QMPRecentEvent2 *event;

@end

@interface QMPRecentEvent2 : NSObject
@property (nonatomic, copy) NSString *ticket_id;
@property (nonatomic, copy) NSString *ticket;
@property (nonatomic, copy) NSString *detail;

@property (nonatomic, copy) NSString *subType;

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *meta;
@property (nonatomic, assign) BOOL hasBP;

@property (nonatomic, assign) CGFloat cellHeight;

- (instancetype)initWithBingGouProModel:(BingGouProModel *)event;
@property (nonatomic, assign) BOOL isAll;

- (instancetype)initWithSmarketEventModel:(SmarketEventModel *)event;
@end
NS_ASSUME_NONNULL_END
