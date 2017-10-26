//
//  MCDDatabase+Private.h
//  Created by Vladimir Ozerov on 28/07/16.
//  Copyright © 2016 SberTech. All rights reserved.
//

#import "MCDDatabase.h"


@interface MCDDatabase ()

/**
 Подготовить папку для сохранения в нее хранилища БД
 @discussion Если директории нет, то создается
 @param filename Имя файла без расширения
 @param error Указатель для передачи ошибки
 @return URL директории
 */
+ (NSURL *)prepareFolderForStoreWithFilename:(NSString *)filename error:(out NSError **)error;

@end
