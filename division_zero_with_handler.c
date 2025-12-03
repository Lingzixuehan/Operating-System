#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>

// SIGFPE信号处理函数
void sigfpe_handler(int signum)
{
    printf("\n===========================================\n");
    printf("捕获到信号: SIGFPE (信号编号: %d)\n", signum);
    printf("异常类型: 浮点异常 (Floating Point Exception)\n");
    printf("原因: 除数为0\n");
    printf("===========================================\n");
    exit(1);
}

int main(void)
{
    int a, b, c;

    // 注册SIGFPE信号处理函数
    printf("注册SIGFPE信号处理函数...\n");
    signal(SIGFPE, sigfpe_handler);

    for ( ; ; )
    {
        printf("\n输入被除数: ");
        if (scanf("%d", &a) != 1) break;

        printf("输入除数: ");
        if (scanf("%d", &b) != 1) break;

        printf("\n执行除法运算: %d / %d\n", a, b);

        // 这里会在b=0时触发SIGFPE信号
        c = a / b;

        printf("结果: %d / %d = %d\n", a, b, c);
    }

    return 0;
}
