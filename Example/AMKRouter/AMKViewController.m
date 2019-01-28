//
//  AMKViewController.m
//  AMKRouter
//
//  Created by AndyM129 on 01/28/2019.
//  Copyright (c) 2019 AndyM129. All rights reserved.
//

#import "AMKViewController.h"
#import "AMKRouter.h"

@interface AMKViewController () <UITableViewDelegate , UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSDictionary *dataSource;
@end

@implementation AMKViewController

#pragma mark - Init Methods

#pragma mark - Life Circle

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.title.length) self.title = @"AMKDispatcher 分发演示";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.tableView action:@selector(reloadData)];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Data & Networking

#pragma mark - Layout Subviews

#pragma mark - Properties

- (NSDictionary *)dataSource {
    if (!_dataSource) {
        NSMutableDictionary *dataSource = [NSMutableDictionary dictionary];
        dataSource[@"amkits://demo.router.amkits.andy.com/view/safari?url=https%3a%2f%2fgithub.com%2fAndyM129%2fAMKLocaleDescription%2ftree%2fmaster"] = @"前往GitHub查看完整说明 👉";
        dataSource[@"amkits://demo.router.amkits.andy.com/view/gotoViewController?class=AMKViewController&title=路由跳转示例"] = @"创建并前往指定页面";
        dataSource[@"amkits://demo.router.amkits.andy.com/view/alert?title=标题&message=弹窗提示文案&cancelTitle=知道啦"] = @"创建并显示弹窗";
        _dataSource = dataSource;
    }
    return _dataSource;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

#pragma mark - Actions

#pragma mark - Override

#pragma mark - Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return AMKRouter.sharedInstance.routingTable.count;
    if (section == 1) return self.dataSource.count;
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"已注册路由";
    if (section == 1) return @"示例";
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.detailTextLabel.numberOfLines = 3;
        
    }
    
    if (indexPath.section == 0) {
        NSString *router = AMKRouter.sharedInstance.routingTable.allKeys[indexPath.row];
        NSDictionary *routerInfo = AMKRouter.sharedInstance.routingTable[router];
        NSString *name = routerInfo[AMKRouterDispatcherNameParamKey];
        cell.textLabel.text = name;
        cell.detailTextLabel.text = router;
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    } else {
        NSString *router = self.dataSource.allKeys[indexPath.row];
        NSString *name = self.dataSource[router];
        cell.textLabel.text = name;
        cell.detailTextLabel.text = router;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSString *router = AMKRouter.sharedInstance.routingTable.allKeys[indexPath.row];
        NSDictionary *routerInfo = AMKRouter.sharedInstance.routingTable[router];
        NSString *name = routerInfo[AMKRouterDispatcherNameParamKey];
        [[[UIAlertView alloc] initWithTitle:name message:routerInfo.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        NSLog(@"当前路由为：%@ => %@", router, routerInfo);
    } else {
        NSString *router = self.dataSource.allKeys[indexPath.row];
        id object = [AMKRouter performRouterUrl:router paramsBlock:nil errorBlock:nil];
    }
}

#pragma mark - Helper Methods


@end
