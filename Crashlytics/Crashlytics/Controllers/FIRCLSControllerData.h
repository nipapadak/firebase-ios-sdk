//
//  FIRCLSControllerData.h
//  Pods
//
//  Created by Sam Edson on 1/26/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FIRCLSFileManager;
@class FIRInstallations;
@class FIRCLSDataCollectionArbiter;
@class FIRCLSApplicationIdentifierModel;
@class FIRCLSInstallIdentifierModel;
@class FIRCLSExecutionIdentifierModel;
@class FIRCLSSettings;
@class FIRCLSLaunchMarker;
@class GDTCORTransport;
@protocol FIRAnalyticsInterop;

@interface FIRCLSControllerData : NSObject

- (instancetype)initWithGoogleAppID:(NSString *)googleAppID
                    googleTransport:(GDTCORTransport *)googleTransport
                      installations:(FIRInstallations *)installations
                          analytics:(nullable id<FIRAnalyticsInterop>)analytics
                        fileManager:(FIRCLSFileManager *)fileManager
                        dataArbiter:(FIRCLSDataCollectionArbiter *)dataArbiter
                           settings:(FIRCLSSettings *)settings NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property(nonatomic, readonly) NSString *googleAppID;

@property(nonatomic, strong) GDTCORTransport *googleTransport;

@property(nonatomic, strong) FIRInstallations *installations;

@property(nonatomic, strong) id<FIRAnalyticsInterop> analytics;

@property(nonatomic, strong) FIRCLSFileManager *fileManager;

@property(nonatomic, strong) FIRCLSDataCollectionArbiter *dataArbiter;

// Uniquely identifies a build / binary of the app
@property(nonatomic, strong) FIRCLSApplicationIdentifierModel *appIDModel;

// Uniquely identifies an install of the app
@property(nonatomic, strong) FIRCLSInstallIdentifierModel *installIDModel;

// Uniquely identifies a run of the app
@property(nonatomic, strong) FIRCLSExecutionIdentifierModel *executionIDModel;

// Settings fetched from the server
@property(nonatomic, strong) FIRCLSSettings *settings;

// Writes a file during launch, and deletes it at the end. Existence
// of this file on the next run means there was a crash at launch, and
// Crashlytics should block startup on uploading the crash.
@property(nonatomic, strong) FIRCLSLaunchMarker *launchMarker;

@property(nonatomic, strong) dispatch_queue_t dispatchQueue;

@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

NS_ASSUME_NONNULL_END
