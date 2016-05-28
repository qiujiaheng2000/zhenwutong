//
//  GlobalFunc.m
//  Trader
//
//  Created by zhenglibao on 14-9-30.
//
//

#import "AppDelegate.h"
#import "NSString+SBJSON.h"
#import "NSDictionaryAdditions.h"
#import "NSObject+SBJSON.h"
#import "NSObject+performBlockAfterDelay.h"
#import "AlertBox.h"
#import "GlobalFunc.h"
#import "UIImage+Resize.h"
#import <AVFoundation/AVFoundation.h>
#import "ZWTTabBarController.h"
#import "UIAlertView+Helper.h"
#include <sys/time.h>
#import <objc/runtime.h>
#import "SDImageCache.h"

void CrashOnSimulator(NSString *errorMsg) {
    if((TARGET_OS_SIMULATOR)){raise(SIGSTOP);}
}

NSString * removeEMTag(NSString * string)
{
    if (string.length <= 0) {
        return @"";
    }
    NSRange rangeLeft = [string rangeOfString:@"<em>"];
    NSRange rangeRight = [string rangeOfString:@"</em>"];
    NSString * temp = string;
    while (rangeLeft.location!= NSNotFound && rangeRight.location != NSNotFound) {
        temp = [temp stringByReplacingCharactersInRange:rangeLeft withString:@""];
        rangeRight = [temp rangeOfString:@"</em>"];
        temp = [temp stringByReplacingCharactersInRange:rangeRight withString:@""];
        rangeLeft = [temp rangeOfString:@"<em>"];
        rangeRight = [temp rangeOfString:@"</em>"];
    }
//    NSString * temp = [string stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
//    temp = [temp stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
    return temp;
}

void checkNetWorkEnable(){
#ifdef dev
#else
//    if (!isNetworkEnabled()){
//        [AlertBox showMessage:@"网络状况不佳，请稍后重试" hideAfter:1.5];
//        return;
//    }
#endif
}




NSString * getDateStr(NSDate *date)
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-M-d"];
    NSString * result = [dateFormatter stringFromDate:date];
    return result;
}

void UpdateStatusBarColor()
{
    if(IsIos7OrAbove())
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
    }
}

UINavigationController* InitCustomNaviController(UIViewController* rootVC)
{
    return [[UINavigationController alloc]init];
}

UIViewController* getTopMostController()
{
    UIViewController *topController = [AppDelegate currentAppDelegate].window.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

UIViewController* getNearestViewController(UIView *view)
{
    id target=view;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}


BOOL isIPhone5()
{
    return ([[UIScreen mainScreen] bounds].size.height == 568);
}

BOOL isShortThanIphone5()
{
    return ([[UIScreen mainScreen] bounds].size.height < 568);
}
BOOL IsIos7OrAbove()
{
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    return (ver_float >= 7.0);
}
BOOL IsIos8OrAbove()
{
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    return (ver_float >= 8.0);
}
float GetIosVersion()
{
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    return ver_float ;
}
BOOL checkCemare()
{
    if (IsIos7OrAbove()) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
        {
            UIAlertView * alt = [[UIAlertView alloc] initWithTitle:@"未获得授权使用摄像头" message:@"请在iOS\"设置中\"-\"隐私\"-\"相机\"中打开" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
            [alt show];
            return NO;
        }else{
            return YES;
        }
    }
    return YES;
}
BOOL IsIosVersionOrAbove(float version)
{
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    return (ver_float >= version);
}


//从右侧push进controller
void AppPresentViewController(UIViewController* controller)
{
    if (!controller) {
        return;
    }
    
    UIViewController* top = getTopMostController() ;
   
    if ([top isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* nav = (UINavigationController*)top ;
        //防止多次push同一个页面
        if(nav.viewControllers.lastObject != controller)
        {
            [nav pushViewController:controller animated:YES];
        }
    }else
    {
        if( ![controller isKindOfClass:[UINavigationController class]])
        {
            UINavigationController* nav = InitCustomNaviController(controller);
            controller = nav ;
        }
        
        [top presentViewController:controller animated:YES completion:nil];
    }
}
void AppPresentViewControllerAnimation(UIViewController* controller,BOOL animation)
{
    if (!controller) {
        return;
    }
    
    UIViewController* top = getTopMostController() ;
    
    if ([top isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* nav = (UINavigationController*)top ;
        //防止多次push同一个页面
        if(nav.viewControllers.lastObject != controller)
        {
            [nav pushViewController:controller animated:animation];
        }
    }else
    {
        if( ![controller isKindOfClass:[UINavigationController class]])
        {
            UINavigationController* nav = InitCustomNaviController(controller);
            controller = nav ;
        }
        
        [top presentViewController:controller animated:animation completion:nil];
    }
}


void AppPresentViewControllerFromBottom(UIViewController* controller)
{
    AppPresentViewControllerFromBottomAnimation(controller,YES);
}
void AppPresentViewControllerFromBottomAnimation(UIViewController* controller,BOOL animated)
{
    if (!controller) {
        return;
    }
    
    UIViewController* top = getTopMostController() ;
    if( ![controller isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* nav = InitCustomNaviController(controller);
        controller = nav ;
    }
    
    [top presentViewController:controller animated:animated completion:nil];
}
void AppPopPushVC(UINavigationController* nav,UIViewController* vcToPush)
{
    NSMutableArray *controllers=[[NSMutableArray alloc] initWithArray:nav.viewControllers] ;
    [controllers removeLastObject];
    [nav setViewControllers:controllers];
    
    [nav pushViewController:vcToPush animated:YES];
}
void AppDismissViewController(BOOL bAnimated)
{
    UIViewController* top = getTopMostController() ;
    
    if( [top isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* nav = (UINavigationController*)top ;
        if( nav.childViewControllers.count>1)
        {
            [nav popViewControllerAnimated:bAnimated];
        }else
        {
            [top.presentingViewController dismissViewControllerAnimated:bAnimated completion:nil];
        }
        
    }else
    {
    
        [top.presentingViewController dismissViewControllerAnimated:bAnimated completion:nil];
    }
    UpdateStatusBarColor(); //防止某些系统的控制器弹出后导致颜色发生变化
}
void AppDismissAllViewController(BOOL bAnimated)
{
    UIViewController * top = getTopMostController();
    if(top.presentingViewController)
    {
        [top.presentingViewController dismissViewControllerAnimated:bAnimated completion:nil];
        UpdateStatusBarColor();
    }else
    {
        AppDismissViewController(bAnimated);
    }
}

void AppRegistSystemNotify(NSString* notifyName,id obj,SEL sel)
{
    [[NSNotificationCenter defaultCenter]addObserver:obj selector:sel name:notifyName object:nil];
}
void AppUnRegistSystemNotify(NSString* notifyName,id obj)
{
    [[NSNotificationCenter defaultCenter] removeObserver:obj name:notifyName
                                                  object:nil];
}
void AppPostSystemNotify(NSString* notifyName)
{
    [[NSNotificationCenter defaultCenter]postNotificationName:notifyName object:nil];
}

void AlertIfRequestErrorWithString(NSString* error)
{
    if (error.length > 0)
    {
        if( [NSThread isMainThread] ) {
            [AlertBox showMessage:error hideAfter:2];
        } else {
            [NSObject performBlockOnMainThread:^{
                [AlertBox showMessage:error hideAfter:2];
            }waitUntilDone:2];
        }
    }
}

// 返回从上一次调用经过的秒数
double GetTimeSinceLastCall()
{
    static struct timeval last ;
    static BOOL bFirst = YES ;
    double tf = 0 ;
    if(bFirst)
    {
        bFirst = NO;
        gettimeofday(&last,NULL);
        tf = last.tv_sec + (double)(last.tv_usec)/1000000.0 ;
    }else
    {
        struct timeval now ;
        gettimeofday(&now,NULL);
        tf = now.tv_sec-last.tv_sec + (now.tv_usec-last.tv_usec)/1000000.0;
        last = now ;
    }

    return tf;
}
//获取自1970-1-1到现在的精确秒数，精确到微秒
//等价于[[NSDate date] timeIntervalSince1970]
double GetAccurateSecondsSince1970()
{
    struct timeval now ;
    gettimeofday(&now,NULL);
    double tf = now.tv_sec + (double)(now.tv_usec)/1000000.0 ;
 
    return tf;
}

static int _gShowBusyCount = 0 ;

void ShowBusyIndicator()
{
    [NSObject performBlockOnMainThread:^{
        if (_gShowBusyCount==0)
        {
            [MBProgressHUD showHUDAddedTo:[AppDelegate currentAppDelegate].window animated:YES];
        }
        
        _gShowBusyCount++;
    } waitUntilDone:NO];
}
void ShowBusyTextIndicatorForView(UIView* forView,NSString* indicatorText)
{
    __block UIView *weakView = forView;
    [NSObject performBlockOnMainThread:^{
        
        MBProgressHUD* hud;
        
        if(forView==nil)
            weakView = [AppDelegate currentAppDelegate].window ;
        
        hud=[MBProgressHUD showHUDAddedTo:forView animated:YES];
        
        if (indicatorText!=nil)
        {
            hud.labelText = indicatorText ;
        }
    } waitUntilDone:NO];
}
void ShowBusyTextIndicatorBlockRigtBarItemForView(UIView *forView, NSString *indicatorText)
{
    UIResponder *nearestVC = nil;
    while ((nearestVC = forView.nextResponder)) {
        if ([nearestVC isKindOfClass:[UIViewController class]])
            break;
    }
    __block UIViewController *vc = (UIViewController *)nearestVC;
    __block UIView *weakView = forView;
    
    [NSObject performBlockOnMainThread:^{
        vc.navigationItem.rightBarButtonItem.enabled = NO;
        MBProgressHUD* hud;
        
        if(forView==nil)
            weakView = [AppDelegate currentAppDelegate].window ;
        
        hud=[MBProgressHUD showHUDAddedTo:forView animated:YES];
        
        if (indicatorText!=nil)
        {
            hud.labelText = indicatorText ;
        }
    } waitUntilDone:NO];
}

void HideBusyUnLockRigthBarItemForView(UIView *forView)
{
    UIResponder *nearestVC = nil;
    while ((nearestVC = forView.nextResponder)) {
        if ([nearestVC isKindOfClass:[UIViewController class]])
            break;
    }
    __block UIViewController *vc = (UIViewController *)nearestVC;
    [NSObject performBlockOnMainThread:^{
        vc.navigationItem.rightBarButtonItem.enabled = YES;
        [MBProgressHUD hideAllHUDsForView:forView animated:YES];
    } waitUntilDone:NO];

}

void HideBusyIndicator()
{
    [NSObject performBlockOnMainThread:^{
        _gShowBusyCount--;
        if (_gShowBusyCount<=0)
        {
            [MBProgressHUD hideHUDForView:[AppDelegate currentAppDelegate].window animated:YES];
        }
    } waitUntilDone:NO];
}
void HideBusyIndicatorAnimated(BOOL animated)
{
    [NSObject performBlockOnMainThread:^{
        _gShowBusyCount--;
        if (_gShowBusyCount<=0)
        {
            [MBProgressHUD hideHUDForView:[AppDelegate currentAppDelegate].window animated:animated];
        }
    } waitUntilDone:NO];
}
void HideBusyIndicatorForView(UIView* forView)
{
    [NSObject performBlockOnMainThread:^{
        [MBProgressHUD hideAllHUDsForView:forView animated:YES];
    } waitUntilDone:NO];
}
UITableViewCell* LoadTableCell(NSString* name)
{
    NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];
    
    UITableViewCell* cell = [topLevelObjects objectAtIndex:0];
    
    return  cell ;
}

id GetObjectFromDictionary(NSDictionary* dict,NSString* path,id defaultValue)
{
    if(dict==nil||path==nil)
        return defaultValue;
    
    NSRange range = [path rangeOfString:@"/"];
    NSString* parentKey = range.length==0 ? path : [path substringToIndex:range.location] ;
    NSString* subkey = range.length==0 ? nil : [path substringFromIndex:(range.location+1)] ;
    
    id obj = nil ;
    
    
    if ( [dict isKindOfClass:[NSArray class]] )
    {
        NSArray* ary = (NSArray*) dict ;
        
        int index = [parentKey intValue];
        
        if (ary.count > index && index >= 0)
            obj = [ary objectAtIndex:index];
    }else if( [dict isKindOfClass:[NSDictionary class]])
    {
        obj = [dict objectForKey:parentKey];
    }else
    {
        NSLog(@"wrong type");
    }
    
    if (range.length==0||obj==nil)
    {
        return obj==nil ? defaultValue : obj ;
    }
    return GetObjectFromDictionary(obj, subkey,defaultValue) ;
}

NSString* GetStringFromDictionary(NSDictionary* dict,NSString* path)
{
    NSString* obj = GetObjectFromDictionary(dict, path, nil);
    if (obj==nil)
    {
        return @"";
    }
    if(![obj isKindOfClass:[NSString class]])
    {
        if( [obj isKindOfClass:[NSNull class]])
            obj = @"";
        else
        {
            obj = [obj description];
            if(obj==nil)
                obj = @"";            
        }
    }
    return obj ;
}
NSArray* GetArrayFromDictionary(NSDictionary* dict,NSString* path)
{
    NSArray* obj = GetObjectFromDictionary(dict, path, nil);
    if (obj==nil||![obj isKindOfClass:[NSArray class]])
    {
        return @[];
    }
    return obj ;
}
NSDictionary* GetDictionaryFromDictionary(NSDictionary* dict,NSString* path)
{
    NSDictionary* obj = GetObjectFromDictionary(dict, path, nil);
    if (obj==nil||![obj isKindOfClass:[NSDictionary class]])
    {
       return @{};
    }
    return obj ;
}
NSInteger GetIntegerFromDictionary(NSDictionary* dict,NSString* path, NSInteger defaultValue)
{
    
    id number = GetObjectFromDictionary(dict, path, nil);
    if ([number isKindOfClass:[NSNumber class]])
    {
        return [number integerValue];
    }
    
    if ([number isKindOfClass:[NSString class]])
    {
        NSString * numberString = number;
        
        // check a string is number
        // code from http://stackoverflow.com/a/6091456
        static NSCharacterSet* notDigits;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        });
        
        if ([numberString rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            return [numberString integerValue];
        }
    }
    
    return defaultValue;
}
double GetDoubleFromDictionary(NSDictionary *dict, NSString *path, double defaultValue)
{
    NSString *doubleString = GetObjectFromDictionary(dict, path, nil);
    if (!doubleString) {
        return defaultValue;
    }
    return doubleString.doubleValue;
}

NSString* AppendMoneyChar(NSString* number)
{
    return  [@"￥" stringByAppendingString:number];
}

UIColor* BuildUIColor(int r,int g,int b,int alpha)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha/255.0];
}

UIColor* BuildUIColorWithHexString(NSString *hex)
{
    if ([hex length]==3)
    {
        NSString *r = [hex substringWithRange:NSMakeRange(0, 1)];
        NSString *g = [hex substringWithRange:NSMakeRange(1, 1)];
        NSString *b = [hex substringWithRange:NSMakeRange(2, 1)];
        
        hex = [NSString stringWithFormat:@"%@%@%@%@%@%@", r, r, g, g, b, b];
    }
    
    if ([hex hasPrefix:@"0x"] || [hex hasPrefix:@"0X"] ) {
        hex = [hex stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
    }
    
    if ([hex length]<6)
    {
        return nil;
    }
    
    unsigned int (^hex2IntBlock)(NSString *) = ^(NSString *value) {
        NSScanner *scanner = [NSScanner scannerWithString:value];
        unsigned int result = 0;
        [scanner scanHexInt: &result];
        return result;
    };
    
    CGFloat red = hex2IntBlock([hex substringWithRange:NSMakeRange(0, 2)])/255.0;
    CGFloat green = hex2IntBlock([hex substringWithRange:NSMakeRange(2, 2)])/255.0;
    CGFloat blue = hex2IntBlock([hex substringWithRange:NSMakeRange(4, 2)])/255.0;
    CGFloat alpha = 1.0;
    
    if (hex.length == 8) {
        alpha = hex2IntBlock([hex substringWithRange:NSMakeRange(6, 2)])/255.0;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

const static NSString* numberToChinese[]=
{
    @"零",
    @"一",
    @"二",
    @"三",
    @"四",
    @"五",
    @"六",
    @"七",
    @"八",
    @"九",
    @"十",
    @"十一",
    @"十二"
};

// 支持0~12转换为汉字
const NSString* ConvertNumToChinese(int n)
{
    if( n<0 )
    {
        n = 0 ;
    }else if( n>12 )
    {
        n = 12 ;
    }
    
    return numberToChinese[n];
}

//格式化金额
NSString* FormatMoney(double f)
{
 
    
    NSString* s ;
    s = [NSString stringWithFormat:@"%.2f",f];

    return s;
}

NSString* FormatCurrency(double f)
{
    static NSNumberFormatter *numberFormatter = nil;
    
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    }
    
    NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:f]];
    return numberAsString;
}

void CompressImageAsync(UIImage* originalImage,onImageFinish onOKEvent)
{
    if(onOKEvent==nil)
        return;
    
    UIImage* image = originalImage ;
    onImageFinish onok = [onOKEvent copy];
    
    [NSObject performBlockOnBackground:^{
        @autoreleasepool
        {
            CompressImageSync(image, onok);
        }
    }];
}

void CompressImageSync(UIImage* originalImage,onImageFinish onOKEvent)
{
    if(onOKEvent==nil)
        return;
    
    UIImage* image = originalImage ;
    onImageFinish onok = [onOKEvent copy];
    
    if ( image.size.width>IMAGE_MAX_SIZE||
         image.size.height>IMAGE_MAX_SIZE )
    {
        float fMax = MAX(image.size.width, image.size.height) ;
        float fScale = 1.0;
        if (fMax<=IMAGE_MAX_SIZE * 2){
            fScale = IMAGE_MAX_SIZE/fMax ;
        }
        else{
            fScale = 0.5 ;
        }
        
        UIImage *postImage = [image imageScaledToSize:CGSizeMake(fScale*image.size.width, fScale*image.size.height)];
        
        if( [NSThread isMainThread] )
        {
            onok(postImage);
        }else
        {
            [NSObject performBlockOnMainThread:^{
                onok(postImage);
            }waitUntilDone:YES];
        }
    }
    else if( [NSThread isMainThread] )
    {
        onok(image);
        
    }else
    {
        [NSObject performBlockOnMainThread:^{
            onok(image);
        }waitUntilDone:YES];
    }
}

UITableView* GetTableViewFromCell(UIView* view)
{
    UITableView *tableView = nil;
 
    while(view != nil) {
        if([view isKindOfClass:[UITableView class]]) {
            tableView = (UITableView *)view;
            break;
        }
        view = [view superview];
    }
    return tableView;
}
// 返回逆序的数组
NSArray* ReverseArray(NSArray* ary)
{
    NSMutableArray* result = [NSMutableArray new];
    
    for (int i=0; i<ary.count; i++)
    {
        id tmp = [ary objectAtIndex:(ary.count-1-i)];
        [result addObject:tmp];
    }

    return result;
}

BOOL isScrollAtEnd(UIScrollView* scrollView)
{
    CGPoint contentOffsetPoint = scrollView.contentOffset;
    CGRect frame = scrollView.frame;
    if (contentOffsetPoint.y >= scrollView.contentSize.height - frame.size.height || scrollView.contentSize.height <= frame.size.height)
    {
        return YES;
    }
    return NO;
}
BOOL isScrollAtBegin(UIScrollView* scrollView)
{
    CGPoint contentOffsetPoint = scrollView.contentOffset;
    CGRect frame = scrollView.frame;
    if (contentOffsetPoint.y <=0 || scrollView.contentSize.height <= frame.size.height)
    {
        return YES;
    }
    return NO;
}

BOOL IndexPathsContainsRow(NSArray* rows,NSInteger nSection,NSInteger nRow)
{
    for (NSIndexPath* path in rows)
    {
        if (path.section==nSection &&
            path.row==nRow)
        {
            return YES;
        }
    }
    return NO;
}
BOOL isTableAtEnd(UITableView* tableView)
{
    NSInteger nSecs = [tableView numberOfSections];
    if(nSecs==0)
        return YES;
    
    NSInteger nCurSec = nSecs-1;
    NSInteger nRows = 0 ;
    for (;nCurSec>=0;nCurSec--)
    {
        nRows = [tableView numberOfRowsInSection:nCurSec];
        if(nRows>0)
            break;
    }
    if( nCurSec<0 || nRows<=0 )
        return YES;
    
    NSArray* ary = [tableView indexPathsForVisibleRows];

    return IndexPathsContainsRow(ary,nCurSec,nRows-1);
}
BOOL isTableAtBegin(UITableView* tableView)
{
    NSInteger nSecs = [tableView numberOfSections];
    if(nSecs==0)
        return YES;
    
    NSInteger nCurSec = 0;
    NSInteger nRows = 0 ;
    for (;nCurSec<nSecs;nCurSec++)
    {
        nRows = [tableView numberOfRowsInSection:nCurSec];
        if(nRows>0)
            break;
    }
    if( nCurSec>=nSecs || nRows<=0 )
        return YES;
    
    NSArray* ary = [tableView indexPathsForVisibleRows];
    
    return IndexPathsContainsRow(ary,nCurSec,nRows-1);
}

void AppSetBadge(NSUInteger index,NSString* badgeString)
{
    badgeString = FormatBadge(badgeString);
    
    ZWTTabBarController *tabBarController =  (ZWTTabBarController*)[[AppDelegate currentAppDelegate].window rootViewController];
    
    [tabBarController setTabbarBadge:index badgeValue:badgeString];
}
#ifdef __IPHONE_8_0
BOOL checkNotificationType(UIUserNotificationType type)
{
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    return (currentSettings.types & type);
}
#endif
void AppSetApplicationBadge(int badgeNumber)
{
    UIApplication *application = [UIApplication sharedApplication];
    
#ifdef __IPHONE_8_0
    // compile with Xcode 6 or higher (iOS SDK >= 8.0)
    
    if(SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        application.applicationIconBadgeNumber = badgeNumber;
    }
    else
    {
        if (checkNotificationType(UIUserNotificationTypeBadge))
        {
            application.applicationIconBadgeNumber = badgeNumber;
        }
        else
        {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            
            if (checkNotificationType(UIUserNotificationTypeBadge))
            {
                application.applicationIconBadgeNumber = badgeNumber;
            }
        }
    }
    
#else
    // compile with Xcode 5 (iOS SDK < 8.0)
    application.applicationIconBadgeNumber = badgeNumber;
    
#endif
}
NSString* FormatBadge(NSString* badge)
{
    int n = [badge intValue];
    if (n>99)
    {
        return @"99+";
    }
    return badge;
}
BOOL isValidDictionary(id obj)
{
    return obj!=nil && [obj isKindOfClass:[NSDictionary class]];
}
BOOL isValidArray(id obj)
{
    return obj!=nil && [obj isKindOfClass:[NSArray class]];
}
BOOL isNonEmptyArray(NSArray *array)
{
    return isValidArray(array) && array.count > 0;
}
//长度非0的字符串为yes，否则NO
BOOL isValidString(id obj)
{
    if( obj!=nil && [obj isKindOfClass:[NSString class]] )
    {
        NSString* s = (NSString*)obj ;
        return  s.length!=0;
    }
    return NO;
}
void errorLog(NSString* errorMsg)
{
#ifdef dev
    [AlertBox showMessage:errorMsg hideAfter:5.0];
#endif
    NSArray *syms = [NSThread  callStackSymbols];
    if ([syms count] > 1) {
        NSLog(@"ERROR: %@, caller: %@ ", errorMsg, [syms objectAtIndex:1]);
    } else {
        NSLog(@"ERROR: %@", errorMsg);
    }
}

NSArray* Build24Hour()
{
    NSMutableArray* ary = [NSMutableArray new];
    
    for (int i=0; i<24; i++)
    {
        [ary addObject:[NSString stringWithFormat:@"%d",i]];
    }
    return ary;
}

NSArray* Build5Min()
{
    NSMutableArray* ary = [NSMutableArray new];
    
    for (int i=0; i<12; i++)
    {
        [ary addObject:[NSString stringWithFormat:@"%02d",i*5]];
    }
    return ary;
}

NSString * GetSizeString(NSInteger size)
{
    NSString * resultStr = @"";
    if (size < 0) {
        resultStr = @"0Byte";
    }
    else if (size < 1024) {
        resultStr = [NSString stringWithFormat:@"%ldByte",(long)size];
    }
    else if(size > 1024 && size < 1024 * 1024)
    {
        resultStr = [NSString stringWithFormat:@"%ldK",(long)size/1024];
    }
    else if (size > 1024 * 1024 && size < 1024 * 1024 * 1024)
    {
        resultStr = [NSString stringWithFormat:@"%.1fM",size/(1024*1024.0)];
    }
    else if (size > 1024 * 1024 * 1024)
    {
        resultStr = [NSString stringWithFormat:@"%.1fG",size/(1024*1024*1024.0)];
    }
    return  resultStr;
}
NSString * GetFileCachePath()
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        NSString * cachePath = [paths objectAtIndex:0];
        NSString * fileCachePath = [cachePath stringByAppendingString:@"/fileCache"];
        return fileCachePath;
    }
    return @"";
    
}
BOOL isFileExist(NSString* filePath)
{
    return [[NSFileManager defaultManager]fileExistsAtPath:filePath];
}
long long GetFileSize(NSString* filePath)
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}


//检查密码是否合法，如果不合法，会弹出提示
BOOL CheckPasswordValid(NSString* password)
{
    if( password==nil )
        return NO;
    
    
    BOOL bValid = YES ;
    NSString* sWarning ;
    
    if( password.length<6 )
    {
        bValid = NO ;
        sWarning = @"密码长度不能少于6位";
    }else if( password.length>20 )
    {
        bValid = NO ;
        sWarning = @"密码长度不能超过20位";
    }else
    {
        for (int i=0;i<password.length;i++)
        {
            unichar c = [password characterAtIndex:i];
            
            if ( (c>='a'&&c<='z') ||
                 (c>='A'&&c<='Z') ||
                 (c>='0'&&c<='9') ||
                 (c=='_') )
            {
                
            }else if( c==' ')
            {
                bValid = NO ;
                sWarning = @"密码不能包含空格";
                break;
            }else
            {
                bValid = NO ;
                sWarning = @"密码不能含有特殊字符";
                break;
            }
        }
    }
    if (!bValid)
    {
        [UIAlertView showAlertWithTitle:@"密码不合法" message:sWarning button:@"确定"];
    }
    return bValid;
}

BOOL isValidPhoneNumber(NSString* phoneNumber)
{
    NSString *invalidNumbers = [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789 "]] componentsJoinedByString:@""];
    
    if (invalidNumbers.length > 0) {
        return NO;
    }
    
    NSString *puredNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    return (puredNumber.length == 11);
}


void KillScroll(UIScrollView* scrollView)
{
    CGPoint offset = scrollView.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [scrollView setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [scrollView setContentOffset:offset animated:NO];
    scrollView.scrollEnabled = NO;
    scrollView.scrollEnabled = YES;
}
// 调整与view位于同一个父窗口中的所有其他view的位置
void AdjustAfterViewsYPosition(UIView* view,float ydiff,BOOL bAdjustAfter)
{
    UIView* pv = [view superview];
    float fBottom = CGRectGetMaxY(view.frame) ;
    float ftop = CGRectGetMinY(view.frame) ;
    
    for (UIView* cv in pv.subviews)
    {
        CGRect rcCurrent = cv.frame ;
        
        if( bAdjustAfter )
        {
            if (CGRectGetMinY(rcCurrent)>=fBottom)
            {
                rcCurrent.origin.y += ydiff ;
                cv.frame = rcCurrent ;
            }
        }else
        {
            if (CGRectGetMaxY(rcCurrent)<=ftop)
            {
                rcCurrent.origin.y -= ydiff ;
                cv.frame = rcCurrent ;
            }
        }
    }
}
void AdjustAfterViewsXPosition(UIView* view,float xdiff,BOOL bAdjustAfter)
{
    UIView* pv = [view superview];
    float fRight = CGRectGetMaxX(view.frame) ;
    float fLeft = CGRectGetMinX(view.frame) ;
    
    for (UIView* cv in pv.subviews)
    {
        CGRect rcCurrent = cv.frame ;
        
        if (bAdjustAfter)
        {
            if (CGRectGetMinX(rcCurrent)>=fRight)
            {
                rcCurrent.origin.x += xdiff ;
                cv.frame = rcCurrent ;
            }
        } else
        {
            if (CGRectGetMaxX(rcCurrent)<=fLeft)
            {
                rcCurrent.origin.x -= xdiff ;
                cv.frame = rcCurrent ;
            }
        }
    }
}

void AdjustViewWithAfterRects(UIView* view,CGRect rc)
{
    //调整子窗口相对位置
    CGRect rcOld = view.frame ;
    float xdiff = rc.size.width - rcOld.size.width ;
    float ydiff = rc.size.height - rcOld.size.height ;
    
    if(fabsf(xdiff)>0.1)
        AdjustAfterViewsXPosition(view, xdiff,YES);
    if(fabs(ydiff)>0.1)
        AdjustAfterViewsYPosition(view, ydiff,YES);

    view.frame = rc ;
}
// 调整view的大小，右侧和下册不动，
void AdjustViewWithPrevRects(UIView* view,CGSize newSize)
{
    //调整子窗口相对位置
    CGRect rcOld = view.frame ;
    float xdiff = newSize.width - rcOld.size.width ;
    float ydiff = newSize.height - rcOld.size.height ;
    
    if(fabsf(xdiff)>0.1)
        AdjustAfterViewsXPosition(view, xdiff,NO);
    if(fabs(ydiff)>0.1)
        AdjustAfterViewsYPosition(view, ydiff,NO);
    
    CGRect rcNew ;
    rcNew.origin.x = rcOld.origin.x - xdiff ;
    rcNew.origin.y = rcOld.origin.y - ydiff ;
    rcNew.size = newSize ;
    view.frame = rcNew ;
}


void storeUserIntValueForKey(NSString* key,int value)
{
    NSString* s = [NSString stringWithFormat:@"%d",value];
//    storeUserValueForKey(key, s);
}
int getUserIntValueForKey(NSString* key,int defaultValue)
{
    int result ;
    
//    NSString* s = getUserValueForKey(key, nil);
//    if(s==nil)
//        result = defaultValue ;
//    else
//        result = [s intValue];
    return result;
}
void storeGlobalValueForKey(NSString* key,NSString* value)
{
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
NSString* getGlobalValueForKey(NSString* key,NSString* defaultValue)
{
    NSString* s = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    if(s==nil)
        s=defaultValue;
    return s;
}
NSString* getFileNameFromPath(NSString* path)
{
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    if(range.length==0)
        return path ;
    
    NSString* filename = [path substringFromIndex:(range.location+1)] ;
    if (!isValidString(filename))
    {
        return getFileNameFromPath([path substringToIndex:range.location]);
    }
    return filename;
}
NSString* getFileNameWithoutExtFromPath(NSString* path)
{
    NSString* filename = getFileNameFromPath(path);
    NSRange range = [filename rangeOfString:@"." options:NSBackwardsSearch];
    if(range.length==0)
        return filename ;

    NSString* fileMainPart = [filename substringToIndex:range.location];
    return fileMainPart ;
}
NSString* getMIMETypeWithFilePath(NSString *filePath)
{
    // 1.判断文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    // 2.使用HTTP HEAD方法获取上传文件信息
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 3.调用同步方法获取文件的MimeType
    NSURLResponse *respose = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&respose error:NULL];
    return respose.MIMEType;
}
NSString* getOriginalImageUrl(NSString* imgUrl)
{
    NSRange range = [imgUrl rangeOfString:@"/" options:NSBackwardsSearch];
    if(range.length==0)
        return imgUrl ;
    
    NSString* subkey = [imgUrl substringFromIndex:(range.location+1)] ;
   
    if( [subkey isEqual:@"small"] ||
        [subkey isEqual:@"mid"] ||
        [subkey isEqual:@"big"] )
    {
        return [imgUrl substringToIndex:range.location];
    }
    return imgUrl ;
}
NSString* getLastPartFromPath(NSString* path)
{
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    if(range.length==0)
        return path ;
    
    NSString* subkey = [path substringFromIndex:(range.location+1)] ;
   
    return subkey;
}
NSString* getExtNameFromPath(NSString* path)
{
    NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
    if(range.length==0)
        return @"" ;
    
    NSString* subkey = [path substringFromIndex:(range.location+1)] ;
    
    return subkey;
}
BOOL IsOriginalImage(NSString* imgUrl)
{
    NSString* lastPart = getLastPartFromPath(imgUrl);
    
    lastPart = [lastPart lowercaseString] ;
    return  !([lastPart isEqual:@"big"] ||
            [lastPart isEqual:@"mid"] ||
            [lastPart isEqual:@"small"]) ;
}
UIView* getFocusOfView(UIView* parentView)
{
    NSArray* subs = parentView.subviews ;
    for (UIView* subview in subs) {
        UIView* focus = getFocusOfView(subview);
        if(focus!=nil)
            return focus;
    }
    
    if ([parentView isKindOfClass:[UITextField class]]||
        [parentView isKindOfClass:[UITextView class]]) {
        if ([parentView isFirstResponder]) {
            return parentView;
        }
    }
    return nil;
}
// 确保文件夹存在
NSString* GetSubDirInDocuments(NSString* subDir)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    if(!isValidString(subDir))
        return documentDirectory;
    
    NSString* imgCacheDir = [documentDirectory stringByAppendingPathComponent:subDir];
    
    
    // 检查目录是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isExist = [fileManager fileExistsAtPath:imgCacheDir isDirectory:&isDir];
    if( isExist )
    {
        if(!isDir)
        {
            [fileManager removeItemAtPath:imgCacheDir error:nil];
            [fileManager createDirectoryAtPath:imgCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }else
    {
        [fileManager createDirectoryAtPath:imgCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return imgCacheDir ;
}

NSString* GetIMCacheDir()
{
    return GetSubDirInDocuments(@"imCache");
}
//不包含扩展名jpg或者png
NSString* GetCacheImageFullPath(NSString* filename)
{
    NSString* imgCacheDir = GetIMCacheDir();
    NSString* jpgPath = [imgCacheDir stringByAppendingPathComponent:filename];
    jpgPath = [jpgPath stringByAppendingString:@".jpg"];
    return jpgPath;
}
//返回保存的文件全路径
NSString* WriteImage(NSString* filename,UIImage* image)
{
    NSString* imgCacheDir = GetIMCacheDir();
    NSString* jpgPath = [imgCacheDir stringByAppendingPathComponent:filename];
    jpgPath = [jpgPath stringByAppendingString:@".jpg"];
    
    [UIImageJPEGRepresentation(image,0.6) writeToFile:jpgPath atomically:YES];
    return jpgPath;
}
void DeleteImageCache(NSString* filename)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* imgCacheDir = GetIMCacheDir();
    
    {
        NSString* pngPath = [imgCacheDir stringByAppendingPathComponent:filename];
        pngPath = [pngPath stringByAppendingString:@".jpg"];
        [fileManager removeItemAtPath:pngPath error:nil];
    }
}

UIImage* LoadImageCache(NSString* filename)
{
    NSString* imgCacheDir = GetIMCacheDir();
    
    //使用jpg加载
    {
        NSString* pngPath = [imgCacheDir stringByAppendingPathComponent:filename];
        pngPath = [pngPath stringByAppendingString:@".jpg"];
        
        BOOL isDir;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:pngPath isDirectory:&isDir];
        if(isExist)
            return [[UIImage alloc]initWithContentsOfFile:pngPath];
    }
    
    //使用png加载
    {
        NSString* pngPath = [imgCacheDir stringByAppendingPathComponent:filename];
        pngPath = [pngPath stringByAppendingString:@".png"];
        
        BOOL isDir;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:pngPath isDirectory:&isDir];
        if(isExist)
            return [[UIImage alloc]initWithContentsOfFile:pngPath];
    }
    return nil;
}

void LayoutButtonVertical(UIButton* button)
{
    if (IsIos7OrAbove())
    {
       
        CGFloat spacing = 6.0;
        
        // lower the text and push it left so it appears centered
        //  below the image
        CGSize imageSize = button.imageView.image.size;
        button.titleEdgeInsets = UIEdgeInsetsMake(
                                                  -75.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        
        // raise the image and push it right so it appears centered
        //  above the text
        CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        button.imageEdgeInsets = UIEdgeInsetsMake(
                                                  - (titleSize.height + spacing)-75, 0.0, 0.0, - titleSize.width);
        

    } else
    {
        // the space between the image and text
        CGFloat spacing = 6.0;
        
        // lower the text and push it left so it appears centered
        //  below the image
        CGSize imageSize = button.imageView.frame.size;
        button.titleEdgeInsets = UIEdgeInsetsMake(
                                                  0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        
        // raise the image and push it right so it appears centered
        //  above the text
        CGSize titleSize = button.titleLabel.frame.size;
        button.imageEdgeInsets = UIEdgeInsetsMake(
                                                  - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    }
}

BOOL IsIpad()
{
    static int devicePad = 0 ;
    
    if(devicePad==0)
    {
        NSString *deviceModel = (NSString*)[UIDevice currentDevice].model;
        
        if ([deviceModel rangeOfString:@"iPad"].location != NSNotFound)  {
            devicePad = 1 ;
        } else {
            devicePad = -1;
        }
    }
 
    return devicePad>0 ;
}
BOOL IsIphone()
{
    return !IsIpad();
}


BOOL isBlankString(NSString* string)
{
    if (string == nil)
    {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    
    return NO;
}
NSMutableArray* ConvertSetToArray(NSSet* set)
{
    NSMutableArray* ary = [NSMutableArray new];
    for (NSObject* obj in set)
    {
        [ary addObject:obj];
    }
    return ary;
}
NSMutableSet* ConvertArrayToSet(NSArray* array)
{
    NSMutableSet* set = [NSMutableSet new];
    for (NSObject* obj in array)
    {
        [set addObject:obj];
    }
    return set;
}


NSString *getChineseMoneyDigits(NSString *numberString)
{
    static NSNumberFormatter *numberFormatter = nil;
    
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        
        [numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
        [numberFormatter setMinimumFractionDigits:2];
        [numberFormatter setMaximumFractionDigits:6];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    }
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[numberString doubleValue]]];
    //通过NSNumberFormatter转换为大写的数字格式 eg:一千二百三十四
    
    //替换大写数字转为金额
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"〇" withString:@"零"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"一" withString:@"壹"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"二" withString:@"贰"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"三" withString:@"叁"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"四" withString:@"肆"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"五" withString:@"伍"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"六" withString:@"陆"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"七" withString:@"柒"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"八" withString:@"捌"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"九" withString:@"玖"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"十" withString:@"拾"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"千" withString:@"仟"];
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"百" withString:@"佰"];
    
    //对小数点后部分单独处理
    if ([formattedNumberString rangeOfString:@"点"].length>0) {
        NSArray* arr = [formattedNumberString componentsSeparatedByString:@"点"];
        NSMutableString* lastStr = [[arr lastObject] mutableCopy];
        
        if (lastStr.length>=2) {
            [lastStr insertString:@"分" atIndex:lastStr.length];
        }
        if (![[lastStr substringWithRange:NSMakeRange(0, 1)]isEqualToString:@"零"]) {
            [lastStr insertString:@"角" atIndex:1];
        }
        
        formattedNumberString = [[arr firstObject] stringByAppendingFormat:@"元%@",lastStr];
        
    }else{
        formattedNumberString = [formattedNumberString stringByAppendingString:@"元整"];
    }
    
    return formattedNumberString;
}

NSString *getChinesDigits(NSInteger intValue)
{
    static NSNumberFormatter *numberFormatter = nil;
    
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        
        [numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
        [numberFormatter setMinimumFractionDigits:2];
        [numberFormatter setMaximumFractionDigits:6];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    }
    
    return [numberFormatter stringFromNumber:@(intValue)];
}

UIImage* LoadImageWithoutCache(NSString* name)
{
    NSString *path;
    @autoreleasepool
    {
        static NSArray* exts ;
        
        if (exts==nil)
        {
            exts = @[
                     @"@3x",
                     @"@2x",
                     @""
                     ];
        }

        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString* filename = getFileNameWithoutExtFromPath(name);
        NSString* type = getExtNameFromPath(name);
        if(!isValidString(type))
            type = @"png";
        

        for (NSString* ext in exts)
        {
            NSString* main = filename;
            
            main = [main stringByAppendingString:ext];
            
            path = [[NSBundle mainBundle] pathForResource:main ofType:type];
            
            if (path!=nil &&
                [fileManager fileExistsAtPath:path])
            {
                break;
            }

        }
        
                
        
    }
    UIImage *img = nil;
    @try {
        img = [UIImage imageWithContentsOfFile:path];
    } @catch (NSException *exception) {
        img = nil;
    } @finally {
        img = (img != nil) ? img: [UIImage imageNamed:name];
    }
    
    return img;
}
UIView *SubviewWithTag(UIView *parentView, NSInteger tag) {
    UIView *theView = nil;
    theView = [parentView viewWithTag:tag];
    
    if (theView)
        return theView;
    
    for (UIView *subview in [parentView subviews]) {
        if (subview.subviews.count > 0) {
            SubviewWithTag(subview, tag);
        }
    }
    
    return nil;
}

void SetAllLabelColor(UIColor* color, UIView* view) {
    if ([view isMemberOfClass:[UILabel class]])
    {
        UILabel * label = (UILabel*)view;
        [label setBackgroundColor:color];
    }
    else if(view.subviews.count > 0)
    {
        for (UIView * subview  in view.subviews) {
            SetAllLabelColor(color, subview);
        }
    }
}

NSString* GetUrlForResource(NSString* resId)
{
    return [[ServerEnvironment instance]urlForResourceId:resId];
}
UIView * quickLoadNib (NSString * nibString)
{
    NSArray * nibs = [[NSBundle mainBundle] loadNibNamed:nibString owner:nil options:nil];
    UIView * likeItemView = nibs[0];
    return likeItemView;
}

// 如果title太长了可能会覆盖返回按钮上的信息, 用UILabel的sizeThatFits确定是不是太长
// 要是太长了就把 NAVIGATION_BAR_TITLE_MAX_LENGTH 像素以外的部分去掉换乘"..."
#define NAVIGATION_BAR_TITLE_MAX_LENGTH (([[UIScreen mainScreen] bounds].size.width) - 150)
NSString * shortenTitleIfNeeded(NSString * longtitle){
    
    static UILabel * label;
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAXFLOAT, MAXFLOAT)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:16.0];
    }
    
    // 先确定title不为空
    if (!longtitle) {
        return @"";
    }
    if (longtitle.length==0) {
        return @"";
    }
    // 再确定需不需要缩短
    label.text = longtitle;
    if ([label sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].width < NAVIGATION_BAR_TITLE_MAX_LENGTH) {
        return longtitle;
    }
    
    // 缩短长名字
    NSMutableString * mtitle = [NSMutableString stringWithString:longtitle];
    NSString * dotdotdot = @"...";

    label.text = dotdotdot;
    float dotWidth = [label sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    
    label.text = mtitle;
    float titleWidth = [label sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;

    // 一个字符一个字符缩短长名字 直到长度小于NAVIGATION_BAR_TITLE_MAX_LENGTH
    while (titleWidth + dotWidth > NAVIGATION_BAR_TITLE_MAX_LENGTH) {
        [mtitle deleteCharactersInRange:(NSRange){mtitle.length-1 , 1}];
        label.text = mtitle;
        titleWidth = [label sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    }
    
    // 后面加个点点点
    [mtitle appendString:dotdotdot];
    return mtitle;
}

NSString* GetNotNilString(NSString* s)
{
    if(s==nil)
        return @"";
    return s;
}

//默认填充图片
UIImage* defaultImage()
{
    static UIImage *defaultImage;
    static dispatch_once_t defaultImageToken;
    dispatch_once(&defaultImageToken, ^{
        defaultImage = [UIImage imageNamed:@"placeholder.png"];
    });
    return defaultImage;
}

UIImage* defaultUserIcon()
{
    static UIImage *defaultUserIcon;
    static dispatch_once_t defaultUserIconToken;
    dispatch_once(&defaultUserIconToken, ^{
        defaultUserIcon = [UIImage imageNamed:@"man100.png"];
    });
    return defaultUserIcon;
}

id GetObjFromArraySafeley(NSArray* ary,NSInteger index)
{
    if (ary) {
        if (index>=0 && index<ary.count)
        {
            return [ary objectAtIndex:index];
        }
    }
    
    return nil;
}

@interface _OverlayView : UIView
{
    UITapGestureRecognizer* _tap;
    UIPanGestureRecognizer* _pan;
}
@property(nonatomic,copy) OverlayViewTap ontapBlock;
@property(nonatomic,weak) UIView* contentView;
@property(nonatomic,strong) UILabel* hintLabel;
@end

@implementation _OverlayView
- (instancetype)init
{
    self = [super init];
    if (self) {
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:_tap];
        
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPan:)];
        [self addGestureRecognizer:_pan];
        
        [_tap requireGestureRecognizerToFail:_pan];
        
        CGRect rcScreen = [[UIScreen mainScreen]bounds];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000,rcScreen.size.width*0.7)];
        [label setFont:[UIFont systemFontOfSize:14]];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 10 ;
        label.text = @"在灰色区域点击完成操作，滑动取消操作" ;
        [label sizeToFit];
        [self addSubview:label];
        self.hintLabel = label;
    }
    return self;
}
-(void)onTap
{
    if (self.ontapBlock)
    {
        self.ontapBlock(self);
    }
}
-(void)onPan:(UIGestureRecognizer*)gesture
{
    if (gesture.state==UIGestureRecognizerStateBegan)
    {
        //cancel
        [self.contentView removeFromSuperview];
        [self removeFromSuperview];
        
        if (!self.hintLabel.hidden)
        {
            [AlertBox showMessage:@"操作已取消" hideAfter:1];
        }
    }
}
@end

UIView* AddFullScreenOverlayView(UIView* subView,BOOL bShowHintLabel,OverlayViewTap ondismiss)
{
    _OverlayView* view=[[_OverlayView alloc]init];
    view.backgroundColor = [UIColor darkGrayColor];
    view.alpha = 0.9 ;
    view.ontapBlock = ondismiss ;
    view.contentView = subView ;
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    screenRect.origin.y = 0;
    view.frame = screenRect ;
    CGRect rcLabel = view.hintLabel.frame ;
    rcLabel.origin.x = (CGRectGetMaxX(screenRect)-rcLabel.size.width)/2;
    rcLabel.origin.y = screenRect.size.height - subView.frame.size.height-40;
    view.hintLabel.frame = rcLabel;
    view.hintLabel.hidden = !bShowHintLabel;
    
    UIWindow* window = [[UIApplication sharedApplication]keyWindow] ;
    [window addSubview:view];
    [window addSubview:subView];
    return view;
}

//将控件居中对齐
void AlignViewCenter(UIView* v,BOOL bXCenter,BOOL bYCenter)
{
    CGSize szParent = v.superview.frame.size ;
    CGRect rc = v.frame ;
    
    if( bXCenter )
    {
        rc.origin.x = (szParent.width-rc.size.width)*0.5;
    }
    if (bYCenter)
    {
        rc.origin.y = (szParent.height-rc.size.height)*0.5;
    }
    v.frame = rc ;
}
void ShowViewOnWindowCenter(UIView* view)
{
    UIView* bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    bg.backgroundColor = BuildUIColor(50, 50, 50, 120);
    [bg addSubview:view];
    AlignViewCenter(view, YES, YES);
    
    [[UIApplication sharedApplication].keyWindow addSubview:bg];
}
void CloseViewOnWindow(UIView* view)
{
    [[view superview]removeFromSuperview];
    [view removeFromSuperview];
}

//拼接api和参数
NSString * UrlWithParameter(NSString * api , NSDictionary * parameters) {
    NSMutableString * resultUrl = [NSMutableString stringWithFormat:@"%@?" , api];
    for (NSString * key in parameters) {
        NSString * val = parameters[key];
        if ([key isKindOfClass:[NSString class]]
            && [val isKindOfClass:[NSString class]]) {
            [resultUrl appendFormat:@"%@=%@&" , key , val];
        }
        else {
            NSLog(@"unrecognized type of key value pair %@ %@" , key , val);
        }
    }
    
    // trim last '&'
    if ([resultUrl characterAtIndex:resultUrl.length-1]=='&') {
        return [resultUrl substringToIndex:resultUrl.length-1];
    }
    return resultUrl;
}


void _enableBtn(UIView* view)
{
    for(id subview in [view subviews])
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            [subview setEnabled:YES];
        }else
        {
            _enableBtn(subview);
        }
    }
}
void EnableSearchbarCancelBtn(UISearchBar* bar)
{
    _enableBtn(bar);
}

UIViewController* GetVCFromAnyView(UIView* view)
{
    id object = [view nextResponder];
    
    while (![object isKindOfClass:[UIViewController class]] &&
           
           object != nil) {
        
        object = [object nextResponder];
        
    }
    
    
    
    UIViewController *uc=(UIViewController*)object;
    return uc;
}
void OutputSubViews(UIView* view,int level)
{
    if(level==0)
    {
        NSLog(@"======= current view ========");
        NSLog(@"%@",view);
    }
    
    NSString* s = @"%@";
    for (int i=0;i<level; i++)
    {
        s = [@"  " stringByAppendingString:s];
    }
    
    for (UIView* sub in view.subviews)
    {
        NSLog(s,sub);
        
        OutputSubViews(sub, level+1);
    }
}

//统计目录的存储空间大小
float checkTmpDirectorySize(NSString *dirPath)
{
    float totalSize = 0;
    NSString *path = nil;
    if (isValidString(dirPath)) {
        path = dirPath.copy;
    } else {
        //获取Cache路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        path = [paths objectAtIndex:0];

    }
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath: path];
    
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath  = [path stringByAppendingPathComponent: fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath: filePath error: nil];
        unsigned long long length = [attrs fileSize];
        
        if([[[fileName componentsSeparatedByString: @"/"] objectAtIndex: 0] isEqualToString: @"URLCACHE"])
            continue;
        
        totalSize += length / 1024.0 / 1024.0;
    }
    return  totalSize;
}


@implementation NSObject (WBGCheckStuff)

+ (BOOL)wbg_isKind:(id)stuff {
    if (!stuff) { return NO; }
    return [stuff isKindOfClass:self];
}
+ (BOOL)wbg_areKind:(id)array {
    if (![NSArray wbg_isKind:array]) { return NO; }
    for (id stuff in array) {
        if (![self wbg_isKind:stuff]) { return NO; }
    }
    return YES;
}
+ (BOOL)wbg_isValid:(id)stuff {
    return [self wbg_isKind:stuff];
}
+ (BOOL)wbg_areValid:(id)array {
    if (![NSArray wbg_isValid:array]) { return NO; }
    for (id stuff in array) {
        if (![self wbg_isValid:stuff]) { return NO; }
    }
    return YES;
}

@end

@implementation NSString (WBGCheckStuff)
+ (BOOL)wbg_isValid:(id)stuff {
    return isValidString(stuff);
}
@end
