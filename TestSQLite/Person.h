//
//  Person.h
//  TestSQLite
//
//  Created by wangjianwei on 16/1/21.
//  Copyright © 2016年 JW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject<NSCoding>
@property (nonatomic ,assign)int id;
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,assign)int age;
@end
