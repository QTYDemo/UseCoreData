//
//  ViewController.m
//  UseCoreData
//
//  Created by 覃团业 on 2020/2/22.
//  Copyright © 2020 覃团业. All rights reserved.
//

#import "ViewController.h"
#import <coredata/CoreData.h>
#import "Employee+CoreDataClass.h"

@interface ViewController ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPersistentStoreCoordinator *psc;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self insertEmployee];
    [self queryEmployee];
    [self updateLxzEmployee];
    [self queryEmployee];
    [self deleteLxzEmployee];
    [self queryEmployee];
}

#pragma mark - 插入操作
- (void)insertEmployee {
    //创建托管对象，并指明创建的托管对象所属实体名
    Employee *emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.context];
    emp.name = @"lxz";
    emp.height = 1.7;
    emp.brithday = [NSDate date];
    
    // 通过上下文保存对象，并在保存前判断是否有更改
    NSError *error = nil;
    if ([self.context hasChanges]) {
        [self.context save:&error];
    }
    
    // 错误处理
    if (error) {
        NSLog(@"insert employee error: %@", error);
    }
}

#pragma mark - 查询操作
- (void)queryEmployee {
    // 建立获取数据的请求对象，指明操作的实体为Employee
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    
    // 执行获取操作，获取所有Employee托管对象
    NSError *error = nil;
    NSArray<Employee *> *employees = [self.context executeFetchRequest:request error:&error];
    
    if (!error) {
        [employees enumerateObjectsUsingBlock:^(Employee * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"queryEmployee=>name: %@, height: %f, birthday: %@", obj.name, obj.height, obj.brithday);
        }];
    } else {
        NSLog(@"查询失败： %@", error);
    }
}

#pragma mark - 修改操作
- (void)updateLxzEmployee {
    // 建立获取数据的请求对象，并指明操作的实体为Employee
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    
    // 创建谓语对象，设置过虑条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", @"lxz"];
    request.predicate = predicate;
    
    // 执行获取请求，获取到符合要求的托管对象
    NSError *error = nil;
    NSArray<Employee *> *employees = [self.context executeFetchRequest:request error:&error];
    
    if (!error) {
        // 遍历符合更新要求的对象数组，执行更新操作
        [employees enumerateObjectsUsingBlock:^(Employee * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.height = 3.0f;
        }];
        
        // 将上面的修改进行存储
        error = nil;
        if (self.context.hasChanges) {
            [self.context save:&error];
        }
        // 错误处理
        if (error) {
            NSLog(@"updateLxzEmployee 保存失败: %@", error);
        }
    } else {
        // 错误处理
        if (error) {
            NSLog(@"updateLxzEmployee 查询失败: %@", error);
        }
    }
}

#pragma mark - 删除操作
- (void)deleteLxzEmployee {
    // 建立获取数据的请求对象，指明对Employee实体进行删除操作
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    
    // 创建谓语对象，过虑出符合要求的对象，也就是要删除的对象
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", @"lxz"];
    request.predicate = predicate;
    
    // 执行获取操作，找到要删除的对象
    NSError *error = nil;
    NSArray<Employee *> *employees = [self.context executeFetchRequest:request error:&error];
    
    if (!error) {
        // 遍历符合删除要求的对象数组，执行删除操作
        [employees enumerateObjectsUsingBlock:^(Employee * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.context deleteObject:obj];
        }];
        
        // 保存上下文
        error = nil;
        if (self.context.hasChanges) {
            [self.context save:&error];
        }
        
        // 错误处理
        if (error) {
            NSLog(@"deleteLxzEmployee 保存失败: %@", error);
        }
    } else {
        // 错误处理
        if (error) {
            NSLog(@"deleteLxzEmployee 查询失败: %@", error);
        }
    }
}

#pragma mark - 懒加载
- (NSManagedObjectContext *)context {
    if (self.psc == nil) {
        return nil;
    }
    
    if (_context == nil) {
        // 创建上下文对象，并发队列设置为主队列
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        // 上下文对象设置属性为持久化存储器
        _context.persistentStoreCoordinator = self.psc;
    }
    return _context;
}

- (NSPersistentStoreCoordinator *)psc {
    if (!_psc) {
        // 创建托管对象模型，并使用ManualCoreData.xcdatamodeId路径当中初始化参数
        NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"UseCoreData" withExtension:@"momd"];
        if (@available(iOS 11.0, *)) {} else {
            modelPath = [modelPath URLByAppendingPathComponent:@"UseCoreData.mom"];
        }
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
        
        // 创建持久化存储调度器
        _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // 创建并关联SQLite数据库文件，如果已经存在则不会重复创建
        NSString *dataPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        dataPath = [dataPath stringByAppendingFormat:@"/%@.sqlite", @"UseCoreData"];
        NSError *error = nil;
        [_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:nil error:&error];
        if (error) {
            NSLog(@"Init persistentStoreCoordinator error: %@", error);
            _psc = nil;
        }
    }
    return _psc;
}

@end
