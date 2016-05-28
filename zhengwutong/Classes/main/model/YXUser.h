//
//  YXUser.h
//  Trader
//
//  Created by Wenquan Xu on 12-12-14.
//
//

#import <Foundation/Foundation.h>

@class TKAddressBookUser;

@interface YXUser : NSObject

# pragma mark - Data Encapsulation
@property (atomic,copy) NSString* userId;
@property (nonatomic,copy) NSString* loginAccount;    //登录账户名称

@property (nonatomic,copy) NSString* email;
@property (nonatomic,copy) NSString* emailPassword;
@property (nonatomic,copy) NSString* password;
@property (nonatomic,copy) NSString* sex;
@property (nonatomic,copy) NSString* organizationName;
@property (nonatomic,copy) NSString* organizationId;

@property (nonatomic,copy) NSString* phone;

@property (nonatomic,assign) BOOL defaultAvatar;
@property (nonatomic,copy) NSString *thumbnail;
@property (nonatomic,copy) NSString *fullname;
@property (nonatomic,copy) NSString *position;
@property (nonatomic,copy) NSString *tel;
@property (nonatomic,copy) NSString *cellPhoneNum;
@property (nonatomic,copy) NSString *QQ;
@property (nonatomic,copy) NSString *introduction;
@property (nonatomic,copy) NSString *activedCount;  //第几个用户
@property (nonatomic,copy) NSString *createdById;
@property (nonatomic,copy) NSString *accessToken;
@property (nonatomic,copy) NSString *root;
@property (nonatomic,copy) NSString *role;
@property (nonatomic,copy) NSString* status;
@property (nonatomic,copy) NSArray* allCompanies;
@property (nonatomic,readonly) NSInteger companyCount;


//权限控制,2015-7-14
@property (nonatomic,copy) NSString *mailEnabled;
@property (nonatomic,copy) NSString *reviewEnabled;
@property (nonatomic,copy) NSString *crmEnabled;
@property (nonatomic,copy) NSString *manageSubordinateEnabled;

//市场推广,2015-9-8
@property (nonatomic,copy) NSString *marketingUrl;

-(id)initWithData:(NSDictionary*)data;
-(void)setData:(NSDictionary*)data;
-(NSDictionary*) proxyForJson;

@end
