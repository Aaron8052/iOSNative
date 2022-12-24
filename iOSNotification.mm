#import <UserNotifications/UserNotifications.h>
#import "iOSNative.h"

static UNUserNotificationCenter *notificationCenter;
static BOOL notificationGranted;

@implementation iOSNotification

+(void)init{
    if(notificationCenter == nil)
    {
        notificationCenter = [UNUserNotificationCenter currentNotificationCenter];

        [notificationCenter requestAuthorizationWithOptions:
         (UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
         completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
            notificationGranted = granted;
            if(error != nil){
                LOG([NSString stringWithFormat: @"NotificationErrorDes: %@", [error localizedDescription]]);
                LOG([NSString stringWithFormat: @"NotificationErrorReason: %@", [error localizedFailureReason]]);
            }
        }];
    }
    else
    {
        [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings){
            notificationGranted = settings.authorizationStatus == UNAuthorizationStatusAuthorized;
        }];
    }
}

+(void)PushNotification:(NSString *)msg
title:(NSString *)title
identifier:(NSString *)identifier
delay:(NSInteger)time{
    [iOSNotification init];
    if(notificationGranted){
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = title ?: @"";
        content.body = msg;
        content.sound = [UNNotificationSound defaultSound];
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        
        [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"Error: %@", error);
        }];
    }
    
}


+(void)RemovePendingNotifications:(NSString *)identifier{
    if(notificationGranted){
        [notificationCenter removePendingNotificationRequestsWithIdentifiers:@[identifier]];
    }

}

+(void)RemoveAllPendingNotificaions{
    if(notificationGranted){
        [notificationCenter removeAllPendingNotificationRequests];
    }
}
@end


    

