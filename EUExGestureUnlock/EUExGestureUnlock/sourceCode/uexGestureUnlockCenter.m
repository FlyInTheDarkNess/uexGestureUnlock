/**
 *
 *	@file   	: uexGestureUnlockCenter.m  in EUExGestureUnlock Project
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 15/11/19
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

#import "uexGestureUnlockCenter.h"
#import "uexGestureUnlockView.h"
@interface uexGestureUnlockCenter()

@property (nonatomic,strong)uexGestureUnlockView *unlockView;

@end
@implementation uexGestureUnlockCenter

+(instancetype)sharedCenter{
    static uexGestureUnlockCenter *center=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center=[[self alloc] init];
        
    });
    return center;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.config=[uexGestureUnlockConfiguration defaultConfiguration];
    }
    return self;
}




#pragma mark - UserDefaults
-(NSString *)getGestureCode{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUexGestureUnlockConfigurationSaveGestureCodeKey];
}
-(void)saveGestureCode:(NSString *)code{
    [[NSUserDefaults standardUserDefaults] setValue:code forKey:kUexGestureUnlockConfigurationSaveGestureCodeKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)removeGestureCode{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kUexGestureUnlockConfigurationSaveGestureCodeKey];
}

#pragma mark - public method

-(BOOL)isGestureCodeSet{
    NSString *gestureCode=[self getGestureCode];
    if(!gestureCode ||[gestureCode length]==0){
        return NO;
    }else{
        return YES;
    }
}
-(void)removeGestureUnlockView{
    if(self.unlockView){
        [self.unlockView removeFromSuperview];
        self.unlockView=nil;
    }
}
-(void)verifyGestureWithResult:(uexGestureUnlockVerifyResultBlock)result{
#pragma warning TODO
}

-(void)setUpGesturCodeInEBrowserView:(EBrowserView *)eBrowserView callback:(uexGestureUnlockSetUpGestureCodeBlock)callback{
#pragma warning TODO
}
@end
