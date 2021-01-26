// Copyright 2021 Google
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "FIRCLSAnalyticsManager.h"

#import "Crashlytics/Crashlytics/Components/FIRCLSUserLogging.h"
#import "Crashlytics/Crashlytics/Helpers/FIRAEvent+Internal.h"
#import "Crashlytics/Crashlytics/Helpers/FIRCLSFCRAnalytics.h"

#import "Interop/Analytics/Public/FIRAnalyticsInterop.h"
#import "Interop/Analytics/Public/FIRAnalyticsInteropListener.h"

static NSString *FIRCLSFirebaseAnalyticsEventLogFormat = @"$A$:%@";

@interface FIRCLSAnalyticsManager () <FIRAnalyticsInteropListener> {
  id<FIRAnalyticsInterop> _analytics;
}

@property(nonatomic, assign) BOOL registeredAnalyticsEventListener;

@end

@implementation FIRCLSAnalyticsManager

- (instancetype)initWithAnalytics:(nullable id<FIRAnalyticsInterop>)analytics {
  self = [super init];
  if (!self) {
    return nil;
  }

  _analytics = analytics;

  return self;
}

- (void)registerAnalyticsListener {
  if (self.registeredAnalyticsEventListener) {
    return;
  }

  [FIRCLSFCRAnalytics registerEventListener:self toAnalytics:_analytics];

  self.registeredAnalyticsEventListener = YES;
}

- (void)messageTriggered:(NSString *)name parameters:(NSDictionary *)parameters {
  NSDictionary *event = @{
    @"name" : name,
    @"parameters" : parameters,
  };
  NSString *json = FIRCLSFIRAEventDictionaryToJSON(event);
  if (json != nil) {
    FIRCLSLog(FIRCLSFirebaseAnalyticsEventLogFormat, json);
  }
}

@end
