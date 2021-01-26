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
#import "Crashlytics/Crashlytics/Helpers/FIRCLSInternalLogging.h"

#import "Interop/Analytics/Public/FIRAnalyticsInterop.h"
#import "Interop/Analytics/Public/FIRAnalyticsInteropListener.h"

static NSString *FIRCLSFirebaseAnalyticsEventLogFormat = @"$A$:%@";

// Origin for events and user properties generated by Crashlytics.
static NSString *const kFIREventOriginCrash = @"clx";

// App exception event name.
static NSString *const kFIREventAppException = @"_ae";

// Timestamp key for the event payload.
static NSString *const kFIRParameterTimestamp = @"timestamp";

// Fatal key for the event payload.
static NSString *const kFIRParameterFatal = @"fatal";

FOUNDATION_STATIC_INLINE NSNumber *timeIntervalInMillis(NSTimeInterval timeInterval) {
  return @(llrint(timeInterval * 1000.0));
}

@interface FIRCLSAnalyticsManager () <FIRAnalyticsInteropListener>

@property(nonatomic, strong) id<FIRAnalyticsInterop> analytics;

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

  if (self.analytics == nil) {
    FIRCLSDeveloperLog(@"Crashlytics:Crash:Reports:Event",
                       "Firebase Analytics SDK not detected. Crash-free statistics and "
                       "breadcrumbs will not be reported");
    return;
  }

  [self.analytics registerAnalyticsListener:self withOrigin:kFIREventOriginCrash];

  FIRCLSDeveloperLog(@"Crashlytics:Crash:Reports:Event",
                     "Registered Firebase Analytics event listener to receive breadcrumb logs");

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

+ (void)logCrashWithTimeStamp:(NSTimeInterval)crashTimeStamp
                  toAnalytics:(id<FIRAnalyticsInterop>)analytics {
  if (analytics == nil) {
    return;
  }

  FIRCLSDeveloperLog(@"Crashlytics:Crash:Reports:Event",
                     "Sending app_exception event to Firebase Analytics for crash-free statistics");

  NSDictionary *params = @{
    kFIRParameterTimestamp : timeIntervalInMillis(crashTimeStamp),
    kFIRParameterFatal : @(INT64_C(1))
  };

  [analytics logEventWithOrigin:kFIREventOriginCrash name:kFIREventAppException parameters:params];
}

NSString *FIRCLSFIRAEventDictionaryToJSON(NSDictionary *eventAsDictionary) {
  NSError *error = nil;

  if (eventAsDictionary == nil) {
    return nil;
  }

  if (![NSJSONSerialization isValidJSONObject:eventAsDictionary]) {
    FIRCLSSDKLog("Firebase Analytics event is not valid JSON");
    return nil;
  }

  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:eventAsDictionary
                                                     options:0
                                                       error:&error];

  if (error == nil) {
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json;
  } else {
    FIRCLSSDKLog("Unable to convert Firebase Analytics event to json");
    return nil;
  }
}

@end
