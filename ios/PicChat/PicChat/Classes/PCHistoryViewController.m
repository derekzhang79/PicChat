//
//  PCHistoryViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Mixpanel.h"

#import "PCHistoryViewController.h"
#import "PCHistoryViewCell.h"
#import "PCHeaderView.h"
#import "PCChatViewController.h"
#import "PCAppDelegate.h"
#import "PCChatVO.h"
#import "PCCameraViewController.h"


@interface PCHistoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *allChats;
@property(nonatomic, strong) UIButton *refreshButton;
@property(nonatomic) BOOL isMoreLoadable;
@property(nonatomic, strong) NSIndexPath *idxPath;
@property(nonatomic, strong) NSDate *lastDate;
@end

@implementation PCHistoryViewController


- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor clearColor];
		_isMoreLoadable = YES;
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	PCHeaderView *headerView = [[PCHeaderView alloc] initWithTitle:@"Chats"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(3.0, 5.0, 64.0, 34.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.frame = CGRectMake(284.0, 10.0, 24.0, 24.0);
	[activityIndicatorView startAnimating];
	[headerView addSubview:activityIndicatorView];
	
	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_refreshButton.frame = CGRectMake(274.0, 5.0, 44.0, 34.0);
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive.png"] forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active.png"] forState:UIControlStateHighlighted];
	[_refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:_refreshButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 65.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	[self _retrieveChats];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_retrieveChats {
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"] != nil) {
		_allChats = [NSMutableArray array];
		NSURL *url = [NSURL URLWithString:[PCAppDelegate apiServerPath]];
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
		
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSString stringWithFormat:@"%d", 1], @"action",
										[[PCAppDelegate infoForUser] objectForKey:@"id"], @"userID",
										nil];
		
		[httpClient postPath:kChatsAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
			NSLog(@"Response: %@", text);
			
			NSError *error = nil;
			if (error != nil)
				NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			
			else {
				NSArray *chats = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
				
				for (NSDictionary *chatDict in chats) {
					PCChatVO *vo = [PCChatVO chatWithDictionary:chatDict];
					
					if (vo != nil)
						[_allChats addObject:vo];
				}
				
				if ([chats count] == 0)
					_isMoreLoadable = NO;
				
				_lastDate = ((PCChatVO *)[_allChats lastObject]).addedDate;
				_refreshButton.hidden = NO;
				[_tableView reloadData];
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"%@", [error localizedDescription]);
			_refreshButton.hidden = NO;
		}];
//	}
}

#pragma mark - Navigation
- (void)_goCamera {
	[self.navigationController dismissViewControllerAnimated:NO completion:^(void) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCCameraViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[[PCAppDelegate rootViewController] presentViewController:navigationController animated:NO completion:nil];
	}];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Refresh Chat List"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 nil]];
	
	_refreshButton.hidden = YES;
	[self _retrieveChats];
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_allChats count] + 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PCHistoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		if (indexPath.row == 0)
			cell = [[PCHistoryViewCell alloc] initAsTopCell];
		
		else if (indexPath.row == [_allChats count] + 1)
			cell = [[PCHistoryViewCell alloc] initAsBottomCell:_isMoreLoadable];
		
		else
			cell = [[PCHistoryViewCell alloc] initAsChatCell];
	}
	
	if (indexPath.row > 0 && indexPath.row < [_allChats count] + 1)
		cell.chatVO = (PCChatVO *)[_allChats objectAtIndex:indexPath.row - 1];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0)
		return (20.0);
	
	else
		return (70.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [_allChats count] + 1) {
		return (indexPath);
	}
	
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	[(PCHistoryViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	PCChatVO *vo = (PCChatVO *)[_allChats objectAtIndex:indexPath.row - 1];
	[self.navigationController pushViewController:[[PCChatViewController alloc] initWithChatVO:vo] animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row > 0 && indexPath.row < [_allChats count] + 1);
}

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
