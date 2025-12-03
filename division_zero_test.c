#include <unistd.h>
#include <stdio.h>

int main(void)
{
    int a, b, c;

    for ( ; ; )
    {
        printf("输入被除数\n");
        scanf("%d", &a);

        printf("输入除数\n");
        scanf("%d", &b);

        c = a / b;

        printf("%d / %d = %d\n", a, b, c);
    }
}
