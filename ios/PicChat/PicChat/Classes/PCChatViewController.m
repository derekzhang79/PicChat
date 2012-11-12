//
//  PCChatViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.31.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"

#import "PCChatViewController.h"
#import "PCAppDelegate.h"
#import "PCHeaderView.h"
#import "PCChatEntryVO.h"
#import "PCChatEntryViewCell.h"


@interface PCChatViewController ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *refreshButton;
@property(nonatomic, strong) NSMutableArray *entries;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation PCChatViewController

@synthesize chatVO = _chatVO;

- (id)init {
	if ((self = [super init])) {
		_entries = [NSMutableArray array];
	}
	
	return (self);
}

- (id)initWithChatVO:(PCChatVO *)vo {
	if ((self = [self init])) {
		_chatVO = vo;
		
		[PCAppDelegate assignChatID:_chatVO.chatID];
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	PCHeaderView *headerView = [[PCHeaderView alloc] initWithTitle:[NSString stringWithFormat:@"#%@", _chatVO.subjectName]];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.frame = CGRectMake(284.0, 10.0, 24.0, 24.0);
	[activityIndicatorView startAnimating];
	[headerView addSubview:activityIndicatorView];
	
	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_refreshButton.frame = CGRectMake(275.0, 5.0, 44.0, 34.0);
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive.png"] forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active.png"] forState:UIControlStateHighlighted];
	[_refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:_refreshButton];
	
	UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 68.0, 320.0, 48.0)];
	footerImgView.image = [UIImage imageNamed:@"footerBG.png"];
	footerImgView.userInteractionEnabled = YES;
	[self.view addSubview:footerImgView];
	
	UIButton *midButton = [UIButton buttonWithType:UIButtonTypeCustom];
	midButton.frame = CGRectMake(64.0, 0.0, 191.0, 48.0);
	[midButton setBackgroundImage:[UIImage imageNamed:@"middleIcon_nonActive.png"] forState:UIControlStateNormal];
	[midButton setBackgroundImage:[UIImage imageNamed:@"middleIcon_Active.png"] forState:UIControlStateHighlighted];
	[midButton addTarget:self action:@selector(_goAddEntry) forControlEvents:UIControlEventTouchUpInside];
	[footerImgView addSubview:midButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 114.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 220.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	[self _retrieveEntries];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_retrieveEntries {
	_entries = [NSMutableArray array];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading Contents…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[PCAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 2], @"action",
									[NSString stringWithFormat:@"%d", _chatVO.chatID], @"chatID",
									nil];
	
	[httpClient postPath:kChatEntriesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		NSLog(@"Response: %@", text);
		
		NSError *error = nil;
		if (error != nil)
			NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
		
		else {
			NSArray *entries = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			for (NSDictionary *entryDict in entries) {
				PCChatEntryVO *vo = [PCChatEntryVO entryWithDictionary:entryDict];
				
				if (vo != nil)
					[_entries addObject:vo];
			}
		}
		
		[_progressHUD hide:YES];
		_progressHUD = nil;
		
		_refreshButton.hidden = NO;
		[_tableView reloadData];
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_entries count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
		[_progressHUD hide:YES];
		_progressHUD = nil;
		_refreshButton.hidden = NO;
	}];
}


#pragma mark - Navigation
- (void)_goBack {
	[PCAppDelegate assignChatID:0];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Refresh Chat"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 nil]];
	
	_refreshButton.hidden = YES;
	[self _retrieveEntries];
}

- (void)_goAddEntry {
	[[Mixpanel sharedInstance] track:@"Open Chat Camera"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCCameraViewController alloc] initWithChatID:_chatVO.chatID withSubject:_chatVO.subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self.navigationController presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_entries count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PCChatEntryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		cell = [[PCChatEntryViewCell alloc] init];
	}
	
	cell.entryVO = (PCChatEntryVO *)[_entries objectAtIndex:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (220.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
