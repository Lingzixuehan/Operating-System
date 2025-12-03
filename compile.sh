#!/bin/bash

# LaTeX文档编译脚本
# 用于编译"操作系统实验报告.tex"

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 文档名称（不含扩展名）
DOC_NAME="操作系统实验报告"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}LaTeX 文档编译脚本${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# 检查LaTeX编译器是否可用
check_compiler() {
    if command -v xelatex &> /dev/null; then
        echo -e "${GREEN}✓ 找到 XeLaTeX 编译器${NC}"
        COMPILER="xelatex"
        return 0
    elif command -v pdflatex &> /dev/null; then
        echo -e "${YELLOW}✓ 找到 PDFLaTeX 编译器（建议使用 XeLaTeX 以获得更好的中文支持）${NC}"
        COMPILER="pdflatex"
        return 0
    else
        echo -e "${RED}✗ 未找到 LaTeX 编译器${NC}"
        echo ""
        echo "请安装 TeX Live 或 MiKTeX："
        echo ""
        echo "  Ubuntu/Debian:"
        echo "    sudo apt-get install texlive-xetex texlive-lang-chinese"
        echo ""
        echo "  macOS:"
        echo "    brew install --cask mactex"
        echo ""
        echo "  或访问: https://www.tug.org/texlive/"
        echo ""
        return 1
    fi
}

# 编译文档
compile_document() {
    echo ""
    echo -e "${YELLOW}开始编译文档...${NC}"
    echo ""

    # 第一次编译
    echo -e "${YELLOW}[1/3] 第一次编译${NC}"
    $COMPILER -interaction=nonstopmode "${DOC_NAME}.tex" || {
        echo -e "${RED}✗ 编译失败！${NC}"
        echo "请查看 ${DOC_NAME}.log 文件获取详细错误信息"
        return 1
    }

    # 第二次编译（生成目录）
    echo ""
    echo -e "${YELLOW}[2/3] 第二次编译（生成目录）${NC}"
    $COMPILER -interaction=nonstopmode "${DOC_NAME}.tex" > /dev/null 2>&1

    # 第三次编译（确保引用正确）
    echo ""
    echo -e "${YELLOW}[3/3] 第三次编译（确保引用正确）${NC}"
    $COMPILER -interaction=nonstopmode "${DOC_NAME}.tex" > /dev/null 2>&1

    echo ""
    if [ -f "${DOC_NAME}.pdf" ]; then
        echo -e "${GREEN}✓ 编译成功！${NC}"
        echo ""
        echo "输出文件: ${DOC_NAME}.pdf"

        # 显示PDF文件大小
        SIZE=$(du -h "${DOC_NAME}.pdf" | cut -f1)
        echo "文件大小: $SIZE"

        # 显示页数（如果安装了 pdfinfo）
        if command -v pdfinfo &> /dev/null; then
            PAGES=$(pdfinfo "${DOC_NAME}.pdf" 2>/dev/null | grep "Pages:" | awk '{print $2}')
            if [ -n "$PAGES" ]; then
                echo "总页数: $PAGES"
            fi
        fi

        return 0
    else
        echo -e "${RED}✗ PDF文件未生成${NC}"
        return 1
    fi
}

# 清理临时文件
clean_files() {
    echo ""
    echo -e "${YELLOW}清理临时文件...${NC}"

    # 要删除的扩展名
    EXTENSIONS="aux log toc out synctex.gz fls fdb_latexmk"

    for ext in $EXTENSIONS; do
        if ls "${DOC_NAME}."$ext 1> /dev/null 2>&1; then
            rm -f "${DOC_NAME}."$ext
            echo "  删除 ${DOC_NAME}.$ext"
        fi
    done

    echo -e "${GREEN}✓ 清理完成${NC}"
}

# 主函数
main() {
    # 检查编译器
    if ! check_compiler; then
        exit 1
    fi

    # 检查源文件是否存在
    if [ ! -f "${DOC_NAME}.tex" ]; then
        echo -e "${RED}✗ 找不到源文件: ${DOC_NAME}.tex${NC}"
        exit 1
    fi

    # 编译文档
    if compile_document; then
        # 询问是否清理临时文件
        echo ""
        read -p "是否清理临时文件? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            clean_files
        fi

        echo ""
        echo -e "${GREEN}=====================================${NC}"
        echo -e "${GREEN}编译完成！${NC}"
        echo -e "${GREEN}=====================================${NC}"

        # 尝试打开PDF（可选）
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v xdg-open &> /dev/null; then
                read -p "是否打开PDF文件? (y/n) " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    xdg-open "${DOC_NAME}.pdf" &
                fi
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            read -p "是否打开PDF文件? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                open "${DOC_NAME}.pdf"
            fi
        fi

        exit 0
    else
        echo ""
        echo -e "${RED}=====================================${NC}"
        echo -e "${RED}编译失败！${NC}"
        echo -e "${RED}=====================================${NC}"
        exit 1
    fi
}

# 运行主函数
main
