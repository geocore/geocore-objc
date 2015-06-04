//
//  SplashViewController.m
//  ObjectiveGeocoreDemo
//
//  Created by Purbo Mohamad on 6/4/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"
#import <PromiseKit/PromiseKit.h>
#import <ObjectiveGeocore/Geocore.h>

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Geocore instance] loginWithUserId:@"#your_username"
                               password:@"#your_password"]
        .then(^(MMGUser *user) {
            NSLog(@"Logged in, user's name: %@", user.name);
            [self openMainScreen];
        })
        .catch(^(NSError *error) {
            NSLog(@"Error logging in: %@", error);
        });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openMainScreen {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarViewController"];
    [UIView transitionWithView:app.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^(void) {
                        app.window.rootViewController = vc;
                    } completion:^(BOOL finished) {
                    }];
}

//

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
