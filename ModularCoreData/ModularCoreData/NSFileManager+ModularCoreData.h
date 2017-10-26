//
//  NSFileManager+ModularCoreData.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 02/10/2017.
//  Copyright © 2017 Vladimir Ozerov. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Категория для упрощения работы с файлами кэша
 */
@interface NSFileManager (ModularCoreData)

/**
 URL файла с указанным именем в папке кэша.
 @param fileName Имя файла
 @return file URL
 */
+ (NSURL *)cacheFileURLWithFileName:(NSString *)fileName;

/**
 URL директории с указанным именем в папке кэша.
 @param directoryName Имя файла
 @return directory URL
 */
+ (NSURL *)cacheDirectoryURLWithDirectoryName:(NSString *)directoryName;

@end
