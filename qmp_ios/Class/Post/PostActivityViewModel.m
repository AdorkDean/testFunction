//
//  PostActivityViewModel.m
//  qmp_ios
//
//  Created by QMP on 2018/6/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PostActivityViewModel.h"
#import "ActivityModel.h"
#import "SearchCompanyModel.h"
#import "SearchJigouModel.h"
#import "PersonModel.h"
#import "SearchPerson.h"
#import "OrganizeItem.h"
#import "CompanyDetailModel.h"

@interface PostActivityViewModel ()
@property (nonatomic, strong, readwrite) RACCommand *postActivityCommand;

@property (nonatomic, strong, readwrite) RACSignal *companysChangeSignal;
@end
@implementation PostActivityViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    RACSignal *validPostSignal = [[[RACObserve(self, content)
                                    map:^(NSString *content) {
                                          return [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                      }]
                                    map:^(NSString *content) {
                                         return @(content.length > 0);
                                     }]
                                    distinctUntilChanged];
    
    @weakify(self)
    self.postActivityCommand = [[RACCommand alloc] initWithEnabled:validPostSignal signalBlock:^(id input) {
        @strongify(self)
        return [self postActivitySignal];
    }];
    
    RACSignal *signal1 = [self.companys rac_signalForSelector:@selector(addObject:)];
    RACSignal *signal2 = [self.companys rac_signalForSelector:@selector(removeObjectAtIndex:)];
    
    
    self.companysChangeSignal = [signal1 merge:signal2];
}

- (RACSignal *)postActivitySignal {
    return [RACSignal createSignal:^RACDisposable * (id subscriber) {
        [self postActivityWithContent:self.content complete:^(id response) {
            [subscriber sendNext:response];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}
- (void)postActivityWithContent:(NSString *)content complete:(void(^)(id response))completeBlock {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        completeBlock(@"ok");
    });
}
- (void)addSelectCompanys:(id)model {
    
//    if ([model isKindOfClass:[SearchCompanyModel class]]) {
//        SearchCompanyModel *cModel = (SearchCompanyModel *)model;
//        for (SearchCompanyModel *m in self.companys) {
//            if ([m.productId isEqualToString:cModel.productId]) {
//                return;
//            }
//        }
        [self.companys removeAllObjects];
        [self.companys addObject:model];
//    }
}
- (NSString *)productID {
    if (self.companys.count <= 0) {
        return nil;
    }
    SearchCompanyModel *cModel = [self.companys firstObject];
    return cModel.productId;
}
- (NSMutableArray *)companys {
    if (!_companys) {
        _companys = [NSMutableArray array];
    }
    return _companys;
}
@end


@implementation PostSelectRelateViewModel
- (void)removeRelateObject:(id)object {
    if (![self.relateObjects containsObject:object]) {
        return;
    }
    [[self mutableArrayValueForKey:@"relateObjects"] removeObject:object];
}
- (void)addNewRelateObject:(id)object type:(NSString *)theType {
    if (!object) {
        return;
    }

    
    ActivityRelateModel *model = [[ActivityRelateModel alloc] init];
    if ([object isKindOfClass:[SearchCompanyModel class]]) {
        SearchCompanyModel *m = (SearchCompanyModel*)object;
        model.name = m.product;
        NSDictionary *d = [PublicTool toGetDictFromStr:m.detail];
        model.ID = d[@"ticket"];
        model.type = @"product";
        model.image = m.icon;
        model.qmpIcon = @"activity_product";
    } else if ([object isKindOfClass:[SearchJigouModel class]]) {
        SearchJigouModel *m = (SearchJigouModel *)object;
        model.name = m.jigou_name;
        NSDictionary *d = [PublicTool toGetDictFromStr:m.detail];
        model.ID = d[@"ticket"];
        model.type = @"jigou";
        model.image = m.icon;
        model.qmpIcon = @"activity_organization";
    } else if ([object isKindOfClass:[PersonModel class]]) {
        PersonModel *m = (PersonModel *)object;
        model.name = m.name;
        model.ID = m.ticket;
        model.type = @"person";
        model.image = m.icon;
        model.qmpIcon = @"activity_user";
    } else if ([object isKindOfClass:[SearchPerson class]]) {
        SearchPerson *m = (SearchPerson *)object;
        model.name = m.name;
        model.ID = m.ticket;
        model.type = @"person";
        model.image = m.icon;
        model.qmpIcon = @"activity_user";
    } else if ([object isKindOfClass:[CompanyDetailModel class]]) {
        CompanyDetailModel *m = (CompanyDetailModel *)object;
        model.ID = m.ticket;
        model.name = m.company_basic.product;
        model.type = @"product";
        model.image = m.company_basic.icon;
        model.qmpIcon = @"activity_product";
    } else if ([object isKindOfClass:[OrganizeItem class]]) {
        OrganizeItem *m = (OrganizeItem *)object;
        NSDictionary *d = [PublicTool toGetDictFromStr:m.detail];
        model.ID = d[@"ticket"];
        model.name = m.name;
        model.type = @"jigou";
        model.image = m.icon;
        model.qmpIcon = @"activity_organization";
    }
    
    for (ActivityRelateModel *sModel in self.relateObjects) {
        if ([sModel.ID isEqualToString:model.ID]) {
            return;
        }
    }
    
    [[self mutableArrayValueForKey:@"relateObjects"] addObject:model];
}
- (NSMutableArray *)relateObjects {
    if (!_relateObjects) {
        _relateObjects = [NSMutableArray array];
    }
    return _relateObjects;
}
- (NSDictionary *)paramOfRelateObject {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *organize = [NSMutableArray array];
    NSMutableArray *product = [NSMutableArray array];
    NSMutableArray *person = [NSMutableArray array];
    for (ActivityRelateModel *model in self.relateObjects) {
        if ([model.type isEqualToString:@"jigou"]) {
            [organize addObject:model.ID];
        } else if ([model.type isEqualToString:@"product"]) {
            [product addObject:model.ID];
        } else if ([model.type isEqualToString:@"person"]) {
            [person addObject:model.ID];
        }
    }
    [dict setValue:[product componentsJoinedByString:@"|"] forKey:@"product"];
    [dict setValue:[organize componentsJoinedByString:@"|"] forKey:@"agency"];
    [dict setValue:[person componentsJoinedByString:@"|"] forKey:@"person"];
    
    return dict;
}

@end
