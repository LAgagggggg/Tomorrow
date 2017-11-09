//
//  TmrThing.m
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/9.
//  Copyright © 2017年 李嘉银. All rights reserved.
//

#import "TmrThing.h"

@implementation TmrThing

-(TmrThing *)initWithTitle:(NSString *)title{
    self=[super init];
    self.title=title;
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self.title = [aDecoder decodeObjectForKey:@"title"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
}
@end
