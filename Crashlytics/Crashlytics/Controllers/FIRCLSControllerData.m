//
//  FIRCLSControllerData.m
//  Pods
//
//  Created by Sam Edson on 1/26/21.
//

#import "FIRCLSControllerData.h"

#import "Crashlytics/Crashlytics/Components/FIRCLSApplication.h"
#import "Crashlytics/Crashlytics/Models/FIRCLSExecutionIdentifierModel.h"
#import "Crashlytics/Crashlytics/Models/FIRCLSInstallIdentifierModel.h"
#import "Crashlytics/Crashlytics/Settings/Models/FIRCLSApplicationIdentifierModel.h"

@implementation FIRCLSControllerData

- (instancetype)initWithGoogleAppID:(NSString *)googleAppID
                    googleTransport:(GDTCORTransport *)googleTransport
                      installations:(FIRInstallations *)installations
                          analytics:(nullable id<FIRAnalyticsInterop>)analytics
                        fileManager:(FIRCLSFileManager *)fileManager
                        dataArbiter:(FIRCLSDataCollectionArbiter *)dataArbiter
                           settings:(FIRCLSSettings *)settings {
  self = [super init];
  if (!self) {
    return nil;
  }

  _googleAppID = googleAppID;
  _googleTransport = googleTransport;
  _installations = installations;
  _analytics = analytics;
  _fileManager = fileManager;
  _dataArbiter = dataArbiter;
  _settings = settings;

  _appIDModel = [[FIRCLSApplicationIdentifierModel alloc] init];
  _installIDModel = [[FIRCLSInstallIdentifierModel alloc] initWithInstallations:installations];
  _executionIDModel = [[FIRCLSExecutionIdentifierModel alloc] init];

  NSString *sdkBundleID = FIRCLSApplicationGetSDKBundleID();
  _operationQueue = [NSOperationQueue new];
  [_operationQueue setMaxConcurrentOperationCount:1];
  [_operationQueue setName:[sdkBundleID stringByAppendingString:@".work-queue"]];

  _dispatchQueue = dispatch_queue_create("com.google.firebase.crashlytics.startup", 0);
  _operationQueue.underlyingQueue = _dispatchQueue;

  return self;
}

@end
