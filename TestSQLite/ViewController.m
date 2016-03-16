//
//  ViewController.m
//  TestSQLite
//
//  Created by wangjianwei on 16/1/21.
//  Copyright © 2016年 JW. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "Person.h"
#import "FMDB.h"
@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",NSHomeDirectory());
    [self testFMDB2];
}
//存取任意对象
-(void)testFMDB2{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [cacheDir stringByAppendingPathComponent:@"Person.sqlite"];
    //1.建立数据库对象，一个数据库对应一个数据库对象
    FMDatabase * db = [FMDatabase databaseWithPath:filename];
    //2.打开数据库
    if (![db open]) {
        NSLog(@"数据库连接或者创建失败");
        return;
    }
    //3. 建表
    NSString *createSql = @"create table  if not exists t_persons(id integer primary key,person blob not null unique,age integer);";
    if (![db executeUpdate:createSql]) {
        NSLog(@"error:%@",[db lastErrorMessage]);
    }
    //4.插入数据
    for (int i = 0; i< 100; i++) {
        //将对象作为一个整体存入到数据库中
        Person *person = [[Person alloc]init];
        person.name = [NSString stringWithFormat:@"xiaoming%d",i];
        person.age = arc4random()%100;
        person.id = arc4random();
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:person];
        //插入blob 数据一定要使用excuteUpdateWithFormat:， 直接用executeUpdate:会报错的，因为你的数据使用NSLog打印出来会带有<>符号
        if (![db executeUpdateWithFormat:@"insert into t_persons(person,age) values(%@,%d)",data,person.age]) {
            NSLog(@"error:%@",[db lastErrorMessage]);
        }
    }
    //5.修改数据
    NSString *updateStr = [NSString stringWithFormat:@"update t_persons set age = 1000"];
    if (![db executeUpdate:updateStr]) {
        NSLog(@"error:%@",[db lastErrorMessage]);
    }
    //6. 删除数据
    NSString *deleteStr= [NSString stringWithFormat:@"delete from t_persons where id =1;"];
    if (![db executeUpdate:deleteStr]) {
        NSLog(@"error:%@",[db lastErrorMessage]);
    }
    //7.查询数据
    NSString *querySql = [NSString stringWithFormat:@"select * from t_persons "];
    FMResultSet * set = [db executeQuery:querySql];
    while (set.next) {
        NSData *data = [set dataForColumn:@"person"];
//        NSLog(@"%@",data);
        Person *person = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        person.id = [set intForColumn:@"id"];
        NSLog(@"%@",person);
    }

}
-(void)testFMDB{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [cacheDir stringByAppendingPathComponent:@"new.sqlite"];
    //1.建立数据库对象，一个数据库对应一个数据库对象
    FMDatabase * db = [FMDatabase databaseWithPath:filename];
    //2.打开数据库
    if (![db open]) {
        NSLog(@"数据库连接或者创建失败");
        return;
    }
    //3. 建表
    NSString *createSql = @"create table  if not exists t_person(id integer primary key,name text not null unique,age integer);";
    if (![db executeUpdate:createSql]) {
        NSLog(@"error:%@",[db lastErrorMessage]);
    }
    //4.插入数据
    for (int i = 0; i< 100; i++) {
        //fmdb 最好自己把你的sql字符串用NSString写出来
        NSString * insertSql = [NSString stringWithFormat:@"insert into t_person(name,age) values('xiaoming%d',%d)",i,arc4random()%100];
        if (![db executeUpdate:insertSql]) {
            NSLog(@"error:%@",[db lastErrorMessage]);
        }
    }
    //5.修改数据
    NSString *updateStr = [NSString stringWithFormat:@"update t_person set age = 1000"];
    if (![db executeUpdate:updateStr]) {
        NSLog(@"error:%@",[db lastErrorMessage]);
    }
    //6. 删除数据
    NSString *deleteStr= [NSString stringWithFormat:@"delete from t_person where id =1;"];
    if (![db executeUpdate:deleteStr]) {
        NSLog(@"error:%@",[db lastErrorMessage]);
    }
    //7.查询数据
    NSString *querySql = [NSString stringWithFormat:@"select * from t_person"];
    FMResultSet * set = [db executeQuery:querySql];
    while (set.next) {
        Person *person = [[Person alloc]init];
        person.id = [set intForColumn:@"id"];
        person.name = [set stringForColumn:@"name"];
        person.age = [set intForColumn:@"age"];
        NSLog(@"%@",person);
    }
}
-(void)testSQLite3{
    //1. 打开(建立)数据库
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [cacheDir stringByAppendingPathComponent:@"test.sqlite"];
    sqlite3 * db = nil;
    
    //0表示成功，1表示失败
    sqlite3_open(filename.UTF8String, &db);
    if (!db) {
        NSLog(@"数据库打开失败，建立失败");
        return;
    }
    char *errmsg = nil;
    //2.一般用来执行无返回结果的sql 命令,（可以执行任何SQL语句）
    //创建数据库
    char * createTableSql = "create table  t_person(id integer primary key,name text not null unique,age integer);";
    int rs = sqlite3_exec(db, createTableSql, NULL, NULL, &errmsg);
    
    if (errmsg) {
        NSLog(@"%s--errorCode:%d",errmsg,rs);
    }
    //3.插入数据
    for(NSUInteger i = 0;i < 100;i ++){
        NSString *insertSql = [NSString stringWithFormat:@"insert into t_person(name,age) values('小hong%lu',%d);",(unsigned long)i,arc4random()%100+10];
        char *errmsg = nil;
        sqlite3_exec(db, insertSql.UTF8String, NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"insert error:%s",errmsg);
        }
    }
    //4.查询数据 尽量使用const char * 不要用NSString ,容易出错
    const char* selectSql =  "select * from t_person where name like '小明%' and age < 20 order by age desc limit 1,10";
    sqlite3_stmt * stmt = nil;
    sqlite3_prepare(db, selectSql, (int)strlen(selectSql), &stmt, NULL);
    if (stmt) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            Person *person = [[Person alloc]init];
            person.id =  sqlite3_column_int(stmt, 0);
            person.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
            person.age = sqlite3_column_int(stmt, 2);
            NSLog(@"%@",person);
        }
    }
}
@end
