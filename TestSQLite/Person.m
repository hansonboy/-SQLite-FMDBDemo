//
//  Person.m
//  TestSQLite
//
//  Created by wangjianwei on 16/1/21.
//  Copyright © 2016年 JW. All rights reserved.
//

#import "Person.h"

@implementation Person
-(NSString *)description{
    return [NSString stringWithFormat:@"id:%d--name:%@--age:%d",self.id,self.name,self.age];
}
-(instancetype)initWithCoder:(NSCoder *)decoder{
    if (self = [super init]) {
        self.id = [decoder decodeIntForKey:@"id"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.age = [decoder decodeIntForKey:@"age"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeInt:self.id
                forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeInt:self.age forKey:@"age"];
}
@end
