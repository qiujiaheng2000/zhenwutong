//
//  ZWTScoreViewController.m
//  zhengwutong
//  查成绩界面
//  Created by qiujiaheng on 16/5/29.
//  Copyright © 2016年 leqimin. All rights reserved.
//

#import "ZWTScoreViewController.h"
#import "NIDropDown.h"

@interface ZWTScoreViewController ()
@property (weak, nonatomic) IBOutlet UIButton *lessonsButton;

- (IBAction)dropDown:(id)sender;

//下拉列表数据
@property (strong, nonatomic) NSArray *dropDownData;
@end

@implementation ZWTScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDropDownData];
}

- (void)initDropDownData {
    _dropDownData  = [NSArray arrayWithObjects:@"邓小平理论",@"毛泽东概论",@"社会科学",@"高等数学",@"专业英语", nil];
    [self.lessonsButton setTitle:[_dropDownData objectAtIndex:0] forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
 *点击课程dropDown
 */
- (IBAction)dropDown:(id)sender {
    if(dropDown == nil){
        CGFloat f = 200;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :self.dropDownData :[[NSArray alloc]init] :@"down"];
        dropDown.delegate = self;
    }else{
        [dropDown hideDropDown:sender];
        [self rel];
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    [self rel];
    NSLog(@"%@", self.lessonsButton.titleLabel.text);
}

-(void)rel{
    //    [dropDown release];
    dropDown = nil;
}

@end
