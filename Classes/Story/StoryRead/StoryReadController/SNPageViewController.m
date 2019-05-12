//
//  SNPageViewController.m
//  sohunews
//
//  Created by chuanwenwang on 2017/3/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPageViewController.h"

@interface SNPageViewController ()

@end

@implementation SNPageViewController

//-(void)setViewControllers:(NSArray<UIViewController *> *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completion
//{
//    if (animated) {
//        [super setViewControllers:viewControllers direction:direction animated:animated completion:^(BOOL finished){
//            
//            if (finished) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [super setViewControllers:viewControllers direction:direction animated:NO completion:completion];
//                });
//            } else {
//                if (completion != NULL) {
//                    completion(finished);
//                }
//            }
//        }];
//    } else {
//        
//        [super setViewControllers:viewControllers direction:direction animated:animated completion:completion];
//        return;
//    }
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end
