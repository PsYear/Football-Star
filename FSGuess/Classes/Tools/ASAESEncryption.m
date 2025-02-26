//
//  ASAESEncryption.m
//  FSGuess
//
//  Created by CarlHwang on 14-3-17.
//  Copyright (c) 2014年 AfroStudio. All rights reserved.
//

#import "ASAESEncryption.h"
#import <CommonCrypto/CommonCryptor.h>

static char encodingTable[64] =
{
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
};

@implementation NSData (Encryption)

- (NSData *)AES256EncryptWithKey:(NSString *)key   //加密
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}


- (NSData *)AES256DecryptWithKey:(NSString *)key   //解密
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

#pragma mark -

+(NSData *)dataWithBase64EncodedString:(NSString *)string{
    return [[[NSData allocWithZone:nil] initWithBase64EncodeString:string] autorelease];
}

- (id)initWithBase64EncodeString:(NSString *)string {
    NSMutableData *mutableData = nil;
    if (string)
    {
        unsigned long ixtext=0, lentext=0;
        unsigned char ch=0, inbuf[4], outbuf[3];
        short i=0, ixinbuf=0;
        BOOL flignore=NO, flendtext =NO;
        NSData *base64Data=nil;
        const unsigned char *base64Bytes=nil;
        
        base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
        base64Bytes = [base64Data bytes];
        mutableData = [NSMutableData dataWithCapacity:base64Data.length];
        lentext = base64Data.length;
        
        while (true)
        {
            if (ixtext >= lentext) break;
            ch = base64Bytes[ixtext++];
            flignore = NO;
            
            if ((ch >= 'A') && (ch <= 'Z')) ch = ch - 'A';
            else if ((ch >= 'a') && (ch <= 'z')) ch = ch - 'a' + 26;
            else if ((ch >= '0') && (ch <= '9')) ch = ch - '0' + 52;
            else if (ch == '+') ch = 62;
            else if (ch == '=') flendtext = YES;
            else if (ch == '/') ch = 63;
            else flignore = YES;
            
            if (!flignore)
            {
                short ctcharsinbuf = 3;
                BOOL flbreak = NO;
                
                if (flendtext)
                {
                    if (!ixinbuf) break;
                    if ((ixinbuf == 1) || (ixinbuf == 2)) ctcharsinbuf = 1;
                    else ctcharsinbuf = 2;
                    
                    ixinbuf = 3;
                    flbreak = NO;
                }
                
                inbuf [ixinbuf++] = ch;
                
                if (ixinbuf == 4)
                {
                    ixinbuf = 0;
                    outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                    outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                    outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                    
                    for (i = 0; i < ctcharsinbuf; i++) {
                        [mutableData appendBytes: &outbuf[i] length: 1];
                    }
                }
                
                if (flbreak) break;
            }
        }
    }
    self = [self initWithData:mutableData];
    return self;
}

#pragma mark - 

-(NSString *)base64Encoding{
    return [self base64EncodingWithLineLength:0];
}

- (NSString *)base64EncodingWithLineLength:(NSUInteger)lineLength{
    
    const unsigned char *bytes = [self bytes];
    NSMutableString *result = [NSMutableString stringWithCapacity:self.length];
    unsigned long ixtext = 0;
    unsigned long lentext = self.length;
    long ctremaining = 0;
    unsigned char inbuf[3], outbuf[4];
    unsigned short i = 0;
    unsigned short charsonline = 0, ctcopy = 0;
    unsigned long ix = 0;
    
    while( YES )
    {
        ctremaining = lentext - ixtext;
        if( ctremaining <= 0 ) break;
        
        for( i = 0; i < 3; i++ )
        {
            ix = ixtext + i;
            if( ix < lentext ) inbuf[i] = bytes[ix];
            else inbuf [i] = 0;
        }
        
        outbuf [0] = (inbuf [0] & 0xFC) >> 2;
        outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
        outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
        outbuf [3] = inbuf [2] & 0x3F;
        ctcopy = 4;
        
        switch( ctremaining )
        {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for( i = 0; i < ctcopy; i++ )
            [result appendFormat:@"%c", encodingTable[outbuf[i]]];
        
        for( i = ctcopy; i < 4; i++ )
            [result appendString:@"="];
        
        ixtext += 3;
        charsonline += 4;
        if( lineLength > 0 )
        {
            if (charsonline >= lineLength)
            {
                charsonline = 0;
                [result appendString:@"\n"];
            }
        }
    }
    
    return [NSString stringWithString:result];
}

@end

@implementation NSString (Encryption)

-(NSString *)AES256DecryptWithKey:(NSString *)key{
    NSData *encryptData = [NSData dataWithBase64EncodedString:self];
    NSData *plainData = [encryptData AES256DecryptWithKey:key];
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return [plainString autorelease];
}

-(NSString *)AES256EncryptWithKey:(NSString *)key{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData = [plainData AES256EncryptWithKey:key];
    
    NSString *encryptString = [encryptData base64Encoding];
    
    return encryptString;
}

@end
