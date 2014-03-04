//
//  XPTaskListVCtler.m
//  XPlan
//
//  Created by mjlee on 14-3-2.
//  Copyright (c) 2014年 mjlee. All rights reserved.
//

#import "XPTaskListVCtler.h"
#import "XPNewTaskVctler.h"
#import "IIViewDeckController.h"
#import "XPTaskTableViewCell.h"
#import "FMMoveTableView.h"
#import "FMMoveTableViewCell.h"

@interface XPTaskListVCtler ()
{
    NSMutableArray* _taskListNormal;
    NSMutableArray* _taskListImportant;
    NSMutableArray* _taskListFinish;
}
// NavButtons
-(void)onNavRightBtuAction:(id)sender;
// Datas
-(void)reLoadData;
//ViewDeck
-(BOOL)openLeftView;
@end

@implementation XPTaskListVCtler
static NSString *sCellIdentifier;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization，load data From Core Data
        _taskListNormal = [[NSMutableArray alloc] init];
        _taskListImportant = [[NSMutableArray alloc] init];;
        _taskListFinish = [[NSMutableArray alloc] init];;
        
        sCellIdentifier = @"MoveCell";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[FMMoveTableView alloc] initWithFrame:self.tableView.frame style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    
    // Uncomment the following line to preserve selection between presentations.
    self.view.backgroundColor = [UIColor whiteColor];
    // navs setting
    UIImage* imgnormal   = [UIImage imageNamed:@"nav_btn_menu01"];
    UIImage* imhighLight = [UIImage imageNamed:@"nav_btn_menu02"];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, imgnormal.size.width/2, imgnormal.size.height/2);
    [btn setImage:imgnormal   forState:UIControlStateNormal];
    [btn setImage:imhighLight forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(openLeftView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* leftBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIBarButtonItem* rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                              target:self
                                                                              action:@selector(onNavRightBtuAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    // tableview
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reLoadData];
    [self.tableView reloadData];
}

#pragma mark -tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if(section == 0) count = [_taskListNormal count];
    if(section == 1) count = [_taskListImportant count];
    if(section == 2) count = [_taskListFinish count];

    #warning Implement this check in your table data source
    // 1. A row is in a moving state
    // 2. The moving row is not in it's initial section
    if (tableView.movingIndexPath && tableView.movingIndexPath.section != tableView.initialIndexPathForMovingRow.section)
    {

        if (section == tableView.movingIndexPath.section) {
            count++;
        }
        else if (section == tableView.initialIndexPathForMovingRow.section) {
            count--;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XPTaskTableViewCell *cell = (XPTaskTableViewCell *)[tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if ([tableView indexPathIsMovingIndexPath:indexPath])
	{
		[cell prepareForMove];
	}
	else
	{
        #warning Implement this check in your table view data source
		if (tableView.movingIndexPath != nil) {
            indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
		}else{
            if (!cell){
                cell = [[XPTaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sCellIdentifier tableview:tableView];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle= UITableViewCellSelectionStyleNone;
            }
            TaskModel* atask = nil;
            if([indexPath section] == 0){
                atask = [_taskListNormal objectAtIndex:[indexPath row]];
            }else if([indexPath section] == 1){
                atask = [_taskListImportant objectAtIndex:[indexPath row]];
            }else if([indexPath section] == 2){
                atask = [_taskListFinish objectAtIndex:[indexPath row]];
            }
            [cell setTask:atask];
        }
        cell.shouldIndentWhileEditing = NO;
        cell.showsReorderControl      = NO;
	}
    return cell;
}

#pragma mark- tableviewdelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskModel* atask = nil;
    if([indexPath section] == 0) atask = [_taskListNormal objectAtIndex:[indexPath row]];
    else if([indexPath section] == 1) atask = [_taskListImportant objectAtIndex:[indexPath row]];
    else if([indexPath section] == 2) atask = [_taskListFinish objectAtIndex:[indexPath row]];

    XPNewTaskVctler* updatevc = [[XPNewTaskVctler alloc] init];
    updatevc.viewType    = XPNewTaskViewType_Update;
    updatevc.task2Update = atask;
    [self.navigationController pushViewController:updatevc animated:YES];

    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray  *titleArray  = @[@"普通",@"重要",@"完成"];
    UIView* headview = [[UIView alloc] initWithFrame:CGRectZero];
    headview.backgroundColor = [UIColor colorWithRed:200/255.0
                                               green:200/255.0
                                                blue:200/255.0
                                               alpha:1.0];
    headview.alpha = 0.8;
    
    UILabel* sectionTItle = [UILabel new];
    sectionTItle.frame    = CGRectMake(15, 0, 0, 0);
    sectionTItle.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    sectionTItle.backgroundColor = kClearColor;
    sectionTItle.font       = [UIFont systemFontOfSize:18];
    sectionTItle.textColor  = [UIColor whiteColor];
    sectionTItle.text = titleArray[section];
    [headview addSubview:sectionTItle];
    return headview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 36;
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	//Uncomment these lines to enable moving a row just within it's current section
	//if ([sourceIndexPath section] != [proposedDestinationIndexPath section]) {
	//	proposedDestinationIndexPath = sourceIndexPath;
	//}
	return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger se = indexPath.section;
    if (se == 0) {
        [_taskListNormal removeObjectAtIndex:[indexPath row]];
    }else if(se == 1){
        [_taskListImportant removeObjectAtIndex:[indexPath row]];
    }else if(se == 2){
        [_taskListFinish removeObjectAtIndex:[indexPath row]];
    }

    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - UITableViewDataSource
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if ([indexPath section] == 2)
    {
        return NO;
    }
    return YES;
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.section == [toIndexPath section])
    {
        NSInteger se = fromIndexPath.section;
        if (se == 0) {
            [_taskListNormal exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        }else if(se == 1){
            [_taskListImportant exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        }else if(se == 2){
            [_taskListFinish exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        }
    }else
    {
        NSInteger se = fromIndexPath.section;
        NSMutableArray* tFromArray = nil;
        NSMutableArray* ToArray = nil;
        se == 0?(tFromArray=_taskListNormal):(se==1?(tFromArray=_taskListImportant):(tFromArray=_taskListFinish));
        se = toIndexPath.section;
        se == 0?(ToArray=_taskListNormal):(se==1?(ToArray=_taskListImportant):(ToArray=_taskListFinish));
        
        if (!tFromArray || !ToArray) {
            return;
        }
        TaskModel* task2Move = [tFromArray objectAtIndex:[fromIndexPath row]];
        [ToArray insertObject:task2Move atIndex:[toIndexPath row]];
        [tFromArray removeObject:task2Move];
    }
}

#pragma mark - 
-(void)reLoadData{
    XPAppDelegate* app = [XPAppDelegate shareInstance];
    {   // Normal
        NSArray* normalList = [app.coreDataMgr selectTaskByDay:[NSDate date] status:0];
        if (normalList && [normalList count]) {
            [_taskListNormal removeAllObjects];
            [_taskListNormal setArray:normalList];
        }else{
            [_taskListNormal removeAllObjects];
        }
    }
    
    {
        NSArray* importantList = [app.coreDataMgr selectTaskByDay:[NSDate date] status:1];
        if (importantList && [importantList count]) {
            [_taskListImportant removeAllObjects];
            [_taskListImportant setArray:importantList];
        }else{
            [_taskListImportant removeAllObjects];
        }
    }
    
    {
        NSArray* finishList = [app.coreDataMgr selectTaskByDay:[NSDate date] status:2];
        if (finishList && [finishList count]) {
            [_taskListFinish removeAllObjects];
            [_taskListFinish setArray:finishList];
        }else{
            [_taskListFinish removeAllObjects];
        }
    }
}

#pragma mark - Navigation
-(void)onNavRightBtuAction:(id)sender{
    XPNewTaskVctler* newTvctl = [[XPNewTaskVctler alloc] init];
    [self.navigationController pushViewController:newTvctl animated:YES];
}

#pragma mark - ViewDeck
-(BOOL)openLeftView{
    if ([self.viewDeckController isSideOpen:IIViewDeckLeftSide]) {
        if ([self.viewDeckController respondsToSelector:@selector(closeLeftViewAnimated:completion:)])
        {
            [self.viewDeckController closeLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success){
            }];
        }
    }else{
        if ([self.viewDeckController respondsToSelector:@selector(openLeftViewAnimated:completion:)])
        {
            [self.viewDeckController openLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success){
            }];
        }
    }
    return YES;
}

@end