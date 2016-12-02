//
//  ViewController.m
//  ThreadDemo
//
//  Created by liushengnan on 2016/12/2.
//  Copyright © 2016年 liushengnan. All rights reserved.
//

#import "ViewController.h"

#define kURL @"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"

@interface ViewController ()
{
    int tickets;
    int count;
    NSThread *ticketsThreadOne;
    NSThread *ticketsThreadTwo;
    NSCondition *ticketsCondition;
    NSLock *ticketsLock;
}
@property (weak, nonatomic) IBOutlet UIImageView *pictureImage;

@end

/*
 *  http://blog.jobbole.com/69019/
 *  多线程的使用方法
 */
//xixitijiaole
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self customThread];
    
    [self displayBuyTickets];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}
#pragma mark - 演示买票
- (void)displayBuyTickets
{
    tickets = 20;
    count = 0;
    ticketsLock = [[NSLock alloc] init];
    ticketsCondition = [[NSCondition alloc] init];
    ticketsThreadOne = [[NSThread alloc] initWithTarget:self selector:@selector(buyTicket) object:nil];
    [ticketsThreadOne setName:@"ticketsThreadOne"];
    [ticketsThreadOne start];
    
    ticketsThreadTwo = [[NSThread alloc] initWithTarget:self selector:@selector(buyTicket) object:nil];
    [ticketsThreadTwo setName:@"ticketsThreadTwo"];
    [ticketsThreadTwo start];
    
    NSThread *ticketsThreadThree = [[NSThread alloc] initWithTarget:self selector:@selector(threadExecuteByOrder) object:nil];
    [ticketsThreadThree setName:@"ticketsThreadThree"];
    [ticketsThreadThree start];
    
}
- (void)threadExecuteByOrder{
    while (TRUE) {
        [ticketsCondition lock];
        [NSThread sleepForTimeInterval:3];
        [ticketsCondition signal];
        [ticketsCondition unlock];
        NSLog(@"顺序：%@",[[NSThread currentThread] name]);
    }
}
- (void)buyTicket{
    while (TRUE) {
        //两种上锁的方式
        [ticketsCondition lock];
        //wait是等待，我加了一个 线程3 去唤醒其他两个线程锁中的wait。
        [ticketsCondition wait];
        [ticketsLock lock];
        if (tickets >= 0) {
            [NSThread sleepForTimeInterval:0.09];
            count = 100 - tickets;
            
            NSLog(@"当前票数是:%d,售出:%d,线程名:%@",tickets,count,[[NSThread currentThread] name]);
            tickets--;
        }else{
            break;
        }
        [ticketsLock unlock];
        [ticketsCondition unlock];
    }
}
#pragma mark - 加载图片
- (void)customThread
{
    //第一种用NSThread
//    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadImage:) object:kURL];
//    [thread start];
    
    //第二种用NSOperation的子类
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:kURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //设置线程池中的线程数，也就是并发操作数，默认情况下是-1，表示没有限制，这样会同时运行队列中的全部操作
    [queue setMaxConcurrentOperationCount:5];
    [queue addOperation:operation];

}
- (void)downloadImage:(NSString *)url{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image = [[UIImage alloc] initWithData:data];
    if (image) {
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];
    }
}
- (void)updateUI:(UIImage *)image{
    self.pictureImage.image = image;
}
@end
