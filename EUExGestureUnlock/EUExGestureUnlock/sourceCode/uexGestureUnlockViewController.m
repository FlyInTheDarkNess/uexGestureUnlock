/**
 *
 *	@file   	: uexGestureUnlockViewController.m  in EUExGestureUnlock Project
 *
 *	@author 	: CeriNo
 *
 *	@date   	: Created on 15/11/20
 *
 *	@copyright 	: 2015 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "uexGestureUnlockViewController.h"

static CGFloat kMinimumExecutionInteval=0.5f; //2次密码验证之间的最短间隔


@interface uexGestureUnlockViewController ()
@property(nonatomic,strong)uexGestureUnlockVerifyingCodeResultBlock verifyResultBlock;
@property(nonatomic,strong)uexGestureUnlockSettingCodeProgressBlock progressBlock;
@end

@implementation uexGestureUnlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithConfiguration:(uexGestureUnlockConfiguration *)config
                             progress:(uexGestureUnlockSettingCodeProgressBlock)callback
{
    self = [super init];
    if (self) {
        self.config=config;
        self.mode=uexGestureUnlockModeSettingInitialInput;
    }
    return self;
}
- (instancetype)initWithWithConfiguration:(uexGestureUnlockConfiguration *)config
                                   result:(uexGestureUnlockVerifyingCodeResultBlock)callback
{
    self = [super init];
    if (self) {
        self.config=config;
        self.mode=uexGestureUnlockModeVerifying;
    }
    return self;
}

-(void)setConfig:(uexGestureUnlockConfiguration *)config{
    if(!config){
        _config=[uexGestureUnlockConfiguration defaultConfiguration];
    }else{
        _config=config;
    }
}
-(RACSubject *)touchStartStream{
    if(!_touchStartStream){
        _touchStartStream=[RACSubject subject];
    }
    return _touchStartStream;
}

-(RACCommand *)verifyResultCommand{
    if(!_verifyResultCommand){
        _verifyResultCommand=[[RACCommand alloc]
                              initWithSignalBlock:^RACSignal *(NSArray <NSNumber *> *input)
        {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:@([self checkIfCodeValid:input])];
                [[RACScheduler scheduler] afterDelay:kMinimumExecutionInteval schedule:^{
                    [subscriber sendCompleted];
                }];
                return nil;
            }];
        }];
        
    }
    return _verifyResultCommand;
}


-(BOOL)checkIfCodeValid:(NSArray <NSNumber *> *)input{
    NSMutableString *code=[NSMutableString string];
    for(int i=0;i<[input count];i++){
        [code appendString:[input[i] stringValue]];
    }
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UserDefaults
+(NSString *)getGestureCode{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUexGestureUnlockConfigurationSaveGestureCodeKey];
}
+(void)saveGestureCode:(NSString *)code{
    [[NSUserDefaults standardUserDefaults] setValue:code forKey:kUexGestureUnlockConfigurationSaveGestureCodeKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(void)removeGestureCode{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kUexGestureUnlockConfigurationSaveGestureCodeKey];
}

#pragma mark - public method

+(BOOL)isGestureCodeSet{
    NSString *gestureCode=[self getGestureCode];
    if(!gestureCode ||[gestureCode length]==0){
        return NO;
    }else{
        return YES;
    }
}




@end
