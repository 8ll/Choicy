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

#import "CHPApplicationListSubcontrollerController.h"
#import "../Shared.h"
#import "CHPPreferences.h"

@implementation CHPApplicationListSubcontrollerController

+ (NSString *)previewStringForProcessPreferences:(NSDictionary *)processPreferences
{
	NSNumber *tweakInjectionDisabledNum = processPreferences[kChoicyProcessPrefsKeyTweakInjectionDisabled];
	NSNumber *customTweakConfigurationEnabledNum = processPreferences[kChoicyProcessPrefsKeyCustomTweakConfigurationEnabled];
	NSNumber *overwriteGlobalTweakConfigurationNum = processPreferences[kChoicyProcessPrefsKeyOverwriteGlobalTweakConfiguration];

	if (tweakInjectionDisabledNum.boolValue) {
		return localize(@"TWEAKS_DISABLED");
	}
	else if (customTweakConfigurationEnabledNum.boolValue) {
		return localize(@"CUSTOM");
	}
	else if (overwriteGlobalTweakConfigurationNum.boolValue) {
		NSArray *globalDeniedTweaks = preferences[kChoicyPrefsKeyGlobalDeniedTweaks];
		if (globalDeniedTweaks.count) {
			return localize(@"GLOBAL_OVERWRITE");
		}
	}
	return @"";
}

- (NSString *)previewStringForApplicationWithIdentifier:(NSString *)applicationID
{
	NSDictionary *appSettings = [preferences objectForKey:kChoicyPrefsKeyAppSettings];
	NSDictionary *settingsForApplication = [appSettings objectForKey:applicationID];
	return [[self class] previewStringForProcessPreferences:settingsForApplication];
}

@end