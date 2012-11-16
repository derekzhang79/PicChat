//
//  PCSettingsViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 11.10.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Facebook.h"
#import "Mixpanel.h"
#import "PCSettingsViewController.h"

#import "PCSettingsViewCell.h"
#import "PCAppDelegate.h"

#import "PCSupportViewController.h"
#import "PCPrivacyViewController.h"
#import "PCLoginViewController.h"
#import "PCHeaderView.h"

@interface PCSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *notificationSwitch;
@property (nonatomic, strong) UISwitch *fbSwitch;
@property (nonatomic, strong) UISwitch *activatedSwitch;
@property (nonatomic, strong) NSArray *captions;
@end

@implementation PCSettingsViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSupport:) name:@"SHOW_SUPPORT" object:nil];
		
		_notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100.0, 5.0, 100.0, 50.0)];
		[_notificationSwitch addTarget:self action:@selector(_goNotificationsSwitch:) forControlEvents:UIControlEventValueChanged];
		if ([PCAppDelegate infoForUser] != nil)
			_notificationSwitch.on = [[[PCAppDelegate infoForUser] objectForKey:@"notifications"] isEqualToString:@"Y"];
		
		else
			_notificationSwitch.on = YES;
		
		_fbSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		[_fbSwitch addTarget:self action:@selector(_goFBSwitch:) forControlEvents:UIControlEventValueChanged];
		_fbSwitch.on = [PCAppDelegate allowsFBPosting];
		
		_captions = [NSArray arrayWithObjects:@"", @"Notifications", @"FB Timeline", @"Logout", @"Privacy Policy", @"", nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}



#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([PCAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	PCHeaderView *headerView = [[PCHeaderView alloc] initWithTitle:@"Settings"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 69.0) style:UITableViewStylePlain];
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


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:NO];
}

-(void)_goNotificationsSwitch:(UISwitch *)switchView {
	NSString *msg;
	
	if (switchView.on)
		msg = @"Turn on notifications?";
	
	else
		msg = @"Turn off notifications?";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notifications"
																	message:msg
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
	_activatedSwitch = switchView;
}

-(void)_goFBSwitch:(UISwitch *)switchView {
	NSString *msg;
	
	[PCAppDelegate setAllowsFBPosting:switchView.on];
	
	if (switchView.on)
		msg = @"Turn on Facebook posting?";
	
	else
		msg = @"Turn off facebook posting?";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Posting"
																	message:msg
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
	_activatedSwitch = switchView;
}


#pragma mark - Notifications
- (void)_showSupport:(NSNotification *)notification {
	[self.navigationController pushViewController:[[PCSupportViewController alloc] init] animated:YES];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (6);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	PCSettingsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		if (indexPath.row == 0)
			cell = [[PCSettingsViewCell alloc] initAsTopCell];
		
		else if (indexPath.row == 5)
			cell = [[PCSettingsViewCell alloc] initAsBottomCell];
		
		else
			cell = [[PCSettingsViewCell alloc] initAsMidCell:[_captions objectAtIndex:indexPath.row]];
	}
	
	if (indexPath.row == 1)
		cell.accessoryView = _notificationSwitch;
	
	if (indexPath.row == 2)
		cell.accessoryView = _fbSwitch;
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0 || indexPath.row == 5)
		return (20.0);
	
	else
		return (70.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 3 || indexPath.row == 4)
		return (indexPath);
	
	else
		return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
//	[(PCSettingsViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[PCLoginViewController alloc] init]];
	switch (indexPath.row) {
		case 3:
			[[Mixpanel sharedInstance] track:@"Facebook Logout"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 nil]];
			
			[FBSession.activeSession closeAndClearTokenInformation];
			
			[navController setNavigationBarHidden:YES];
			[self presentViewController:navController animated:YES completion:nil];
			break;
			
		case 4:
			[self.navigationController pushViewController:[[PCPrivacyViewController alloc] init] animated:YES];
			break;
	}
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0:
			if (_activatedSwitch == _fbSwitch) {
				[[Mixpanel sharedInstance] track:@"Facebook Posting"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d", _fbSwitch.on], @"switch", nil]];
				
				[PCAppDelegate setAllowsFBPosting:_fbSwitch.on];
				
			} else {
				//NSLog(@"-----loginViewShowingLoggedInUser-----");
				[[Mixpanel sharedInstance] track:@"Notifications"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d", _fbSwitch.on], @"switch", nil]];

				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[PCAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 3], @"action",
												[[PCAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												(_notificationSwitch.on) ? @"Y" : @"N", @"isNotifications",
												nil];
				
				[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					
					if (error != nil)
						NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
					
					else {
						NSLog(@"USER: %@", userResult);
						
						if ([userResult objectForKey:@"id"] != [NSNull null])
							[PCAppDelegate writeUserInfo:userResult];
					}
					
					//NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
					//NSLog(@"Response: %@", text);
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					NSLog(@"%@", [error localizedDescription]);
				}];
			}
			break;
			
		case 1:
			_activatedSwitch.on = !_activatedSwitch.on;
			break;
	}
}

@end
