//
//  PCHistoryViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCHistoryViewController.h"
#import "PCHistoryViewCell.h"
#import "PCHeaderView.h"
#import "PCChatViewController.h"
#import "PCAppDelegate.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@interface PCHistoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *pendingChats;
@property (nonatomic, strong) NSMutableArray *allChats;
@property(nonatomic, strong) UIButton *refreshButton;
@property (nonatomic) BOOL isNewChats;
@property(nonatomic) BOOL isMoreLoadable;
@property(nonatomic, strong) NSIndexPath *idxPath;
@end

@implementation PCHistoryViewController

@synthesize pendingChats = _pendingChats;
@synthesize allChats = _allChats;

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor clearColor];
		_isNewChats = YES;
		_isMoreLoadable = YES;
		
		_pendingChats = [NSMutableArray array];
		_allChats = [NSMutableArray array];
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	PCHeaderView *headerView = [[PCHeaderView alloc] initWithTitle:@"Chats"];
	[self.view addSubview:headerView];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.frame = CGRectMake(284.0, 10.0, 24.0, 24.0);
	[activityIndicatorView startAnimating];
	[headerView addSubview:activityIndicatorView];
	
	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_refreshButton.frame = CGRectMake(270.0, 0.0, 50.0, 45.0);
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive.png"] forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active.png"] forState:UIControlStateHighlighted];
	[_refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:_refreshButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_retrieveChats {
	//if (![[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
	
	
	NSURL *url = [NSURL URLWithString:[PCAppDelegate apiServerPath]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 1], @"action",
									[PCAppDelegate deviceToken], @"token",
									nil];
	
	[httpClient postPath:kMessagesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		NSLog(@"Response: %@", text);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
	}];
}

#pragma mark - Navigation
- (void)_goRefresh {
	
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_isNewChats)
		return ([_pendingChats count] + 2);
	
	else
		return ([_allChats count] + 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PCHistoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		if (indexPath.row == 0)
			cell = [[PCHistoryViewCell alloc] initAsTopCell:_isNewChats];
		
		else if (indexPath.row == [_pendingChats count] + 1)
			cell = [[PCHistoryViewCell alloc] initAsBottomCell:_isMoreLoadable];
		
		else
			cell = [[PCHistoryViewCell alloc] initAsChatCell];
	}
	
	if (indexPath.row > 0 && indexPath.row < [_pendingChats count] + 1)
		cell.chatVO = [_pendingChats objectAtIndex:indexPath.row - 1];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (70.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [_pendingChats count] + 1) {
		return (indexPath);
	}
	
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	[(PCHistoryViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	//PCChatVO *vo = [_pendingChats objectAtIndex:indexPath.row - 1];
	[self.navigationController pushViewController:[[PCChatViewController alloc] init] animated:YES];
	
//	if ([vo.status isEqualToString:@"Accept"] || [vo.status isEqualToString:@"Waiting"]) {
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPhotoViewController alloc] initWithImagePath:vo.imageURL withTitle:vo.subjectName]];
//		[navigationController setNavigationBarHidden:YES];
//		[self presentViewController:navigationController animated:YES completion:nil];
//		
//	} else if ([vo.status isEqualToString:@"Started"]) {
//		[self.navigationController pushViewController:[[HONVoteViewController alloc] initWithChallenge:vo] animated:YES];
//	}
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return YES if you want the specified item to be editable.
	
	return (indexPath.row > 0 && indexPath.row < [_pendingChats count] + 1);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		_idxPath = indexPath;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Chat"
																		message:@"Are you sure you want to remove this chat?"
																	  delegate:self
														  cancelButtonTitle:@"Yes"
														  otherButtonTitles:@"No", nil];
		[alert show];
	}
}

@end
