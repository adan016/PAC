//
//  XPlanTests.m
//  XPlanTests
//
//  Created by mjlee on 14-2-21.
//  Copyright (c) 2014年 mjlee. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TaskModel.h"
#import "ProjectModel.h"
#import "XPDataManager.h"
//#import "NSDate+Conversions.h"
#import "NSDate+Category.h"


@interface XPlanTests : XCTestCase
//@property(nonatomic,strong)XPDataManager* coreDataManger;
-(void)getItem:(NSString**)brief date:(NSDate**)date status:(NSNumber**)status ext:(int)ext;

@end

@implementation XPlanTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    //XPDataManager* cdMgr = [[XPDataManager alloc] init];
    //self.coreDataManger = cdMgr;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    BOOL      ifError = NO;
    NSString* title;
    NSDate*   date;
    NSNumber* status;
    // 测试日期类的正确性：增加
    int ext = 1;
    for (int i = 0 ; i < 5; i ++) {
        [self getItem:&title date:&date status:&status ext:ext];
        NSLog(@"title=%@,date=%@,ext=%d",title,date.description,ext);
        if (title == nil || date == nil) {
            ifError = YES;
            break;
        }
        ext ++;
    }
    // 测试日期类的正确性：减少
    ext = -1;
    for (int i = 0 ; i < 5; i ++) {
        [self getItem:&title date:&date status:&status ext:ext];
        NSLog(@"title=%@,date=%@,ext=%d",title,date.description,ext);
        if (title == nil || date == nil) {
            ifError = YES;
            break;
        }
        ext --;
    }
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertNotEqual(ifError, YES, @"NSDate Helper is Pass");
}


-(void)getItem:(NSString**)brief date:(NSDate**)date status:(NSNumber**)status ext:(int)ext
{
    NSDate* today = [NSDate date];
    if (ext < 0) {
        *date = [today dateBySubtractingDays:abs(ext)];
    }else{
        *date = [today dateByAddingDays:ext];
    }
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    *brief = [df stringFromDate:*date];
}

@end
