//
//  YXUser.m
//  Trader
//
//  Created by Wenquan Xu on 12-12-14.
//
//

#import "YXUser.h"

#import "NSDictionaryAdditions.h"
#import "NSMutableDictionary+Safe.h"

#import "NSObject+performBlockAfterDelay.h"

#define kUserid @"id"
#define kUsername @"name"
#define kEmail @"email"
#define kEmailPassword @"emailPassword"
#define kPassword @"password"
#define kBrokerId @"brokerid"
#define kPhone @"phone"
#define kName @"fullname"
#define kPosition @"jobTitle"
#define kDefaultAvator @"defaultAvatar"
#define kThumbnail @"avatar"
#define kSex @"sex"
#define kActiveCount @"activedCount"
#define kMobile @"mobile"
#define kOrganizationName @"organizationname"
#define kOrganizationId @"kOrganizationId"
#define kDepartName @"departname"
#define kDepartId @"kDepartId"
#define kQQ @"qq"
#define kChangePasswordStatus @"requirePasswordChange"
#define kCreatedById @"createdById"
#define KIntroduction @"introduction"
#define kRoot @"root"
#define KRole @"role"
#define kAllCompanies @"allProfiles"

@implementation YXUser

# pragma mark - Data Encapsulation
- (id)initWithData:(NSDictionary*)data {
    if (![data count]) { return nil; }
    if (self=[super init]) {
        [self setData:data];
    }
    return self;
}

- (void)setData:(NSDictionary *)data
{
    NSDictionary* organization=[data objectForKey:@"organization" ofType:[NSDictionary class]];
    self.userId = [data getStringValueForKey:kUserid defaultValue:nil];
    self.loginAccount = GetStringFromDictionary(data, @"loginAccount");
    self.allCompanies = GetArrayFromDictionary(data, kAllCompanies);
    
    if (self.allCompanies.count == 0) {
        // 前者会在"allProfiles"接口中返回所有可用公司列表，后者仅会在"alternativeProfiles"
        // 返回除当前公司以外的其他公司列表
        NSArray* otherCompanies = GetArrayFromDictionary(data, @"alternativeProfiles");
        NSMutableArray *allCompanies = [[NSMutableArray alloc]init];
        for (NSDictionary *dic in otherCompanies) {
           NSString *status=[dic getStringValueForKey:@"status" defaultValue:nil];
            if (![status isEqualToString: @"2"]) {
                [allCompanies addObject:dic];
            }
        }
        self.allCompanies = allCompanies;

        
//        if (otherCompanies.count > 0 || self.userId.length > 0) {
//            NSMutableArray *allCompanies = [[NSMutableArray alloc] initWithArray:otherCompanies];
//            [allCompanies addObject:data];
//        }
    }

    self.organizationId=[organization getStringValueForKey:@"id" defaultValue:nil];
    self.introduction = [data getStringValueForKey:KIntroduction defaultValue:@""];
    self.fullname = [data getStringValueForKey:kName defaultValue:@""];
    self.position = [data getStringValueForKey:kPosition defaultValue:@""];
    self.defaultAvatar = [data getBoolValueForKey:kDefaultAvator defaultValue:YES];
    self.thumbnail = [data getStringValueForKey:kThumbnail defaultValue:@"man100.png"];
    self.cellPhoneNum = [data getStringValueForKey:kMobile defaultValue:@""];
    self.tel = [data getStringValueForKey:kPhone defaultValue:@""];
    self.email = [data getStringValueForKey:kEmail defaultValue:nil];
    self.emailPassword = [data getStringValueForKey:kEmailPassword defaultValue:nil];
    self.password=[data getStringValueForKey:kPassword defaultValue:nil];
    
    self.status=[data getStringValueForKey:@"status" defaultValue:nil];
    
    self.createdById=[data getStringValueForKey:kCreatedById defaultValue:nil];
    
    self.root=GetStringFromDictionary(data,kRoot);
    self.role=GetStringFromDictionary(data,KRole);
    if(GetStringFromDictionary(data, kAccessToken)){
        self.accessToken = GetStringFromDictionary(data, kAccessToken);
    }
    NSString * sexStr = [data objectForKey:kSex ofType:[NSString class]];
    
    self.activedCount = [data objectForKey:kActiveCount ofType:[NSString class]];
    
    
    if ([sexStr isEqualToString:@"2"])
    {
        self.sex = @"男";
    }else if ([sexStr isEqualToString:@"1"])
    {
        self.sex = @"女";
    }
    
    self.organizationName = [organization objectForKey:kName];
    if (!self.organizationName   ||[self.organizationName isEqual:[NSNull null]] || [self.organizationName isEqualToString:@""]) {
        self.organizationName = [data getStringValueForKey:kOrganizationName defaultValue:@"" ];
    }
    self.QQ = [data getStringValueForKey:kQQ defaultValue:@""];
    
    if (self.organizationId==nil) {
        self.organizationId = [ data getStringValueForKey:kOrganizationId defaultValue:nil];
    }
    //增加权限
    NSDictionary* setting = GetDictionaryFromDictionary(data,@"settings");
//    self.mailEnabled = GetStringFromDictionary(setting, @"mailEnabled");
    self.reviewEnabled = GetStringFromDictionary(setting, @"reviewEnabled");
    self.crmEnabled = GetStringFromDictionary(setting, @"crmEnabled");
    
    //汇报管理
    NSArray* featureRoles = GetArrayFromDictionary(data, @"featureRoles");
    self.manageSubordinateEnabled = nil;
    [featureRoles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj intValue] == 1) {
            self.manageSubordinateEnabled = @"1";
        }
    }];
    
    //市场推广
    self.marketingUrl = GetStringFromDictionary(setting, @"marketingUrl");

    //test
    //self.marketingUrl = @"h5/organizations/new.html";
}

-(NSDictionary*) proxyForJson
{
    NSMutableDictionary* dict=[NSMutableDictionary dictionary];
    if(self.userId) [dict setObject:self.userId forKey:kUserid];
    if(self.loginAccount) [dict setObject:self.loginAccount forKeyedSubscript:@"loginAccount"];
    if(self.allCompanies) [dict setObject:self.allCompanies forKey:kAllCompanies];
    if(self.email) [dict setObject:self.email forKey:kEmail];
    if (self.emailPassword) [dict setObject:self.emailPassword forKey:kEmailPassword];
    if(self.password) [dict setObject:self.password forKey:kPassword];
    if (self.tel) [dict setObject:self.tel forKey:kPhone];
    if (self.cellPhoneNum) [dict setObject:self.cellPhoneNum forKey:kMobile];
    if (self.introduction) [dict setObject:self.introduction forKey:KIntroduction];
    if (self.fullname) [dict setObject:self.fullname forKey:kName];
    if (self.position) [dict setObject:self.position forKey:kPosition];
    if (self.thumbnail) [dict setObject:self.thumbnail forKey:kThumbnail];
    if (self.defaultAvatar) [dict setObject:@(self.defaultAvatar) forKeyedSubscript:kDefaultAvator];
    if (self.sex) [dict setObject:self.sex forKey:kSex];
    if (self.organizationName) [dict setObject:self.organizationName forKey:kOrganizationName];
    if (self.organizationId)[dict setObject:self.organizationId forKey:kOrganizationId];
    if (self.QQ) [dict setObject:self.QQ forKey:kQQ];
    
    if (self.status) {
        [dict setObject:self.status forKey:@"status"];
    }
    
    if(self.activedCount)
    {
        [dict setObject:self.activedCount forKey:kActiveCount];
    }
    
    if (self.createdById) {
        [dict setObject:self.createdById forKey:kCreatedById];
    }
    if (self.accessToken) {
        [dict setObject:self.accessToken forKey:kAccessToken];
    }
    
    
    if (self.root) {
        [dict setObject:self.root forKey:kRoot];
    }
    
    //增加权限
    {
        NSMutableDictionary* rights = [NSMutableDictionary new];
        if(self.reviewEnabled)
            [rights setObject:self.reviewEnabled forKey:@"reviewEnabled"];
        if(self.crmEnabled)
            [rights setObject:self.crmEnabled forKey:@"crmEnabled"];
        //市场推广
        if(self.marketingUrl)
            [rights setObject:self.marketingUrl forKey:@"marketingUrl"];

        // Junyu: 12/25/2015:
        // 放开邮箱入口是否出现的限制。修改管理员弹窗的范围。
        // if(self.mailEnabled)
        //     [rights setObject:self.mailEnabled forKey:@"mailEnabled"];
        
        [dict setObject:rights forKey:@"settings"];
    }
    
    //汇报管理
    {
        NSMutableArray* featureRoles = [NSMutableArray new];
        if (self.manageSubordinateEnabled) {
            [featureRoles addObject:@"1"];
        }
        [dict setObject:featureRoles forKey:@"featureRoles"];
    }
    
    return dict;
}

- (NSInteger)companyCount
{
    return self.allCompanies.count;
}

# pragma mark - 推导出来的属性

-(NSString*) getBasicAuth
{
    if( self.cellPhoneNum!=nil && self.cellPhoneNum.length!=0 )
        return self.cellPhoneNum;
    
    if( self.email!=nil && self.email.length!=0)
        return self.email;
    
    NSLog(@"wrong basic auth");
    return @"";
}
-(BOOL)isSuperManager  { return  [self.root          isEqualToString:@"1"]; }
-(BOOL)isManager       { return  [self.role          isEqualToString:@"1"]; }
-(BOOL)isMailEnabled   { return ![self.mailEnabled   isEqualToString:@"0"]; }
-(BOOL)isReviewEnabled { return ![self.reviewEnabled isEqualToString:@"0"]; }
-(BOOL)isCrmEnabled    { return ![self.crmEnabled    isEqualToString:@"0"]; }
-(BOOL)isManageSubordinateEnabled { return [self.manageSubordinateEnabled isEqualToString:@"1"]; }

@end
