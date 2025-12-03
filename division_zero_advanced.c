#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <setjmp.h>

// 全局跳转缓冲区
static sigjmp_buf jmpbuf;

// SIGFPE信号处理函数
static void sig_divzero(int signum)
{
    printf("\n===========================================\n");
    printf("捕获到信号: SIGFPE (信号编号: %d)\n", signum);
    printf("异常类型: 除数为0\n");
    printf("正在通过siglongjmp跳转回主程序...\n");
    printf("===========================================\n");

    // 跳转回sigsetjmp位置，返回值设为1
    siglongjmp(jmpbuf, 1);
}

int main(void)
{
    int a, b, c;

    // 注册SIGFPE信号处理函数
    if (signal(SIGFPE, sig_divzero) == SIG_ERR) {
        printf("无法注册信号处理函数\n");
        exit(1);
    }

    printf("程序启动：除零异常处理演示（使用sigsetjmp/siglongjmp）\n");
    printf("========================================================\n\n");

    // 无限循环，持续进行除法运算
    for ( ; ; )
    {
        // sigsetjmp: 保存当前执行环境和信号掩码
        // 返回值：首次调用返回0，siglongjmp跳转回来返回非0值
        if (sigsetjmp(jmpbuf, 1) == 0) {
            // 首次执行或正常执行路径
            printf("输入被除数: ");
            if (scanf("%d", &a) != 1) {
                printf("输入错误，程序退出\n");
                break;
            }

            printf("输入除数: ");
            if (scanf("%d", &b) != 1) {
                printf("输入错误，程序退出\n");
                break;
            }

            printf("\n执行除法运算: %d / %d\n", a, b);

            // 这里可能触发SIGFPE信号（当b=0时）
            c = a / b;

            // 如果没有异常，正常打印结果
            printf("结果: %d / %d = %d\n\n", a, b, c);

        } else {
            // siglongjmp跳转回来的路径
            printf("\n异常已处理，程序继续运行\n");
            printf("可以继续输入新的数据\n\n");

            // 清空输入缓冲区
            int ch;
            while ((ch = getchar()) != '\n' && ch != EOF);
        }
    }

    printf("\n程序正常退出\n");
    return 0;
}
