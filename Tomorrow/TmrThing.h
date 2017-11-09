//
//  TmrThing.h
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/9.
//  Copyright © 2017年 李嘉银. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TmrThing : NSObject<NSCoding>
@property(strong,nonatomic)NSString * title;

-(TmrThing *)initWithTitle:(NSString *)title;

-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;
@end
