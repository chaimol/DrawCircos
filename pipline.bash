#!/bin/bash

# 默认参数值
genome=""
gff3=""
windowsize=""
abbr=""
coline=""
LAI=""
repeat=""
SNP=""
INDEL=""
LTR=""
bam=()
gff_type=""
gff_keyid=""
circos_type=()
circos_file=()

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Usage: pipline.sh [OPTIONS]"
            echo "Options:"
            echo "  -h, --help              Show this help message"
            echo "  --genome FILE           Genome file,必需参数"
            echo "  --gff3 FILE             GFF3 file，必需参数"
            echo "  --windowsize SIZE       Window size，根据基因组大小选择合适的窗口，格式是：1000000，数字格式，默认值是1000000，即1Mb"
            echo "  --ticksize Size         绘图时外圈的最小刻度的大小，默认是windowsize的10倍，格式也是数字格式，1000000"
            echo "  --abbr NAME             Abbreviation,这个是输出的基因相关文件的前缀"
            echo "  --coline FILE           Coline file，参数一般是${abbr}.${abbr}.anchors"
            echo "  --LAI FILE              LAI file，参数一般是${abbr}.out.LAI文件"
            echo "  --repeat FILE           Repeat file,参数是${abbr}.repeat.gff3文件"
            echo "  --SNP FILE              SNP file，参数是SNP.vcf文件"
            echo "  --INDEL FILE            INDEL file,参数是indel.vcf文件"
            echo "  --LTR FILE              LTR file，参数一般是${abbr}.pass.list"
            echo "  --bam FILE              BAM file,参数可以是1到多个bam文件，格式是：repeat1.bam repeat2.bam repeat3.bam"
            echo "  --gff-type TYPE         GFF3的第3列对应基因id的字段,参数一般是gene或mRNA"
            echo "  --gff-keyid ID          GFF3的第9列对应基因id的字段位置，参数一般是1或2"
            echo "  --circos_type coline heatmap heatmap LAI heatmap histogram line  格式是：使用空格分开不同的绘图类型"
            echo "  --circos_file coline genes GC LAI SNP repeat fpkm        格式是：使用空格分割开不同的输出_num.txt文件的前缀"
            echo ""
            echo "command line arguments take precedence."
            echo "注意事项：
            除了gff3文件和genome文件是必需参数，其他参数都可以省略。如果不提供--circos_file或--circos_type文件，则不会自动绘图。
            --circos_type和--circos_file参数后面的传入的参数数量必须相同，前后顺序是一一对应的关系
            --circos_type 是指定对应的从内到外，每一圈要绘图的形状。可选形状包括：coline,histogram,heatmap,LAI,line.这5种格式，其中coline和LAI是固定的专用格式。
            --circos_file 是指定对应的从内到外，每一圈要绘图的文件。需要传入文件的前缀名，每一次运行前面的都会输出${abbr}_num.txt，这里就是指定abbr的内容。
            传入coline参数，会输出coline_num.txt
            传入LAI参数后，会输出LAI_num.txt,full_LTR_num.txt,LTR_num.txt这3个文件
            传入SNP参数后，会输出SNP_num.txt
            传入INDEL参数后，会输出INDEL_num.txt
            传入repeat参数，会输出repeat_num.txt
            传入基因组文件和gff3文件，会输出GC_num.txt,genes_num.txt文件
            传入LTR参数，会输出Gypsy_num.txt和Copia_num.txt文件。
            传入bam参数，会输出fpkm_num.txt文件
            如果你没有传入对应的参数，但是使用DrawCircos的其他命令生成了类似XXX_num.txt文件，你也可以在--circos_file传入XXX,程序一样可以读取已有的对应的文件。
            "
            exit 0
            ;;
        --genome)
            genome="$2"
            shift 2
            ;;
        --gff3)
            gff3="$2"
            shift 2
            ;;
        --windowsize)
            windowsize="$2"
            shift 2
            ;;
        --ticksize)
            ticksize="$2"
            shift 2
            ;;
        --abbr)
            abbr="$2"
            shift 2
            ;;
        --coline)
            coline="$2"
            shift 2
            ;;
        --LAI)
            LAI="$2"
            shift 2
            ;;
        --repeat)
            repeat="$2"
            shift 2
            ;;
        --SNP)
            SNP="$2"
            shift 2
            ;;
        --INDEL)
            INDEL="$2"
            shift 2
            ;;
        --LTR)
            LTR="$2"
            shift 2
            ;;
        --bam)
		    shift
            # 循环读取后续参数，直到遇到下一个选项（--开头）或参数结束
			while [[ $# -gt 0 && "$1" != --* ]]; do
				bam+=("$1")
				shift
			done
			;;
        --gff-type)
            gff_type="$2"
            shift 2
            ;;
        --gff-keyid)
            gff_keyid="$2"
            shift 2
            ;;
        --circos_file)
            shift  # 跳过--circos_file本身
			# 循环读取后续参数，直到遇到下一个选项（--开头）或参数结束
			while [[ $# -gt 0 && "$1" != --* ]]; do
				circos_file+=("$1")
				shift
			done
			;;
        --circos_type)
			shift  # 跳过--circos_type本身
			while [[ $# -gt 0 && "$1" != --* ]]; do
				circos_type+=("$1")
				shift
			done
        ;;
        -*)
            echo "Unknown option $1"
            echo "Use -h or --help for help"
            exit 1
            ;;
        *)
            # 如果不是以-开头的参数，则认为是配置文件
            if [[ -z "$config_file" ]]; then
                config_file="$1"
            fi
            shift
            ;;
    esac
done

# 检查必需的文件是否存在
if [[ -z "$genome" || -z "$gff3" ]]; then
    echo "Error: Both genome and gff3 files must be specified!"
    echo "Use -h or --help for help"
    exit 1
fi

if [[ ! -e "$genome" || ! -e "$gff3" ]]; then
    echo "Error: Input file not exist!"
    echo "Genome file: $genome exists: $([ -e "$genome" ] && echo "yes" || echo "no")"
    echo "GFF3 file: $gff3 exists: $([ -e "$gff3" ] && echo "yes" || echo "no")"
    exit 1
fi

#检查参数是否存在，存在则数量必需相等
if [[ ${#circos_file[@]} -gt 0 && ${#circos_type[@]} -gt 0 ]];then
    if [[ ${#circos_type[@]} -ne ${#circos_file[@]} ]]; then
    echo "Error: --circos_type 和 --circos_file 数量必须相同"
    exit 1
    fi
fi

echo "pass the data check !"

windowsize=${windowsize:-1000000} #默认的窗口大小为1Mb
ticksize=${ticksize:-$((windowsize * 10))} #设置默认的刻度盘最小刻度大小，默认是窗口大小的10倍
#######################准备具体的每种类型的绘图文件############################
##获取window文件(输出：${abbr}.window)
DrawCircos getwindow ${genome} ${windowsize} ${abbr}

##获取karyotype.txt,染色体信息文件
DrawCircos -k ${abbr}.genome.txt

##获取刻度文件ticks.conf
DrawCircos -t ${ticksize}

##获取GC 含量（输出：GC_num.txt）
DrawCircos getGC ${genome} ${abbr}.window 

##获取gene密度(输出： genes_num.txt )
DrawCircos genedensity ${gff3} ${abbr}.window

##获取genes.bed
DrawCircos getIDbed ${gff3} ${gff_type} ${gff_keyid}

##获取共线性（输出：coline_num.txt）
if [ -e ${coline} ];then
	DrawCircos getcoline ${coline} genes.bed
fi

##获取LAI（输出：LAI_num.txt）
if [ -e $LAI ];then
	DrawCircos getLAI ${LAI}  #LAI_num.txt
	DrawCircos getfullLTR ${LAI}  #full_LTR_num.txt
	DrawCircos getallLTR ${LAI}  #LTR_num.txt
fi

##获取重复序列 (输出：repeat_num.txt)
if [ -e ${repeat} ];then
	grep -v ^# ${repeat}|cut -f 1,4,5 >repeat.bed
	DrawCircos bed2num repeat.bed ${abbr}.window repeat rate
fi

##获取SNP (输出：SNP_num.txt)
if [ -e ${SNP} ];then
	DrawCircos getvcf ${SNP} ${abbr}.window SNP
fi

##获取INDEL (输出：INDEL_num.txt)
if [ -e ${INDEL} ];then
	DrawCircos getvcf ${INDEL} ${abbr}.window INDEL
fi

##获取LTR(输出：)
if [ -e ${LTR} ];then
	DrawCircos getCopia ${LTR} ${abbr}.window  #Copia_num.txt
	DrawCircos getGypsy ${LTR} ${abbr}.window  #Gypsy_num.txt
fi

##获取表达量fpkm（输出：fpkm_num.txt）
###只有第一个bam文件存在时才会运行
if [ -e ${bam[0]} ];
then
	bamlen=${#bam[@]}
	lenbam=`expr $bamlen - 1`
	##生成临时文件
	trap 'rm -f "$tempfpkm"' EXIT  #退出时，删除临时文件(trap是根据后面的系统信号，执行前面的命令)
	tempfpkm=$(mktemp -p ${PWD}) || exit 1 #在工作路径，生成临时文件，如果生成失败，则退出。
	##转置行列
	# awk BEGIN{c=0;} {for(i=1;i<=NF;i++) {num[c,i] = $i;} c++;} END{ for(i=1;i<=NF;i++){str=""; for(j=0;j<NR;j++){ if(j>0){str = str" "} str= str""num[j,i]}printf("%s\n", str)} }
	for i in `seq 0 ${lenbam}`;
	do
            if [ -e ${bam[i]} ];
            then
            	DrawCircos fpkm ${bam[i]} ${abbr}.window bam_$i
            	#把第四列输出，并转置成行，追加到临时文件
            	awk '{print $4}' bam_${i}.fpkm |awk 'BEGIN{c=0;} {for(i=1;i<=NF;i++) {num[c,i] = $i;} c++;} END{ for(i=1;i<=NF;i++){str=""; for(j=0;j<NR;j++){ if(j>0){str = str" "} str= str""num[j,i]}printf("%s\n", str)} }'  >>${tempfpkm}
            fi
	done
	#拼接多个bam的输出结果到一起，求的是均值
	if [ -e bam_0.fpkm ];
	then
		paste -d "\t" <(awk '{print $1"\t"$2"\t"$3}' bam_0.fpkm) <(awk 'BEGIN{c=0;} {for(i=1;i<=NF;i++) {num[c,i] = $i;} c++;} END{ for(i=1;i<=NF;i++){str=""; for(j=0;j<NR;j++){ if(j>0){str = str" "} str= str""num[j,i]}printf("%s\n", str)} }' ${tempfpkm}| awk '{ for(i=1; i<=NF;i++) j+=$i; print j/NF; j=0 }') >fpkm_num.txt
	fi
fi

########使用一条命令准备绘制conf文件##############
if [[ ${#circos_file[@]} -gt 0 && ${#circos_type[@]} -gt 0 && ${#circos_type[@]} -eq ${#circos_file[@]} ]]; then
    # 初始化配置文件
    > "${abbr}.run.conf"  # 清空或创建文件
    printf "DrawCircos -c" >> "${abbr}.run.conf"  # 写入基础命令

    # 遍历所有参数
    for ((i=0; i<${#circos_type[@]}; i++)); do
        current_file_prefix="${circos_file[$i]}"
        current_type="${circos_type[$i]}"
        target_file="${current_file_prefix}_num.txt"
        
        # 检查文件是否存在
        if [[ ! -f "$target_file" ]]; then
            echo "Error: 绘图文件不存在！文件路径：$target_file"
            echo "对应配置：--circos_file $current_file_prefix | --circos_type $current_type（索引：$i）"
            exit 1
        fi
        
        # 根据类型追加参数，注意-cc只需要2个参数，因为只能绘制1个coline,所以这个命令不需要传入当前圈数，只需要传入总圈数，
		#其他类型都是需要3个参数。参数2是当前的圈数，参数3是总圈数。
        case "${current_type}" in
            coline)    printf " -cc ${target_file} ${#circos_file[@]}"  >> "${abbr}.run.conf" ;;
            histogram) printf " -hi ${target_file} $(($i + 1)) ${#circos_file[@]}" >> "${abbr}.run.conf" ;;
            line)      printf " -line ${target_file} $(($i + 1)) ${#circos_file[@]}" >> "${abbr}.run.conf" ;;
            heatmap)   printf " -hm ${target_file} $(($i + 1)) ${#circos_file[@]}" >> "${abbr}.run.conf" ;;
            LAI|lai)   printf " -lai ${target_file} $(($i + 1)) ${#circos_file[@]}" >> "${abbr}.run.conf" ;;
            *) 
                echo "Error: --circos_type 参数 ${current_type} 不规范！"
                echo "可选值：coline/LAI/histogram/heatmap/line"
                exit 1 ;;
        esac
    done
	printf "\n" >>${abbr}.run.conf #给结尾添加上换行符
    # 执行配置文件生成命令
    echo "运行bash ${abbr}.run.conf命令生成最终的绘图conf文件！"
    bash "${abbr}.run.conf"
else
    echo "Error: --circos_type（数量：${#circos_type[@]}）与--circos_file（数量：${#circos_file[@]}）参数数量不一致"
    exit 1
fi