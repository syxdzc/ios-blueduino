//
//  ABCustomProtocol.m
//  Example
//
//  Created by liaojinhua on 14-8-21.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import "ABCustomProtocol.h"
#import "ABArduinoDefine.h"

@implementation ABCustomProtocol

@synthesize delegate;

- (void)queryTotalPinCount
{
    uint8_t buf[] = {'C'};
    uint8_t len = 1;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [self write:nsData];
}
- (void)queryPinAll
{
    uint8_t buf[] = {'A'};
    uint8_t len = 1;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [self write:nsData];
}
- (void)setPinMode:(uint8_t)pin mode:(uint8_t)mode
{
    uint8_t buf[] = {'S', pin, mode};
    uint8_t len = 3;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [self write:nsData];
}
- (void)digitalWrite:(uint8_t)pin value:(uint8_t)value
{
    uint8_t buf[] = {'T', pin, value};
    uint8_t len = 3;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [self write:nsData];
}
- (void)setPinPWM:(uint8_t)pin pwm:(uint8_t)pwm
{
    uint8_t buf[] = {'N', pin, pwm};
    uint8_t len = 3;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [self write:nsData];
}

- (void)parseData:(unsigned char*)data length:(int)lenght
{
    uint8_t i = 0;
    
    while (i < lenght)
    {
        uint8_t type = data[i++];
        
        switch (type)
        {
            case 'C': // report total pin count of the board
                if (i < lenght) {
                    [self.delegate protocolDidReceiveTotalPinCount:data[i++]];
                }
                break;
                
            case 'P': // report pin capability
            {
                if (i + 1 < lenght) {
                    uint8_t pin = data[i++];
                    [self.delegate protocolDidReceivePinCapability:pin value:data[i++]];
                }
            }
                break;
            case 'M': // report pin mode
            {
                if (i + 1 < lenght) {
                    uint8_t pin = data[i++];
                    [self.delegate protocolDidReceivePinMode:pin mode:data[i++]];
                }
            }
                break;
                
            case 'G': // report pin data
            {
                if (i + 2 < lenght) {
                    uint8_t pin = data[i++];
                    uint8_t mode = data[i++];
                    uint8_t value = data[i++];
                    
                    uint8_t _mode = mode & 0x0F;
                    
                    if ((_mode == INPUT) || (_mode == OUTPUT)) {
                        [self.delegate protocolDidReceivePinData:pin mode:_mode value:value];
                    }
                    else if (_mode == ANALOG) {
                        uint16_t analogValue = ((mode >> 4) << 8);
                        [self.delegate protocolDidReceivePinData:pin mode:_mode value:value + analogValue];
                    }
                    else if (_mode == PWM) {
                        [self.delegate protocolDidReceivePinData:pin mode:_mode value:value];
                    }
                }
            }
                break;
        }
    }
}


#pragma mark - private
- (void)write:(NSData *)data
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(protocolDidPrepareDataToWrite:)]) {
        [self.delegate protocolDidPrepareDataToWrite:data];
    }
}

@end
