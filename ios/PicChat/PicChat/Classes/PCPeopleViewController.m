//
//  PCPeopleViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "Facebook.h"

#import "PCAppDelegate.h"
#import "PCPeopleViewController.h"
#import "PCPersonViewCell.h"
#import "PCHeaderView.h"
#import "PCCameraViewController.h"

@interface PCPeopleViewController () <UITableViewDataSource, UITableViewDelegate, FBFriendPickerDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *familyPeople;
@property (nonatomic, strong) NSMutableArray *friendPeople;
@property(nonatomic, strong) UIButton *refreshButton;
@property (nonatomic) BOOL isFamily;
@property(nonatomic) BOOL isMoreLoadable;
@property(nonatomic, strong) NSIndexPath *idxPath;
@end

@implementation PCPeopleViewController

@synthesize familyPeople = _familyPeople;
@synthesize friendPeople = _friendPeople;

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor clearColor];
		
		_isFamily = YES;
		_isMoreLoadable = YES;
		
		_familyPeople = [NSMutableArray array];
		_friendPeople = [NSMutableArray array];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_presentFriends:) name:@"PRESENT_FRIENDS" object:nil];
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	friendsButton.frame = CGRectMake(18.0, 338.0, 284.0, 49.0);
	friendsButton.backgroundColor = [UIColor redColor];
	[friendsButton addTarget:self action:@selector(_goChallengeFriends) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:friendsButton];
	
	[self _goChallengeFriends];
}

- (void)_goChallengeFriends {
	
//	[[Mixpanel sharedInstance] track:@"Pick Challenger - Friend"
//								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
//												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	FBFriendPickerViewController *friendPickerController = [[FBFriendPickerViewController alloc] init];
	friendPickerController.title = @"Pick Friends";
	friendPickerController.allowsMultipleSelection = NO;
	friendPickerController.delegate = self;
	friendPickerController.sortOrdering = FBFriendDisplayByLastName;
	friendPickerController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
																				  initWithTitle:@"Cancel!"
																				  style:UIBarButtonItemStyleBordered
																				  target:self
																				  action:@selector(cancelButtonWasPressed:)];
	
	friendPickerController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
																					initWithTitle:@"Done!"
																					style:UIBarButtonItemStyleBordered
																					target:self
																					action:@selector(doneButtonWasPressed:)];
	[friendPickerController loadData];
	
	// Use the modal wrapper method to display the picker.
	[friendPickerController presentModallyFromViewController:self animated:YES handler:
	 ^(FBViewController *sender, BOOL donePressed) {
		 if (!donePressed)
			 return;
		 
		 if (friendPickerController.selection.count == 0) {
			 [[[UIAlertView alloc] initWithTitle:@"No Friend Selected"
												  message:@"You need to pick a friend."
												 delegate:nil
									 cancelButtonTitle:@"OK"
									 otherButtonTitles:nil]
			  show];
			 
		 } else {
			 [self.navigationController dismissViewControllerAnimated:NO completion:^(void) {
				 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCCameraViewController alloc] init]];
				 [navigationController setNavigationBarHidden:YES];
				 [[PCAppDelegate rootViewController] presentViewController:navigationController animated:NO completion:nil];
			 }];
			 
//			 _filename = [NSString stringWithFormat:@"%@_%@", [PCAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
//			 _fbID = [[friendPickerController.selection lastObject] objectForKey:@"id"];
//			 _fbName = [[friendPickerController.selection lastObject] objectForKey:@"first_name"];
//			 //NSLog(@"FRIEND:[%@]", [friendPickerController.selection lastObject]);
//			 
//			 [self _goSubmitChallenge];
		 }
	 }];
}
	
//	PCHeaderView *headerView = [[PCHeaderView alloc] initWithTitle:@"Friends"];
//	[self.view addSubview:headerView];
//	
//	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//	activityIndicatorView.frame = CGRectMake(284.0, 10.0, 24.0, 24.0);
//	[activityIndicatorView startAnimating];
//	[headerView addSubview:activityIndicatorView];
//	
//	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_refreshButton.frame = CGRectMake(270.0, 0.0, 50.0, 45.0);
//	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive.png"] forState:UIControlStateNormal];
//	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active.png"] forState:UIControlStateHighlighted];
//	[_refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
//	[headerView addSubview:_refreshButton];
//	
//	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0) style:UITableViewStylePlain];
//	[_tableView setBackgroundColor:[UIColor clearColor]];
//	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//	_tableView.rowHeight = 70.0;
//	_tableView.delegate = self;
//	_tableView.dataSource = self;
//	_tableView.userInteractionEnabled = YES;
//	_tableView.scrollsToTop = NO;
//	_tableView.showsVerticalScrollIndicator = YES;
//	[self.view addSubview:_tableView];


- (void)_pushCameraView {
	[self.navigationController pushViewController:[[PCCameraViewController alloc] init] animated:NO];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Navigation
- (void)_goRefresh {
	
}

#pragma mark - Notifications
- (void)_presentFriends:(NSNotification *)notification {
	[self _goChallengeFriends];
}

- (void)cancelButtonWasPressed:(id)sender {
	
}

- (void)doneButtonWasPressed:(id)sender {
	
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_isFamily)
		return ([_familyPeople count] + 2);
	
	else
		return ([_friendPeople count] + 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PCPersonViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		if (indexPath.row == 0)
			cell = [[PCPersonViewCell alloc] initAsTopCell:_isFamily];
		
		else if (indexPath.row == [_familyPeople count] + 1)
			cell = [[PCPersonViewCell alloc] initAsBottomCell:_isMoreLoadable];
		
		else
			cell = [[PCPersonViewCell alloc] initAsChatCell];
	}
	
	if (indexPath.row > 0 && indexPath.row < [_familyPeople count] + 1)
		cell.personVO = [_familyPeople objectAtIndex:indexPath.row - 1];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (70.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [_familyPeople count] + 1) {
		
//		PCPersonVO *vo = [_familyPeople objectAtIndex:indexPath.row - 1];
		return (indexPath);
	}
	
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	[(PCPersonViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
//	PCPersonVO *vo = [_familyPeople objectAtIndex:indexPath.row - 1];
	
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
	
	return (indexPath.row > 0 && indexPath.row < [_familyPeople count] + 1);
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
