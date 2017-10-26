//
//  ADVMOCharacter.h
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

@import CoreData;
@import ModularCoreData;


@interface ADVMOCharacter : NSManagedObject <MCDDatabaseEntityDataSource>

@property (nullable, nonatomic, strong) NSString *name;
@property (nullable, nonatomic, strong) UIImage *portrait;

@end
