//
//  WechatUserInfo.m
//  QiMingPian
//
//  Created by qimingpian08 on 16/4/25.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "WechatUserInfo.h"
#import "FriendModel.h"
#import "PublicTool.h"

@interface WechatUserInfo()

@property(nonatomic,strong)NSArray *propertysArr;

@end
@implementation WechatUserInfo

static WechatUserInfo *userInfo = nil;
static dispatch_once_t onceToken = 0;
+ (instancetype)shared{
    dispatch_once(&onceToken, ^{
        userInfo = [[WechatUserInfo alloc]init];
    });
    return userInfo;
    
}


- (instancetype)init{
    //从NSUserDefault获取属性内容
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    [self setValuesForKeysWithDictionary:[userDefault dictionaryRepresentation]];
    return self;
}

- (void)save{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    for (NSString *property in self.propertysArr) {
        if ([self valueForKey:property]) {
            if ([self valueForKey:property]) {
                if ([[self valueForKey:property] isKindOfClass:[NSString class]]) {
                    if ([PublicTool isNull:[self valueForKey:property]]) {
                        [userDefault setValue:@"" forKey:property];
                        continue;
                    }
                }
                [userDefault setValue:[self valueForKey:property] forKey:property];
            }
        }
    }
    
    [userDefault  synchronize];
}

- (void)clear{ //清空数据
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    for (NSString *property in self.propertysArr) {
        if ([self valueForKey:property]) {
            [userDefault setValue:@"" forKey:property];
            [self setValue:@"" forKey:property];
        }
    }
    [userDefault  synchronize];
    
}

- (NSArray*)propertys{
    uint count;
    objc_property_t *property = class_copyPropertyList([WechatUserInfo class], &count);
    NSMutableArray *propertys = [NSMutableArray array];
    for (int i=0; i<count; i++) {
        const char* propertyStr = property_getName(property[i]);
        [propertys addObject:[[NSString alloc]initWithUTF8String:propertyStr]];
    }
    return propertys;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"userid"]) {
        _userid = value;
    }
}

-(void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues{
    [super setValuesForKeysWithDictionary:keyedValues];
   
    
    if (self.user_type) {
        self.vip = self.user_type;
    }else{
        self.vip = @"";
    }
    self.zhiwei = [NSString stringWithFormat:@"%@",keyedValues[@"zhiwu"]];
    self.claim_type = [NSString stringWithFormat:@"%@",keyedValues[@"claim_type"]];
    self.coin = [NSString stringWithFormat:@"%@",keyedValues[@"coin"]];
    self.person_role = [NSString stringWithFormat:@"%@",keyedValues[@"role"]];
}


-(NSString *)bind_phone{
    if ([PublicTool isNull:_bind_phone]) {
        return _phone;
    }
    return _bind_phone;
}

-(NSString *)phone{
    if ([PublicTool isNull:_phone]) {
        return _bind_phone;
    }
    return _phone;
}

- (NSArray*)propertysArr{
    if (!_propertysArr) {
        _propertysArr = @[@"userid",@"unionid",@"uuid",@"app_focus",@"person_id",@"usercode",@"nickname",@"flower_name",@"company",@"zhiwei",@"headimgurl",@"wechat",@"phone",@"bind_flag",@"claim_type",@"apply_count",@"bp_count",@"exchange_card_count",@"system_notification_count",@"activity_notifi_count",];
    }
    return _propertysArr;
}

@end
