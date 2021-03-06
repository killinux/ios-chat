//
//  WFCCKickoffGroupMemberNotificaionContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/9/20.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCKickoffGroupMemberNotificaionContent.h"
#import "WFCCIMService.h"
#import "WFCCNetworkService.h"
#import "Common.h"


@implementation WFCCKickoffGroupMemberNotificaionContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [[WFCCMessagePayload alloc] init];
    payload.contentType = [self.class getContentType];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.operateUser) {
        [dataDict setObject:self.operateUser forKey:@"o"];
    }
    if (self.kickedMembers) {
        [dataDict setObject:self.kickedMembers forKey:@"ms"];
    }
    
    payload.binaryContent = [NSJSONSerialization dataWithJSONObject:dataDict
                                                            options:kNilOptions
                                                              error:nil];
    
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:payload.binaryContent
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.operateUser = dictionary[@"o"];
        self.kickedMembers = dictionary[@"ms"];
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_KICKOF_GROUP_MEMBER;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST;
}



+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest {
    return [self formatNotification];
}

- (NSString *)formatNotification {
    NSString *formatMsg;
    if ([[WFCCNetworkService sharedInstance].userId isEqualToString:self.operateUser]) {
        formatMsg = @"你把";
    } else {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.operateUser refresh:NO];
        if (userInfo.displayName.length > 0) {
            formatMsg = [NSString stringWithFormat:@"%@把", userInfo.displayName];
        } else {
            formatMsg = [NSString stringWithFormat:@"用户<%@>把", self.operateUser];
        }
    }
    
    for (NSString *member in self.kickedMembers) {
        if ([member isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            formatMsg = [formatMsg stringByAppendingString:@" 你"];
        } else {
            WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:member refresh:NO];
            if (userInfo.displayName.length > 0) {
                formatMsg = [formatMsg stringByAppendingFormat:@" %@", userInfo.displayName];
            } else {
                formatMsg = [formatMsg stringByAppendingFormat:@" 用户<%@>", member];
            }

        }
    }
    formatMsg = [formatMsg stringByAppendingString:@"移出群聊"];
    return formatMsg;
}
@end
