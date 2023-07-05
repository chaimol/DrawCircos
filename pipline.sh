#!/bin/bash

case $1 in 
	-h|--help)
		echo "Usage:pipline.sh config.ini"
		exit 1
		;;
esac
config=$1
source $config
if [ -e $genome ] && [ -e $gff3 ];
then
	echo "pass the data check !"
else
	echo "Error: input file not exist! please check the config file $1 setting!"
	exit 1
fi

##获取window文件(输出：${abbr}.window)
DrawCircos getwindow ${genome} ${windowsize} ${abbr}

##获取GC 含量（输出：GC_num.txt）
DrawCircos getGC ${genome} ${abbr}.window 

##获取gene密度(输出： genes_num.txt )
DrawCircos genedensity ${gff3} ${abbr}.window

##获取genes.bed
DrawCircos gff2bed ${gff3} ${gff_type} ${gff_keyid}

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
	cut -f 1,4,5 ${repeat} >repeat.bed
	DrawCircos bed2num genes.bed ${abbr}.window repeat rate
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
#只有第一个bam文件存在时才会运行
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

