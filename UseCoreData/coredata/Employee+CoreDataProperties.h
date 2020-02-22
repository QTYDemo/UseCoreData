//
//  Employee+CoreDataProperties.h
//  UseCoreData
//
//  Created by 覃团业 on 2020/2/22.
//  Copyright © 2020 覃团业. All rights reserved.
//
//

#import "Employee+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Employee (CoreDataProperties)

+ (NSFetchRequest<Employee *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *brithday;
@property (nonatomic) float height;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
