//
//  ADVMOVillain+Admin.h
//  FANMultiuniverse
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 FANs. All rights reserved.
//

@import ADVCore;


@interface ADVMOVillain (Multiuniverse)

@property (nullable, nonatomic, strong) NSNumber *isAlterHero;

@end


@interface ADVMOVillainMultiuniverseExtension: NSObject <MCDDatabaseEntityDataSource>

@end
