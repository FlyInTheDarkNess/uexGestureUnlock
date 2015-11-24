
/**
 *
 *	@file   	: UiColor+HtmlColor.m  in EUExGestureUnlock Project
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




#import "UIColor+HtmlColor.h"

@implementation UIColor (HtmlColor)

+(UIColor *)uexGU_ColorFromHtmlString:(NSString *)colorString{
    
    colorString=[[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    if ([colorString hasPrefix:@"#"]){
        
        unsigned int r,g,b,a;
        
        NSRange range;
        NSMutableArray *colorArray=[NSMutableArray arrayWithCapacity:4];
        switch ([colorString length]) {
            case 4://"#123"型字符串
                [colorArray addObject:@"ff"];
                for(int k=0;k<3;k++){
                    range.location=k+1;
                    range.length=1;
                    NSMutableString *tmp=[[colorString substringWithRange:range] mutableCopy];
                    [tmp  appendString:tmp];
                    [colorArray addObject:tmp];
                    
                }
                break;
            case 7://"#112233"型字符串
                [colorArray addObject:@"ff"];
                for(int k=0;k<3;k++){
                    range.location=2*k+1;
                    range.length=2;
                    [colorArray addObject:[colorString substringWithRange:range]];
                    
                }
                break;
            case 9://"#11223344"型字符串
                for(int k=0;k<4;k++){
                    range.location=2*k+1;
                    range.length=2;
                    [colorArray addObject:[colorString substringWithRange:range]];
                }
                break;
                
            default:
                return nil;
                break;
        }
        [[NSScanner scannerWithString:colorArray[0]] scanHexInt:&a];
        [[NSScanner scannerWithString:colorArray[1]] scanHexInt:&r];
        [[NSScanner scannerWithString:colorArray[2]] scanHexInt:&g];
        [[NSScanner scannerWithString:colorArray[3]] scanHexInt:&b];
        
        return [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:(float)a/255.0];
    }
    if ([colorString hasPrefix:@"rgb("]&&[colorString hasSuffix:@")"]){
        colorString=[colorString substringWithRange:NSMakeRange(4, [colorString length] -5)];
        return [self uexGU_ColorWithRGBAArray:[colorString componentsSeparatedByString:@","]];
    }
    if ([colorString hasPrefix:@"rgba("]&&[colorString hasSuffix:@")"]){
        colorString=[colorString substringWithRange:NSMakeRange(5, [colorString length] -6)];
        return [self uexGU_ColorWithRGBAArray:[colorString componentsSeparatedByString:@","]];
    }
    return nil;
    
    
}

+(UIColor*)uexGU_ColorWithRGBAArray:(NSArray *)rgbaStr{
    if([rgbaStr count]<3){
        return nil;
    }
    NSMutableArray *rgb=[NSMutableArray array];
    NSString *alpha=@"1";
    if([rgbaStr count]>3 && [rgbaStr[3] isKindOfClass:[NSString class]]){
        alpha=[rgbaStr[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    for(int i=0;i<3;i++) {
        if(![rgbaStr[i] isKindOfClass:[NSString class]]){
           return nil;
        }
        NSString *str=rgbaStr[i];
        str=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([str hasSuffix:@"%"]){
            str=[str substringWithRange:NSMakeRange(0, [str length] - 1)];
            [rgb addObject:[NSNumber numberWithFloat:([str floatValue]*255.0f/100.0f)]];
        }else{
            [rgb addObject:[NSNumber numberWithFloat:[str floatValue]]];
        }
    }
    return [UIColor colorWithRed:[rgb[0] floatValue]/255 green:[rgb[1] floatValue]/255 blue:[rgb[2] floatValue]/255 alpha:[alpha floatValue]];
    
    
}

@end
