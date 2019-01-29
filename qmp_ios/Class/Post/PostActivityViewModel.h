//
//  PostActivityViewModel.h
//  qmp_ios
//
//  Created by QMP on 2018/6/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>
@interface PostActivityViewModel : NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong, readonly) RACCommand *postActivityCommand;

@property (nonatomic, strong) NSMutableArray *companys;
- (void)addSelectCompanys:(id)model;
- (void)removeSelectCompanys:(id)model;

@property (nonatomic, strong, readonly) RACSignal *companysChangeSignal;

@property (nonatomic, strong) NSString *productID;


@end

@interface PostSelectRelateViewModel : NSObject
@property (nonatomic, strong) NSMutableArray *relateObjects;
- (void)addNewRelateObject:(id)object type:(NSString *)theType;
- (void)removeRelateObject:(id)object;

- (NSDictionary *)paramOfRelateObject;
@end
