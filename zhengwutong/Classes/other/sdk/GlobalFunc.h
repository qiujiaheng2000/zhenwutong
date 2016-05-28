//
//  GlobalFunc.h
//  Trader
//
//  Created by zhenglibao on 14-9-30.
//
//

#import <Foundation/Foundation.h>
#import "YXClient.h"

#define NO_DUPPLICATE_CALL(seconds)     \
    {                                   \
        static double _tmLastCall = 0 ; \
        if( fabs(GetAccurateSecondsSince1970()-_tmLastCall)<seconds) \
            return;                     \
        _tmLastCall = GetAccurateSecondsSince1970(); \
    }                                   \


// Return nil when __INDEX__ is beyond the bounds of the array
#define NSArrayObjectMaybeNil(__ARRAY__, __INDEX__) ((__INDEX__ >= [__ARRAY__ count]) ? nil : [__ARRAY__ objectAtIndex:__INDEX__])

// Manually expand an array into an argument list//把一个数组分解成一个队列，在遇到函数参数可变的时候使用
#define NSArrayToVariableArgumentsList(__ARRAYNAME__)\
NSArrayObjectMaybeNil(__ARRAYNAME__, 0),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 1),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 2),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 3),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 4),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 5),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 6),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 7),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 8),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 9),\
nil

// 安全的crash, 在虚拟机上通知开发者, 在真机上调试时候不要crash
// 数据有错的时候可以用
void CrashOnSimulator(NSString *errorMsg);

# pragma mark - Easy Macros
#define IOS7OrAbove if(IsIos7OrAbove())
#define IOS8OrAbove if(IsIos8OrAbove())


@class TKAddressBookUser;
@class OAWorkCopyableLabel;
typedef void(^VoidBlock)();
typedef void(^BoolBlock)(BOOL boolStuff);
typedef void (^OperationFinish)(BOOL bSuccess);
typedef void (^ProgressBlock)(float fProgress,float fUploadSpeed);
typedef void (^OverlayViewTap)(UIView* overlayView);

BOOL isNetworkEnabled();
//删除字符串里面的成对<em></em>
NSString * removeEMTag(NSString* string);

void checkHighLight(NSString *string,OAWorkCopyableLabel *label);

//判断字符串是否是空白字符串
BOOL isBlankString(NSString* string);

// http请求
typedef void (^SuccessBlock)(NSDictionary* dic,NSString* errorMsg,NSString* sStatus);

void AlertIfRequestErrorWithString(NSString* error);

// 界面相关
UINavigationController* InitCustomNaviController(UIViewController* rootVC);


//获取最顶层controller
UIViewController* getTopMostController();

//获取最近的controller
UIViewController* getNearestViewController(UIView *view);

void AppPresentViewController(UIViewController* controller);
void AppPresentViewControllerAnimation(UIViewController* controller,BOOL animation);
void AppPresentViewControllerFromBottom(UIViewController* controller);
void AppPresentViewControllerFromBottomAnimation(UIViewController* controller,BOOL animated);
void AppDismissViewController(BOOL bAnimated);
void AppDismissAllViewController(BOOL bAnimated);
void AppUpdateTopNaviBar();
void AppSetBadge(NSUInteger index,NSString* badgeString);
void AppSetApplicationBadge(int badgeNumber);
void AppPopPushVC(UINavigationController* nav,UIViewController* vcToPush);

//注册系统广播，系统NSNotificationCenter的等效调用
void AppRegistSystemNotify(NSString* notifyName,id obj,SEL sel);
void AppUnRegistSystemNotify(NSString* notifyName,id obj);
void AppPostSystemNotify(NSString* notifyName);

NSString* GetSubDirInDocuments(NSString* subDir);

// 图片缓存
NSString* GetIMCacheDir();
NSString* GetCacheImageFullPath(NSString* filename);
NSString* WriteImage(NSString* filename,UIImage* image);
void DeleteImageCache(NSString* filename);
UIImage* LoadImageCache(NSString* filename);
BOOL isIPhone5();
BOOL isShortThanIphone5();
BOOL IsIos7OrAbove();
BOOL IsIos8OrAbove();
float GetIosVersion();
BOOL IsIosVersionOrAbove(float version);
BOOL checkCemare();
void checkNetWorkEnable();

void UpdateStatusBarColor();

//返回从上次调用起经过的时间差
double GetTimeSinceLastCall();
//获取自1970-1-1到现在的精确秒数，精确到微秒
double GetAccurateSecondsSince1970();

//获得时间展示
NSString * getDateStr(NSDate *date);

//显示/关闭菊花
void ShowBusyIndicator();
void HideBusyIndicator();
void HideBusyUnLockRigthBarItemForView(UIView *forView);
void ShowBusyTextIndicatorBlockRigtBarItemForView(UIView *forView, NSString *indicatorText);
// both parameter may be null
void ShowBusyTextIndicatorForView(UIView* forView,NSString* indicatorText);
void HideBusyIndicatorForView(UIView* forView);
void HideBusyIndicatorAnimated(BOOL animated);

// 加载tableViewCell
UITableViewCell* LoadTableCell(NSString* name);

//从字典中按照路径直接取值
id GetObjectFromDictionary(NSDictionary* dict,NSString* path,id defaultValue);
NSString* GetStringFromDictionary(NSDictionary* dict,NSString* path);
NSArray* GetArrayFromDictionary(NSDictionary* dict,NSString* path);
NSDictionary* GetDictionaryFromDictionary(NSDictionary* dict,NSString* path);
NSInteger GetIntegerFromDictionary(NSDictionary* dict,NSString* path, NSInteger defaultValue);
double GetDoubleFromDictionary(NSDictionary *dict, NSString *path, double defaultValue);

NSString* AppendMoneyChar(NSString* number);


UIColor* BuildUIColor(int r,int g,int b,int alpha);
UIColor* BuildUIColorWithHexString(NSString *hex);

//转换1~10的数字为汉字
const NSString* ConvertNumToChinese(int n);

//格式化金额
NSString* FormatMoney(double f);
NSString* FormatCurrency(double f);// 有逗号

//将阿拉伯数字字符串转换为大写金额格式
NSString *getChineseMoneyDigits(NSString *numberString);
//将整数转换为中文字符
NSString *getChinesDigits(NSInteger intValue);

// 压缩图片
typedef void (^onImageFinish)(UIImage* smallImage);
void CompressImageAsync(UIImage* originalImage,onImageFinish onOKEvent);
void CompressImageSync(UIImage* originalImage,onImageFinish onOKEvent);


UITableView* GetTableViewFromCell(UIView* view);

NSArray* ReverseArray(NSArray* ary);

BOOL isScrollAtEnd(UIScrollView* scrollView);
BOOL isScrollAtBegin(UIScrollView* scrollView);
BOOL isTableAtEnd(UITableView* scrollView);
BOOL isTableAtBegin(UITableView* scrollView);

NSString* FormatBadge(NSString* badge);

BOOL isValidDictionary(id obj);
BOOL isValidArray(id obj);
BOOL isValidString(id obj);
BOOL isNonEmptyArray(NSArray *array);

//错误日志打印
void errorLog(NSString* errorMsg);

//
NSArray* Build24Hour();
NSArray* Build5Min();

//附件文件
NSString * GetSizeString(NSInteger size);
NSString * GetFileCachePath();
BOOL is3G2GNetWork();
BOOL isFileExist(NSString* filePath);
long long GetFileSize(NSString* filePath);
//
BOOL CheckPasswordValid(NSString* password);
BOOL isValidPhoneNumber(NSString* phoneNumber);

BOOL ShowWarningIfExceedLength(NSString* content,NSString* prompt);

void KillScroll(UIScrollView* scrollView);

//设置view的大小，然后自动调整右侧和下侧的其他view的位置
void AdjustViewWithAfterRects(UIView* view,CGRect rc);
//调整左侧和上侧的
void AdjustViewWithPrevRects(UIView* view,CGSize newSize);

// plist

void storeUserIntValueForKey(NSString* key,int value);
int getUserIntValueForKey(NSString* key,int defaultValue);

void storeGlobalValueForKey(NSString* key,NSString* value);
NSString* getGlobalValueForKey(NSString* key,NSString* defaultValue);

//
NSString* getFileNameFromPath(NSString* path);
NSString* getFileNameWithoutExtFromPath(NSString* path);
NSString* getMIMETypeWithFilePath(NSString *filePath);
NSString* getExtNameFromPath(NSString* path);
NSString* getOriginalImageUrl(NSString* imgUrl);
NSString* getLastPartFromPath(NSString* path);
BOOL IsOriginalImage(NSString* imgUrl);

UIView* getFocusOfView(UIView* parentView);

void LayoutButtonVertical(UIButton* button);

BOOL IsIpad();
BOOL IsIphone();


// 数组和集合相互转换
NSMutableArray* ConvertSetToArray(NSSet* set);
NSMutableSet* ConvertArrayToSet(NSArray* array);


//从程序的library、程序自身目录加载图像，不同于imageNamed会缓存图像，该方法会自动释放图像
UIImage* LoadImageWithoutCache(NSString* name);


UIView *SubviewWithTag(UIView *parentView, NSInteger tag);

//获取资源的url
NSString* GetUrlForResource(NSString* resId);
UIView * quickLoadNib (NSString * nibString);

// 缩短太长的字符串 用来放在navigationBar.title里
NSString * shortenTitleIfNeeded(NSString * longtitle);

NSString* GetNotNilString(NSString* s);

//默认填充图片
UIImage* defaultImage();

//默认填充头像
UIImage* defaultUserIcon();


id GetObjFromArraySafeley(NSArray* ary,NSInteger index);

UIView* AddFullScreenOverlayView(UIView* subView,BOOL bShowHintLabel,VoidBlock ondismiss);

void AlignViewCenter(UIView* v,BOOL bXCenter,BOOL bYCenter);

void ShowViewOnWindowCenter(UIView* view);
void CloseViewOnWindow(UIView* view);

//拼接api和参数
NSString * UrlWithParameter(NSString * api , NSDictionary * parameters);

//
void EnableSearchbarCancelBtn(UISearchBar* bar);

//从view获取Controller
UIViewController* GetVCFromAnyView(UIView* view);

//输出所有view
void OutputSubViews(UIView* view,int level);

//统计摸个目录的存储空间大小
float checkTmpDirectorySize(NSString *path);


// WBGCheckStuff: 检查一个东西是不是一个类, isKindOfClass...的语法糖
// isKind / areKind - 检查是不是一个类
// isValid / areValid - 检查更具体的东西 每一个类都会有自己的实现, 要是没有实现就还是走isKind
// usage:
// if ([NSDictionary wbg_isKind:maybeDictionary])
//      NSDictionary * dict = (NSDictionary *)maybeDictionary;
//
// if ([NSDictionary wbg_areKind:manyDictionaries]) {
//      for dict in manyDictionaries {
//          ...
//
@interface NSObject (WBGCheckStuff)
+ (BOOL)wbg_isKind:(id)stuff;
+ (BOOL)wbg_areKind:(id)array;
+ (BOOL)wbg_isValid:(id)stuff;
+ (BOOL)wbg_areValid:(id)array;
@end

// 把一个uiimage的所有有颜色的地方都变成tint color
#define TINT_IMAGE(image) (IsIos7OrAbove() ? [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : image)



#define USE_CONTACT_DOC

