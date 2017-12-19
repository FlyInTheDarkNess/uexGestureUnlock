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
#import "uexGestureUnlockShakeLabel.h"
#import "uexGestureUnlockTouchView.h"
#import "uexGestureUnlockInfoView.h"
#import "uexGestureUnlockError.h"
#import <Masonry/Masonry.h>
//const
#define UEXGU_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define UEXGU_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
static CGFloat kUexGestureUnlockMinimumExecutionInteval=0.5f; //2次密码验证之间的最短间隔
static CGFloat kUexGestureUnlockTouchViewMargin=30;//TouchView距离左右屏幕边框的距离
static CGFloat kUexGestureUnlockPromptLabelMargin=20;//PromptLabel的上下间距
static CGFloat kUexGestureUnlockPromptLabelFontSize=18;//PromptLabel的字体大小
static CGFloat kUexGestureUnlockActionButtonFontSize=14;//ActionButton的字体大小


typedef NS_ENUM(NSInteger,uexGestureUnlockCodeValidSignalType) {
    uexGestureUnlockCodeVerificationSignal,
    uexGestureUnlockCodeLengthCheckSignal,
    uexGestureUnlockCodeEqualCheckSignal
};




@interface uexGestureUnlockViewController ()<UIAlertViewDelegate>


@property (nonatomic,strong)uexGestureUnlockProgressBlock progressBlock;
@property (nonatomic,strong)uexGestureUnlockCompletionBlock completionBlock;


//UI
@property (nonatomic,strong)uexGestureUnlockTouchView *touchView;
@property (nonatomic,strong)uexGestureUnlockShakeLabel *promptLabel;
@property (nonatomic,strong)UIButton *leftActionButton;
@property (nonatomic,strong)UIButton *rightActionButton;
@property (nonatomic,strong)uexGestureUnlockInfoView *infoView;
@property (nonatomic,strong)UIImageView *iconView;

//
@property (nonatomic,strong)RACDisposable *currentExecution;
@property (nonatomic,strong)RACSubject *eventStream;
@property (nonatomic,strong)__block NSString *inputCode;
@property (nonatomic,assign)__block NSInteger trialTimes;
@property (nonatomic,assign)uexGestureUnlockCodeValidSignalType signalType;
@end

@implementation uexGestureUnlockViewController

- (instancetype)initWithConfiguration:(uexGestureUnlockConfiguration *)config
                                 mode:(uexGestureUnlockMode)mode
                             progress:(uexGestureUnlockProgressBlock)progressBlock
                           completion:(uexGestureUnlockCompletionBlock)completionBlock{
    self = [super init];
    if (self) {
        self.config = config;
        self.mode = mode;
        self.progressBlock = progressBlock;
        self.completionBlock = completionBlock;
    }
    return self;
}




- (void)loadView{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UEXGU_SCREEN_WIDTH, UEXGU_SCREEN_HEIGHT)];
    imageView.backgroundColor = self.config.backgroundColor;
    if(self.config.backgroundImage){
        [imageView setImage:self.config.backgroundImage];
    }
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.userInteractionEnabled = YES;
    self.view = imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTouchView];
    [self setupLeftActionButton];
    [self setupRightActionButton];
    [self setupPromptLabel];
    [self setupEventStream];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [self.eventStream sendNext:@(uexGestureUnlockInitialized)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sutup;
- (void)setupTouchView{
    CGFloat touchViewSideLength = UEXGU_SCREEN_WIDTH-2*kUexGestureUnlockTouchViewMargin;
    self.touchView = [[uexGestureUnlockTouchView alloc] initWithSideLength:touchViewSideLength];
    [self.touchView combineWithViewController:self];
    [self.view addSubview:self.touchView];
    @weakify(self);
    [self.touchView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.width.equalTo(@(touchViewSideLength));
        make.height.equalTo(@(touchViewSideLength));
        make.left.equalTo(self.view.mas_left).with.offset(kUexGestureUnlockTouchViewMargin);
        make.top.equalTo(self.view.mas_top).with.offset(0.3*UEXGU_SCREEN_HEIGHT);
    }];

}

- (void)setupLeftActionButton{
    self.leftActionButton = [self defaultActionButton];
    [self.view addSubview:self.leftActionButton];
    @weakify(self);
    [self.leftActionButton mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
        make.left.equalTo(self.view.mas_left).with.offset(kUexGestureUnlockTouchViewMargin);
    }];
}
- (void)setupRightActionButton{
    [self.view addSubview:self.rightActionButton];
    @weakify(self);
    [self.rightActionButton mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
        make.right.equalTo(self.view.mas_right).with.offset(-kUexGestureUnlockTouchViewMargin);
    }];
}


- (void)setupPromptLabel{
    uexGestureUnlockShakeLabel *promptLabel = [[uexGestureUnlockShakeLabel alloc] init];
    [promptLabel combineWithViewController:self];
    promptLabel.font = [UIFont systemFontOfSize:kUexGestureUnlockPromptLabelFontSize];
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.numberOfLines = 1;
    self.promptLabel = promptLabel;
    [self.view addSubview:self.promptLabel];
    @weakify(self);
    [self.promptLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.bottom.equalTo(self.touchView.mas_top);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (void)setupInfoView{
    CGFloat sideLength = 50;
    uexGestureUnlockInfoView *infoView = [[uexGestureUnlockInfoView alloc]initWithSideLength:sideLength];
    [infoView combineWithViewController:self];
    self.infoView = infoView;
    [self.view addSubview:self.infoView];
    @weakify(self);
    [self.infoView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.promptLabel.mas_top).with.offset(-kUexGestureUnlockPromptLabelMargin);
        make.height.equalTo(@(sideLength));
        make.width.equalTo(@(sideLength));
    }];
}
- (void)setupIconView{
    UIImageView *icon = [[UIImageView alloc]init];
    icon.backgroundColor = [UIColor clearColor];
    icon.userInteractionEnabled = YES;
    CGFloat radius = UEXGU_SCREEN_WIDTH*0.15;
    icon.layer.masksToBounds = YES;
    icon.layer.cornerRadius = radius;
    if(self.config.iconImage){
        [icon setImage:self.config.iconImage];
        icon.contentMode = UIViewContentModeScaleToFill;
    }
    self.iconView = icon;
    [self.view addSubview:self.iconView];
    @weakify(self);
    [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.promptLabel.mas_top).with.offset(-kUexGestureUnlockPromptLabelMargin);
        make.height.equalTo(@(radius*2));
        make.width.equalTo(@(radius*2));
    }];
}

- (void)setupEventStream{
    RACSubject *eventStream = [RACSubject subject];
    self.eventStream = eventStream;
    @weakify(self);
    [self.eventStream subscribeNext:^(NSNumber *eventNumber) {
        @strongify(self);
        uexGestureUnlockEvent event = (uexGestureUnlockEvent)[eventNumber integerValue];
        if(self.progressBlock){
            self.progressBlock(event);
        }
        switch (event) {
            case uexGestureUnlockInitialized: {
                switch (self.mode) {
                    case uexGestureUnlockModeCreateCode: {

                        [self.eventStream sendNext:@(uexGestureUnlockCodeCreationBegin)];
                        break;
                    }
                    case uexGestureUnlockModeVerifyCode:
                    case uexGestureUnlockModeVerifyThenCreateCode: {
                        [self.eventStream sendNext:@(uexGestureUnlockCodeVerificationBegin)];
                        break;
                    }

                }
                break;
            }
            case uexGestureUnlockCodeVerificationBegin: {
                self.prompt = self.config.verificationBeginPrompt;
                self.signalType = uexGestureUnlockCodeVerificationSignal;
                [self startCodeVerification];
                break;
            }
            case uexGestureUnlockCodeVerificationFailed: {
                self.prompt = self.config.verificationErrorPrompt;
                if(self.config.maximumAllowTrialTimes == 0){
                    self.prompt = self.config.verificationErrorPrompt;
                }else if(self.trialTimes < self.config.maximumAllowTrialTimes){
                    self.prompt = [NSString stringWithFormat:self.config.verificationErrorPrompt,(int)(self.config.maximumAllowTrialTimes-self.trialTimes)];
                    
                }else{
                    self.prompt = @" ";
                    [self.eventStream sendError:[uexGestureUnlockError maxTrialTimesExceededError]];
                }

                break;
            }
            case uexGestureUnlockCodeVerificationCancelled: {
                self.prompt = @" ";
                [self.eventStream sendError:[uexGestureUnlockError verificationCancelledError]];
                break;
            }
            case uexGestureUnlockCodeVerificationSucceed: {
                self.prompt = self.config.verificationSucceedPrompt;
                switch (self.mode) {
                    case uexGestureUnlockModeVerifyCode: {
                        [self.eventStream sendCompleted];
                        break;
                    }
                    case uexGestureUnlockModeVerifyThenCreateCode: {
                        [self.eventStream sendNext:@(uexGestureUnlockCodeCreationBegin)];
                        break;
                    }
                    default: {
                        [self.eventStream sendError:[uexGestureUnlockError unknownAccidentHappenedError]];
                        break;
                    }
                }
                break;
            }
            case uexGestureUnlockCodeCreationBegin: {
                self.prompt = self.config.creationBeginPrompt;
                self.signalType = uexGestureUnlockCodeLengthCheckSignal;
                [self startCodeCreation];
                break;
            }
            case uexGestureUnlockCodeCreationInputInvalid: {
                self.prompt = [NSString stringWithFormat:self.config.codeLengthErrorPrompt,(int)self.config.minimumCodeLength];
                break;
            }
            case uexGestureUnlockCodeCreationCheckInput: {
                self.prompt = self.config.codeCheckPrompt;
                self.signalType = uexGestureUnlockCodeEqualCheckSignal;
                [self startCodeChecking];
                break;
            }
            case uexGestureUnlockCodeCreationCheckFailed: {
                self.prompt = self.config.checkErrorPrompt;
                break;
            }
            case uexGestureUnlockCodeCreationCompleted: {
                self.prompt = self.config.creationSucceedPrompt;
                [self.class saveGestureCode:self.inputCode];
                [self.eventStream sendCompleted];
                break;
            }
            case uexGestureUnlockCodeCreationCancelled: {
                [self.eventStream sendError:[uexGestureUnlockError creationCancelledError]];
                break;
            }

        }
    } error:^(NSError *error) {
        @strongify(self);
        if(self.completionBlock){
            self.completionBlock(NO,error);
        }
    } completed:^{
        @strongify(self);
        if(self.completionBlock){
            [[RACScheduler mainThreadScheduler] afterDelay:self.config.successRemainInterval schedule:^{
                self.completionBlock(YES,nil);
            }];
    
        }
    }];
}


#pragma mark - Override Setters/Getters


- (RACSubject *)touchStartStream{
    if(!_touchStartStream){
        _touchStartStream = [RACSubject subject];
        [_touchStartStream subscribeNext:^(id x) {
            switch (self.signalType) {
                case uexGestureUnlockCodeVerificationSignal: {
                    self.prompt = self.config.verificationBeginPrompt;
                    break;
                }
                case uexGestureUnlockCodeLengthCheckSignal: {
                    self.prompt = self.config.creationBeginPrompt;
                    break;
                }
                case uexGestureUnlockCodeEqualCheckSignal: {
                    self.prompt=self.config.codeCheckPrompt;
                    break;
                }
            }
        }];
    }
    return _touchStartStream;
}
- (UIButton *)leftActionButton{
    if(!_leftActionButton){
        _leftActionButton = [self defaultActionButton];
    }
    return _leftActionButton;
}
- (UIButton *)rightActionButton{
    if(!_rightActionButton){
        _rightActionButton = [self defaultActionButton];
    }
    return _rightActionButton;
}

- (RACCommand *)verifyResultCommand{
    if(!_verifyResultCommand){
        _verifyResultCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSArray<NSNumber *> *input) {
            return [self ifCodeValidSignal:input];
        }];
    }
    return _verifyResultCommand;
}
#pragma mark - Action Button Factory
- (UIButton *)defaultActionButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:self.config.normalThemeColor forState:UIControlStateNormal];
    [button setTitleColor:self.config.selectedThemeColor forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:kUexGestureUnlockActionButtonFontSize];
    button.titleLabel.numberOfLines = 1;
    button.backgroundColor = [UIColor clearColor];
    button.hidden = YES;
    return button;
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
+ (NSString *)getGestureCode{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUexGestureUnlockConfigurationSaveGestureCodeKey];
}
+ (void)saveGestureCode:(NSString *)code{
    [[NSUserDefaults standardUserDefaults] setValue:code forKey:kUexGestureUnlockConfigurationSaveGestureCodeKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+ (void)removeGestureCode{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kUexGestureUnlockConfigurationSaveGestureCodeKey];
}


#pragma mark - Processers

- (void)startCodeVerification{
    [self clear];
    [self setupIconView];
    if(![self.class isGestureCodeSet]){
        [self.eventStream sendError:[uexGestureUnlockError codeNotSetError]];
    }
    @weakify(self);
    self.currentExecution = [self.verifyResultCommand.executionSignals subscribeNext:^(RACSignal *execution) {
        [execution subscribeNext:^(id x) {
            @strongify(self);
            BOOL verifyResult = [x boolValue];
            if(verifyResult){
                //验证成功
                [self.eventStream sendNext:@(uexGestureUnlockCodeVerificationSucceed)];
            }else{
                //验证失败
                self.trialTimes++;
                [self.eventStream sendNext:@(uexGestureUnlockCodeVerificationFailed)];
            }
        }];
    }];
    [self.rightActionButton setTitle:self.config.cancelVerificationButtonTitle forState:UIControlStateNormal];
    [[self.rightActionButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (_promptStr != nil && [_promptStr length] > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:_promptStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"忘记手势密码需重新登录设置！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }];
    
    if (self.config.cancelVerificationButtonTitle != nil && [self.config.cancelVerificationButtonTitle length] > 0) {
        self.rightActionButton.hidden = NO;
    }
    else{
        self.rightActionButton.hidden = YES;
    }
}



- (void)startCodeCreation{
    [self clear];
    [self setupInfoView];
    @weakify(self);
    self.currentExecution = [self.verifyResultCommand.executionSignals subscribeNext:^(RACSignal *execution) {
        [execution subscribeNext:^(id x) {
            @strongify(self);
            BOOL verifyResult = [x boolValue];
             if(verifyResult){
                 [self.eventStream sendNext:@(uexGestureUnlockCodeCreationCheckInput)];
             }else{
                 [self.eventStream sendNext:@(uexGestureUnlockCodeCreationInputInvalid)];
             }
            
        }];
    }];
    [self.rightActionButton setTitle:self.config.cancelCreationButtonTitle forState:UIControlStateNormal];
    [[self.rightActionButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.eventStream sendNext:@(uexGestureUnlockCodeCreationCancelled)];
    }];
    self.rightActionButton.hidden = NO;
}

- (void)startCodeChecking{
    if(self.currentExecution){
        [self.currentExecution dispose];
        self.currentExecution = nil;
    }
    @weakify(self);
    self.currentExecution = [self.verifyResultCommand.executionSignals subscribeNext:^(RACSignal *execution) {
        [execution subscribeNext:^(id x) {
            @strongify(self);
            BOOL verifyResult = [x boolValue];
            if(verifyResult){
                [self.eventStream sendNext:@(uexGestureUnlockCodeCreationCompleted)];
            }else{
                [self.eventStream sendNext:@(uexGestureUnlockCodeCreationCheckFailed)];
            }
            
        }];
    }];
    [self.leftActionButton setTitle:self.config.restartCreationButtonTitle forState:UIControlStateNormal];
    [[self.leftActionButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.eventStream sendNext:@(uexGestureUnlockCodeCreationBegin)];
    }];
    self.leftActionButton.hidden = NO;
}


- (void)cancel{
    [self.eventStream sendError:[uexGestureUnlockError forcedCancalError]];
}
#pragma mark - Signals

- (RACSignal *)ifCodeValidSignal:(NSArray<NSNumber *> *)input{
    NSMutableString *code = [NSMutableString string];
    for(int i=0;i<[input count];i++){
        [code appendString:[input[i] stringValue]];
    }
    NSString *inputCode = [code copy];
    switch (self.signalType) {
        case uexGestureUnlockCodeVerificationSignal: {
            NSString *savedCode = [self.class getGestureCode];
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                if([savedCode isEqual:inputCode]){
                    [subscriber sendNext:@(YES)];
                }else{
                    [subscriber sendNext:@(NO)];
                }
                [[RACScheduler mainThreadScheduler]afterDelay:kUexGestureUnlockMinimumExecutionInteval schedule:^{
                    [subscriber sendCompleted];
                }];
                return nil;
            }];
            break;
        }
        case uexGestureUnlockCodeLengthCheckSignal: {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                if([inputCode length] >= self.config.minimumCodeLength){
                    self.inputCode = inputCode;
                    [subscriber sendNext:@(YES)];
                    if(self.infoView) {
                        [self.infoView SelectCircles:input];
                    }
                }else{
                    [subscriber sendNext:@(NO)];
                }
                
                [[RACScheduler mainThreadScheduler]afterDelay:kUexGestureUnlockMinimumExecutionInteval schedule:^{
                    [subscriber sendCompleted];
                }];
                return nil;
            }];
            break;
        }
        case uexGestureUnlockCodeEqualCheckSignal: {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                if([inputCode isEqual:self.inputCode]){
                    [subscriber sendNext:@(YES)];
                }else{
                    [subscriber sendNext:@(NO)];
                }
                [[RACScheduler mainThreadScheduler]afterDelay:kUexGestureUnlockMinimumExecutionInteval schedule:^{
                    [subscriber sendCompleted];
                }];
                return nil;
            }];
            break;
        }
    }
}



#pragma mark - Utility

+ (BOOL)isGestureCodeSet{
    NSString *gestureCode = [self getGestureCode];
    if(!gestureCode ||[gestureCode length] == 0){
        return NO;
    }else{
        return YES;
    }
}

- (void)clear{
    if(self.currentExecution){
        [self.currentExecution dispose];
        self.currentExecution = nil;
    }
    if(self.infoView){
        [self.infoView removeFromSuperview];
        self.infoView = nil;
    }
    if(self.iconView){
        [self.iconView removeFromSuperview];
        self.iconView = nil;
    }
    self.leftActionButton.hidden = YES;
    self.rightActionButton.hidden = YES;
    self.trialTimes = 0;
    self.inputCode = @"";
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.eventStream sendNext:@(uexGestureUnlockCodeVerificationCancelled)];
    }
}


@end
