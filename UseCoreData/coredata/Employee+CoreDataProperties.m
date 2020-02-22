//
//  Employee+CoreDataProperties.m
//  UseCoreData
//
//  Created by 覃团业 on 2020/2/22.
//  Copyright © 2020 覃团业. All rights reserved.
//
//

#import "Employee+CoreDataProperties.h"

@implementation Employee (CoreDataProperties)

+ (NSFetchRequest<Employee *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
}

@dynamic brithday;
@dynamic height;
@dynamic name;

@end
