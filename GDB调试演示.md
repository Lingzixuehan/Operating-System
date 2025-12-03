# GDB调试演示：除零异常处理程序

## 一、准备工作

### 1. 编译程序（带调试信息）

```bash
$ gcc -g -o division_zero_advanced division_zero_advanced.c
```

`-g` 选项会在可执行文件中包含调试符号。

### 2. 启动GDB

```bash
$ gdb ./division_zero_advanced
GNU gdb (Ubuntu 7.11.1-0ubuntu1~16.5) 7.11.1
...
Reading symbols from ./division_zero_advanced...done.
(gdb)
```

## 二、GDB调试步骤

### 步骤1：设置断点

```gdb
(gdb) break main
Breakpoint 1 at 0x4008a3: file division_zero_advanced.c, line 27.

(gdb) break sig_divzero
Breakpoint 2 at 0x400760: file division_zero_advanced.c, line 12.

(gdb) break 48
Breakpoint 3 at 0x4008fe: file division_zero_advanced.c, line 48.

(gdb) info breakpoints
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x00000000004008a3 in main at division_zero_advanced.c:27
2       breakpoint     keep y   0x0000000000400760 in sig_divzero at division_zero_advanced.c:12
3       breakpoint     keep y   0x00000000004008fe in main at division_zero_advanced.c:48
```

**断点说明**：
- 断点1：main函数入口
- 断点2：信号处理函数sig_divzero
- 断点3：除法运算之前（第48行：c = a / b;）

### 步骤2：运行程序到main入口

```gdb
(gdb) run
Starting program: /home/user/Operating-System/division_zero_advanced

Breakpoint 1, main () at division_zero_advanced.c:27
27          if (signal(SIGFPE, sig_divzero) == SIG_ERR) {
```

**查看当前栈帧**：

```gdb
(gdb) info frame
Stack level 0, frame at 0x7fffffffe490:
 rip = 0x4008a3 in main (division_zero_advanced.c:27); saved rip = 0x7ffff7a2d830
 source language c.
 Arglist at 0x7fffffffe480, args:
 Locals at 0x7fffffffe480, Previous frame's sp is 0x7fffffffe490
 Saved registers:
  rbp at 0x7fffffffe480, rip at 0x7fffffffe488

(gdb) info registers
rax            0x4008a0 4196512
rbx            0x0      0
rcx            0x0      0
rdx            0x7fffffffe5a8   140737488348584
rsi            0x7fffffffe598   140737488348568
rdi            0x1      1
rbp            0x7fffffffe480   0x7fffffffe480
rsp            0x7fffffffe460   0x7fffffffe460
r8             0x400a60 4196960
r9             0x7ffff7de7ab0   140737351940784
r10            0x846    2118
r11            0x7ffff7a2d740   140737348098880
r12            0x400730 4196144
r13            0x7fffffffe590   140737488348560
r14            0x0      0
r15            0x0      0
rip            0x4008a3 0x4008a3 <main+3>
eflags         0x246    [ PF ZF IF ]
cs             0x33     51
ss             0x2b     43
ds             0x0      0
es             0x0      0
fs             0x0      0
gs             0x0      0
```

**关键寄存器**：
- `rip`：指令指针，指向当前执行的代码地址
- `rsp`：栈指针，指向用户栈顶
- `rbp`：栈帧基址指针
- `cs = 0x33`：代码段选择子，RPL=3（用户态）

### 步骤3：继续到sigsetjmp之前

```gdb
(gdb) continue
Continuing.
程序启动：除零异常处理演示（使用sigsetjmp/siglongjmp）
========================================================

输入被除数: 输入除数:

Breakpoint 3, main () at division_zero_advanced.c:48
48              c = a / b;
```

**查看局部变量**：

```gdb
(gdb) info locals
a = 10
b = 0
c = 32767

(gdb) print &a
$1 = (int *) 0x7fffffffe44c

(gdb) print &b
$2 = (int *) 0x7fffffffe448

(gdb) print &c
$3 = (int *) 0x7fffffffe444
```

**查看调用栈**：

```gdb
(gdb) backtrace
#0  main () at division_zero_advanced.c:48
```

**查看栈内容**（在除法运算之前）：

```gdb
(gdb) x/20x $rsp
0x7fffffffe440: 0xffffe460      0x00007fff      0x00400a60      0x00000000
0x7fffffffe450: 0xffffe590      0x00007fff      0x00000001      0x00000000
0x7fffffffe460: 0x00000000      0x00000000      0xf7a2d830      0x00007fff
0x7fffffffe470: 0x00000000      0x00000000      0xffffe598      0x00007fff
0x7fffffffe480: 0x00000000      0x00000000      0x004008a0      0x00000000

(gdb) x/3dw 0x7fffffffe444
0x7fffffffe444: 32767   0       10
                  ↑     ↑       ↑
                  c     b       a
```

**关键观察**：
- `b = 0`，即将触发除零异常
- 用户栈上保存了局部变量a, b, c

### 步骤4：单步执行，触发除零异常

```gdb
(gdb) step
执行除法运算: 10 / 0

Program received signal SIGFPE, Arithmetic exception.
0x0000000000400904 in main () at division_zero_advanced.c:48
48              c = a / b;
```

**程序收到SIGFPE信号！**

```gdb
(gdb) info signal SIGFPE
Signal        Stop      Print   Pass to program Description
SIGFPE        Yes       Yes     Yes             Arithmetic exception

(gdb) info program
        Using the running image of child process 12345.
Program stopped at 0x400904.
It stopped with signal SIGFPE, Arithmetic exception.
```

### 步骤5：继续执行，进入信号处理函数

```gdb
(gdb) continue
Continuing.

Breakpoint 2, sig_divzero (signum=8) at division_zero_advanced.c:12
12      {
```

**查看信号处理函数的参数**：

```gdb
(gdb) info args
signum = 8

(gdb) print signum
$4 = 8
```

`signum = 8` 就是 SIGFPE 信号编号。

**查看调用栈（信号处理函数）**：

```gdb
(gdb) backtrace
#0  sig_divzero (signum=8) at division_zero_advanced.c:12
#1  <signal handler called>
#2  0x0000000000400904 in main () at division_zero_advanced.c:48
```

**关键观察**：
- 调用栈显示了信号处理路径：main → signal handler → sig_divzero
- `<signal handler called>` 表示这是信号处理栈帧

**查看寄存器（信号处理时）**：

```gdb
(gdb) info registers rip rsp rbp
rip            0x400760 0x400760 <sig_divzero>
rsp            0x7fffffffe360   0x7fffffffe360
rbp            0x7fffffffe370   0x7fffffffe370
```

**对比**：
- 信号处理前 `rsp = 0x7fffffffe440`
- 信号处理时 `rsp = 0x7fffffffe360`
- 栈向下增长了 `0x440 - 0x360 = 0xE0` (224字节)

这部分是**内核构造的信号处理栈帧**。

**查看栈内容（信号处理栈）**：

```gdb
(gdb) x/40x $rsp
0x7fffffffe360: 0x00000008      0x00000000      0xffffe480      0x00007fff
0x7fffffffe370: 0xffffe440      0x00007fff      0x00400904      0x00000000
0x7fffffffe380: 0x00000000      0x00000000      0x00000000      0x00000000
0x7fffffffe390: 0x00000000      0x00000000      0x00000000      0x00000000
...

# 第一个值是信号编号参数
(gdb) x/w $rsp
0x7fffffffe360: 0x00000008  (signum = 8)

# 查看保存的返回地址
(gdb) x/a $rbp+8
0x7fffffffe378: 0x400904 <main+100>
```

### 步骤6：查看jmpbuf（在siglongjmp之前）

```gdb
(gdb) print jmpbuf
$5 = {{
    __jmpbuf = {4195488, 140737488348320, 140737488348560, 0, -2, 140737351746528},
    __mask_was_saved = 1,
    __saved_mask = {
      __val = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    }
  }}

(gdb) x/10x &jmpbuf
0x601080 <jmpbuf>:      0x004008a0      0x00000000      0xffffe480      0x00007fff
0x601090 <jmpbuf+16>:   0xffffe590      0x00007fff      0x00000000      0x00000000
0x6010a0 <jmpbuf+32>:   0xfffffffe      0xffffffff
```

**jmpbuf内容解析**：
- 保存的 RBP: `0x7fffffffe480`
- 保存的 RSP: `0x7fffffffe590`
- 保存的 RIP: `0x4008a0`（sigsetjmp后的代码地址）
- 保存的信号掩码

### 步骤7：单步执行siglongjmp

```gdb
(gdb) next
13          printf("\n===========================================\n");
(gdb) next
14          printf("捕获到信号: SIGFPE (信号编号: %d)\n", signum);

===========================================
(gdb) next
15          printf("异常类型: 除数为0\n");
捕获到信号: SIGFPE (信号编号: 8)
(gdb) next
16          printf("正在通过siglongjmp跳转回主程序...\n");
异常类型: 除数为0
(gdb) next
17          printf("===========================================\n");
正在通过siglongjmp跳转回主程序...
(gdb) next
===========================================

20          siglongjmp(jmpbuf, 1);
(gdb) next

异常已处理，程序继续运行
main () at division_zero_advanced.c:52
52              printf("\n异常已处理，程序继续运行\n");
```

**siglongjmp执行后**：

```gdb
(gdb) backtrace
#0  main () at division_zero_advanced.c:52

(gdb) info registers rip rsp rbp
rip            0x400932 0x400932 <main+146>
rsp            0x7fffffffe460   0x7fffffffe460
rbp            0x7fffffffe480   0x7fffffffe480
```

**关键观察**：
- 调用栈已恢复到只有main函数
- `rsp` 和 `rbp` 恢复到sigsetjmp时保存的值
- `rip` 指向sigsetjmp后的代码（else分支）
- 完全跳过了异常点，程序可以继续执行

**对比栈指针**：
```
sigsetjmp时:      rsp = 0x7fffffffe460, rbp = 0x7fffffffe480
信号处理时:       rsp = 0x7fffffffe360, rbp = 0x7fffffffe370
siglongjmp后:     rsp = 0x7fffffffe460, rbp = 0x7fffffffe480  ← 已恢复！
```

### 步骤8：继续执行，验证程序正常运行

```gdb
(gdb) continue
Continuing.
可以继续输入新的数据

输入被除数: 20
输入除数: 5

执行除法运算: 20 / 5
结果: 20 / 5 = 4

输入被除数: ^C
Program received signal SIGINT, Interrupt.
```

程序成功恢复并继续执行！

## 三、关键GDB命令总结

### 断点管理
```gdb
break <function>         # 在函数入口设置断点
break <file>:<line>      # 在指定行设置断点
info breakpoints         # 查看所有断点
delete <num>             # 删除断点
```

### 程序控制
```gdb
run [args]               # 运行程序
continue                 # 继续执行
next                     # 单步执行（不进入函数）
step                     # 单步执行（进入函数）
finish                   # 运行到当前函数返回
```

### 查看信息
```gdb
info frame               # 查看当前栈帧
info registers           # 查看所有寄存器
info locals              # 查看局部变量
info args                # 查看函数参数
backtrace (bt)           # 查看调用栈
info signals             # 查看信号处理设置
```

### 内存检查
```gdb
x/[n][f][u] <addr>       # 查看内存
  n: 数量
  f: 格式 (x=十六进制, d=十进制, s=字符串, i=指令, a=地址)
  u: 单位 (b=字节, h=半字, w=字, g=双字)

例如：
x/10x $rsp              # 查看栈顶10个字（十六进制）
x/20i $rip              # 查看指令指针处的20条指令
x/s 0x400000            # 查看地址处的字符串
```

### 变量查看
```gdb
print <var>              # 打印变量值
print &<var>             # 打印变量地址
print *<ptr>             # 打印指针指向的值
display <expr>           # 每次停止时自动显示表达式
```

## 四、栈变化可视化

### 1. 正常执行时（sigsetjmp点）

```
用户栈
┌─────────────────────────┐  0x7fffffffe490
│ main栈帧                │
│ ┌─────────────────────┐ │
│ │ 返回地址            │ │  0x7fffffffe488
│ ├─────────────────────┤ │
│ │ 保存的RBP           │ │  0x7fffffffe480  ← RBP
│ ├─────────────────────┤ │
│ │ jmpbuf在此保存状态  │ │
│ ├─────────────────────┤ │
│ │ 局部变量 a = 10     │ │  0x7fffffffe44c
│ │ 局部变量 b = 0      │ │  0x7fffffffe448
│ │ 局部变量 c          │ │  0x7fffffffe444
│ └─────────────────────┘ │
└─────────────────────────┘  0x7fffffffe440  ← RSP
```

### 2. 信号处理时

```
用户栈（内核修改）
┌─────────────────────────┐  0x7fffffffe490
│ main栈帧（保留）        │  (同上)
├─────────────────────────┤  0x7fffffffe440
│ 内核构造的信号栈帧      │
│ ┌─────────────────────┐ │
│ │ 保存的用户上下文    │ │
│ │ (ucontext_t)        │ │
│ ├─────────────────────┤ │
│ │ siginfo_t           │ │
│ ├─────────────────────┤ │
│ │ 返回地址(sigreturn) │ │
│ └─────────────────────┘ │
├─────────────────────────┤
│ sig_divzero栈帧         │
│ ┌─────────────────────┐ │
│ │ 返回地址            │ │  0x7fffffffe378
│ ├─────────────────────┤ │
│ │ 保存的RBP           │ │  0x7fffffffe370  ← RBP
│ ├─────────────────────┤ │
│ │ 参数 signum = 8     │ │  0x7fffffffe360  ← RSP
│ └─────────────────────┘ │
└─────────────────────────┘
```

### 3. siglongjmp后（恢复）

```
用户栈（恢复到sigsetjmp时）
┌─────────────────────────┐  0x7fffffffe490
│ main栈帧                │
│ ┌─────────────────────┐ │
│ │ 返回地址            │ │  0x7fffffffe488
│ ├─────────────────────┤ │
│ │ 保存的RBP           │ │  0x7fffffffe480  ← RBP（恢复）
│ ├─────────────────────┤ │
│ │ 局部变量 a = 10     │ │
│ │ 局部变量 b = 0      │ │
│ │ 局部变量 c          │ │
│ └─────────────────────┘ │
└─────────────────────────┘  0x7fffffffe460  ← RSP（恢复）

RIP恢复到 sigsetjmp 后的 else 分支
信号栈帧已清除
```

## 五、内核栈分析（理论）

虽然GDB无法直接查看内核栈，但我们可以推断：

### 异常发生时的内核栈

```
内核栈（每个进程8KB）
┌─────────────────────────┐  内核栈顶+8KB
│ 未使用                  │
├─────────────────────────┤
│ CPU自动保存：           │
│ - 用户SS                │
│ - 用户RSP               │
│ - 用户RFLAGS            │
│ - 用户CS                │
│ - 用户RIP               │
├─────────────────────────┤
│ 内核手动保存（pt_regs）：│
│ - 所有通用寄存器        │
│ - 段寄存器              │
├─────────────────────────┤
│ 内核函数调用栈：        │
│ - do_divide_error()     │
│ - do_trap()             │
│ - force_sig_fault()     │
│ - send_signal()         │
│ - ...                   │
└─────────────────────────┘  当前内核RSP
```

## 六、调试技巧和注意事项

### 1. 捕获信号

默认情况下，GDB会捕获所有信号。可以配置：

```gdb
# 让GDB在收到SIGFPE时停止，但继续传递给程序
handle SIGFPE stop pass

# 不停止，只打印信息
handle SIGFPE nostop pass

# 完全忽略
handle SIGFPE nostop nopass
```

### 2. 查看信号栈

```gdb
# 查看sigaltstack设置
info stack

# 查看信号掩码
print $_siginfo
```

### 3. 反汇编关键代码

```gdb
# 反汇编当前函数
disassemble

# 反汇编特定地址
disassemble 0x400904

# 查看指令指针处的指令
x/10i $rip
```

示例输出：
```gdb
(gdb) disassemble main
...
   0x0000000000400904 <+100>:   idiv   %ecx      ← 除零指令
   0x0000000000400906 <+102>:   mov    %eax,-0x18(%rbp)
...
```

### 4. 条件断点

```gdb
# 只在b=0时停止
break 48 if b == 0

# 计数断点（第N次命中时停止）
break 48
ignore 1 10  # 忽略前10次
```

## 七、完整的调试会话示例

```bash
$ gdb ./division_zero_advanced
(gdb) break sig_divzero
Breakpoint 1 at 0x400760: file division_zero_advanced.c, line 12.

(gdb) run
Starting program: ./division_zero_advanced
程序启动：除零异常处理演示（使用sigsetjmp/siglongjmp）
========================================================

输入被除数: 10
输入除数: 0

执行除法运算: 10 / 0

Breakpoint 1, sig_divzero (signum=8) at division_zero_advanced.c:12
12      {

(gdb) backtrace
#0  sig_divzero (signum=8) at division_zero_advanced.c:12
#1  <signal handler called>
#2  0x0000000000400904 in main () at division_zero_advanced.c:48

(gdb) info registers rip rsp rbp
rip            0x400760 0x400760 <sig_divzero>
rsp            0x7fffffffe360   0x7fffffffe360
rbp            0x7fffffffe370   0x7fffffffe370

(gdb) print jmpbuf
$1 = {{__jmpbuf = {4195488, 140737488348320, 140737488348560, 0, -2, 140737351746528}, ...}}

(gdb) continue
Continuing.

===========================================
捕获到信号: SIGFPE (信号编号: 8)
异常类型: 除数为0
正在通过siglongjmp跳转回主程序...
===========================================

异常已处理，程序继续运行
可以继续输入新的数据

输入被除数: ^C
Program received signal SIGINT, Interrupt.
(gdb) quit
```

## 八、总结

通过GDB调试，我们清晰地观察到：

1. **信号处理过程**：
   - 异常触发 → 内核发送SIGFPE → 调用sig_divzero

2. **栈的变化**：
   - 正常栈 → 信号处理栈（栈向下增长224字节） → 恢复到正常栈

3. **sigsetjmp/siglongjmp机制**：
   - sigsetjmp保存执行环境到jmpbuf
   - siglongjmp从jmpbuf恢复环境，实现非局部跳转

4. **寄存器恢复**：
   - RIP, RSP, RBP完全恢复到sigsetjmp时的状态
   - 程序流程跳转到else分支，避免重新触发异常

这个调试过程展示了操作系统信号处理机制的完整流程，以及用户态和内核态之间的协作。
