// Copyright (c) 2019-2021 Lars Fröder

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "CHPListController.h"
#import "../Shared.h"
#import "../ChoicyPrefsMigrator.h"

@implementation CHPListController

+ (void)sendPostNotificationForSpecifier:(PSSpecifier *)specifier
{
	NSString *postNotification = [specifier propertyForKey:@"PostNotification"];
	if (postNotification) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)postNotification, NULL, NULL, YES);
	}
}

+ (void)sendChoicyPrefsPostNotification
{
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.opa334.choicyprefs/ReloadPrefs"), NULL, NULL, YES);
}

//Must be overwritten by subclass
- (NSString *)topTitle
{
	return nil;
}

//Must be overwritten by subclass
- (NSString *)plistName
{
	return nil;
}

- (void)applySearchControllerHideWhileScrolling:(BOOL)hideWhileScrolling
{
	_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	_searchController.searchResultsUpdater = self;
	if (@available(iOS 9.1, *)) _searchController.obscuresBackgroundDuringPresentation = NO;

	if (@available(iOS 11.0, *)) {
		if (@available(iOS 13.0, *)) {
			_searchController.hidesNavigationBarDuringPresentation = YES;
		}
		else {
			_searchController.hidesNavigationBarDuringPresentation = NO;
		}

		self.navigationItem.searchController = _searchController;
		self.navigationItem.hidesSearchBarWhenScrolling = hideWhileScrolling;
	}
	else {
		self.table.tableHeaderView = _searchController.searchBar;
		[self.table setContentOffset:CGPointMake(0,44) animated:NO];
	}

	_searchKey = @"";
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
	_searchKey = searchController.searchBar.text;
	[self reloadSpecifiers];
}

- (NSMutableArray *)specifiers
{
	if (!_specifiers) {
		NSString *plistName = [self plistName];

		if (plistName) {
			_specifiers = [self loadSpecifiersFromPlistName:plistName target:self bundle:[NSBundle bundleForClass:[CHPListController class]]];
			[self parseLocalizationsForSpecifiers:_specifiers];
		}
	}

	NSString *title = [self topTitle];
	if (title) {
		[(UINavigationItem *)self.navigationItem setTitle:title];
	}

	return _specifiers;
}

- (void)parseLocalizationsForSpecifiers:(NSArray *)specifiers
{
	//Localize specifiers
	NSMutableArray *mutableSpecifiers = (NSMutableArray *)specifiers;
	for (PSSpecifier *specifier in mutableSpecifiers) {
		HBLogDebug(@"title:%@",specifier.properties[@"label"]);
		NSString *localizedTitle = localize(specifier.properties[@"label"]);
		NSString *localizedFooter = localize(specifier.properties[@"footerText"]);
		specifier.name = localizedTitle;
		[specifier setProperty:localizedFooter forKey:@"footerText"];
	}
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithContentsOfFile:kChoicyPrefsPlistPath];
	if (!mutableDict) {
		mutableDict = [NSMutableDictionary new];
		[ChoicyPrefsMigrator updatePreferenceVersion:mutableDict];
	}
	[mutableDict setObject:value forKey:[[specifier properties] objectForKey:@"key"]];
	[mutableDict writeToFile:kChoicyPrefsPlistPath atomically:YES];

	[[self class] sendPostNotificationForSpecifier:specifier];
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:kChoicyPrefsPlistPath];

	id obj = [dict objectForKey:[[specifier properties] objectForKey:@"key"]];

	if (!obj) {
		obj = [[specifier properties] objectForKey:@"default"];
	}

	return obj;
}

@end