# LaTeX报告编译指南

## 文档说明

本目录包含一个完整的操作系统实验报告LaTeX文档：`操作系统实验报告.tex`

该文档整合了所有实验题目的答案，包括：
- Part 1: 除零异常处理机制
  - 问题1：异常响应过程分析
  - 问题2：用户栈和内核栈变化分析
  - 问题3：GDB调试演示
- Part 2: 外设中断和IO操作
  - Copy和Matrix进程并发执行分析
  - 甘特图和时间线
  - IO操作六大阶段详解
  - DMA和中断机制

## 编译要求

### 必需软件

1. **TeX Live** 或 **MiKTeX** (LaTeX发行版)
2. **ctex** 宏包 (中文支持)
3. **XeLaTeX** 编译器 (推荐，更好的中文支持)

### Ubuntu/Debian 系统安装

```bash
# 安装完整的TeX Live (约4GB)
sudo apt-get update
sudo apt-get install texlive-full

# 或者安装精简版 + 中文支持
sudo apt-get install texlive-latex-base texlive-latex-extra
sudo apt-get install texlive-xetex texlive-lang-chinese
sudo apt-get install latex-cjk-all
```

### macOS 系统安装

```bash
# 使用 Homebrew 安装 MacTeX
brew install --cask mactex

# 或者下载安装包
# https://www.tug.org/mactex/
```

### Windows 系统安装

下载并安装 MiKTeX 或 TeX Live for Windows：
- MiKTeX: https://miktex.org/download
- TeX Live: https://www.tug.org/texlive/

## 编译方法

### 方法1：使用 XeLaTeX (推荐)

XeLaTeX 对中文支持更好，推荐使用。

```bash
# 编译LaTeX文档
xelatex 操作系统实验报告.tex

# 生成目录需要编译两次
xelatex 操作系统实验报告.tex
xelatex 操作系统实验报告.tex
```

### 方法2：使用 PDFLaTeX

```bash
# 需要先安装CJK支持
pdflatex 操作系统实验报告.tex
pdflatex 操作系统实验报告.tex
```

### 方法3：使用 latexmk (自动化编译)

```bash
# 安装 latexmk
sudo apt-get install latexmk

# 自动编译
latexmk -xelatex 操作系统实验报告.tex

# 清理临时文件
latexmk -c
```

## 编译脚本

我们提供了一个自动化编译脚本 `compile.sh`：

```bash
# 赋予执行权限
chmod +x compile.sh

# 运行编译
./compile.sh
```

## 输出文件

编译成功后会生成以下文件：

- **操作系统实验报告.pdf** - 最终的PDF报告（主要输出）
- 操作系统实验报告.aux - 辅助文件
- 操作系统实验报告.log - 编译日志
- 操作系统实验报告.toc - 目录文件
- 操作系统实验报告.out - 超链接信息

## 在线编译

如果不想在本地安装LaTeX环境，可以使用在线LaTeX编辑器：

### Overleaf (推荐)
1. 访问 https://www.overleaf.com
2. 创建新项目
3. 上传 `操作系统实验报告.tex` 文件
4. 选择 XeLaTeX 编译器
5. 点击编译即可生成PDF

### 其他在线编辑器
- LaTeX Online: https://latexbase.com/
- Papeeria: https://papeeria.com/

## 文档结构

```
操作系统实验报告.tex
├── 封面和摘要
├── 目录
├── 第1章：引言
├── 第2章：Part 1 - 除零异常处理
│   ├── 2.1 实验程序
│   ├── 2.2 异常响应三层架构
│   └── 2.3 实验结果
├── 第3章：用户栈和内核栈变化
│   ├── 3.1 栈的基本概念
│   ├── 3.2 异常前的栈状态
│   ├── 3.3 CPU自动保存
│   ├── 3.4 内核手动保存
│   └── 3.5 信号处理栈帧
├── 第4章：GDB调试演示
│   ├── 4.1 高级异常处理程序
│   ├── 4.2 GDB调试步骤
│   └── 4.3 关键命令总结
├── 第5章：Part 2 - 外设中断和IO操作
│   ├── 5.1 进程特性对比
│   ├── 5.2 甘特图
│   ├── 5.3 DMA机制
│   ├── 5.4 中断处理
│   └── 5.5 IO操作总结
├── 第6章：实验总结与思考
└── 附录
```

## 自定义和修改

### 修改页面布局

在文档开头找到 `\geometry` 命令：

```latex
\geometry{left=2.5cm,right=2.5cm,top=2.5cm,bottom=2.5cm}
```

### 修改字体大小

修改文档类选项：

```latex
\documentclass[UTF8,a4paper,12pt]{ctexart}
                              ^^-- 改为 11pt 或 10pt
```

### 修改代码样式

找到 `\lstdefinestyle{cstyle}` 部分进行自定义。

### 添加新内容

在相应章节添加 LaTeX 代码即可。

## 常见问题

### Q1: 编译时提示找不到 ctexart 类

**A:** 需要安装 ctex 宏包：
```bash
sudo apt-get install texlive-lang-chinese
```

### Q2: 中文显示乱码

**A:** 确保使用 XeLaTeX 编译器，而不是 PDFLaTeX。

### Q3: 编译时间很长

**A:** 第一次编译会较慢（需要生成辅助文件），后续编译会快很多。使用 latexmk 可以加速。

### Q4: 缺少某个宏包

**A:** 使用包管理器安装：
```bash
# Ubuntu
sudo apt-get install texlive-latex-extra

# 或者使用 tlmgr (TeX Live Manager)
sudo tlmgr install <package-name>
```

## 清理临时文件

编译后会产生很多临时文件，可以使用以下命令清理：

```bash
# 手动删除
rm -f *.aux *.log *.toc *.out *.synctex.gz

# 使用 latexmk 清理
latexmk -c

# 完全清理（包括PDF）
latexmk -C
```

## 技术支持

如果遇到编译问题：

1. 检查 LaTeX 安装是否完整
2. 查看编译日志文件 (.log)
3. 尝试在线编译（Overleaf）
4. 搜索错误信息寻找解决方案

## 版本信息

- LaTeX 文档版本：1.0
- 创建日期：2025年12月3日
- 文档类：ctexart (支持中文)
- 推荐编译器：XeLaTeX
