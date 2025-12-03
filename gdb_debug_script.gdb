# GDB调试脚本：除零异常分析

# 设置输入
set pagination off
set confirm off

# 显示调试信息
echo ========================================\n
echo GDB调试演示：除零异常处理\n
echo ========================================\n\n

# 设置断点
echo [1] 设置断点...\n
break main
break sig_divzero
break 48

# 开始运行
echo [2] 启动程序...\n
run <<EOF
10
0
EOF

echo \n========================================\n
echo [3] 在main函数入口，查看初始状态\n
echo ========================================\n
info frame
info registers eip esp ebp
echo \n

# 继续到sigsetjmp
echo [4] 继续执行到sigsetjmp之前（第48行）...\n
continue

echo \n========================================\n
echo [5] 查看sigsetjmp时的栈帧\n
echo ========================================\n
backtrace
info frame
info locals
x/10x $esp
echo \n

# 继续执行，等待触发信号
echo [6] 继续执行，将触发除零异常...\n
continue

echo \n========================================\n
echo [7] 捕获到SIGFPE信号，进入sig_divzero函数\n
echo ========================================\n
backtrace
info frame
info registers eip esp ebp
info args
echo \n

# 查看栈内容
echo [8] 查看当前栈内容（信号处理栈）\n
x/30x $esp
echo \n

# 单步执行到siglongjmp
echo [9] 单步执行到siglongjmp调用前...\n
next
next
next
next

echo \n========================================\n
echo [10] 即将调用siglongjmp，查看jmpbuf内容\n
echo ========================================\n
print jmpbuf
echo \n

# 执行siglongjmp
echo [11] 执行siglongjmp，跳转回main...\n
next

echo \n========================================\n
echo [12] siglongjmp后，查看恢复的栈帧\n
echo ========================================\n
backtrace
info frame
info registers eip esp ebp
echo \n

# 退出
echo [13] 调试结束\n
quit
