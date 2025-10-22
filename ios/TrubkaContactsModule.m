#import <React/RCTBridgeModule.h>
#import "react_native_trubka_contacts-Swift.h"

@interface TrubkaContactsModule : NSObject <RCTBridgeModule>
@end

@implementation TrubkaContactsModule

RCT_EXPORT_MODULE(TrubkaContacts)

- (dispatch_queue_t)methodQueue {
  return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
}

RCT_REMAP_METHOD(process,
  process:(NSArray<NSDictionary *> *)contacts
  options:(NSDictionary *)options
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject)
{
  @try {
    NSArray *result = [TrubkaContactsImpl.shared processWithContacts:contacts options:options ?: @{}];
    resolve(result);
  } @catch (NSException *e) {
    reject(@"trubka_contacts_error", e.reason, nil);
  }
}

@end
