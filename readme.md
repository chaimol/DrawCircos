# DrawCircos: A pipline for prepare draw circos data
# DrawCircos: 一个自动化准备circos圈图数据的流程

**程序的作用：用户准备好各种类型的输入文件，使用DrawCircos即可一键生成最终的用于circos绘图的conf文件`conf.txt`。然后使用circos -conf conf.txt即可绘制圈图**

# 文件夹说明
+ demo 			存放测试模拟数据的目录，供用户参考不同文件的格式
+ DrawCircos	主程序
+ pipline.bash 	自动化流程

# 1. Install 
### Install require software:
- circos
- bedtools
- samtools

```
conda create -c bioconda -n circos circos bedtools samtools -y
source activate circos
```

### 安装DrawCircos，解压压缩包，添加执行权限，添加到全局环境变量。一定要添加到环境变量，否则程序无法正确运行。
```
unzip DrawCircos.zip
chmod 755 DrawCircos
echo 'export PATH="$PATH:'$(pwd)'"' >> ~/.bashrc
# 重新加载配置
source ~/.bashrc
```
[circos的安装的疑难解答](https://www.jianshu.com/p/7c594d01fede)

# 2. Usage
### prepare Data

| abbr parameter |Long parameter |Usage	|	Purpose |
|----|----|----|----|
|-gw|getwindow	|	getwindow genome.fa windowsize abbr	|	for get window file |
|-gd|genedensity	|	genedensity gff3file windowfile		|for get gene density|
|-gGC|getGC	|	getGC genome.fa windowfile		|for get GC content in genome |
|-gv|getvcf	|	getvcf vcffile windowfile abbrname	|	for vcffile |
|-gc|getcoline	|	getcoline colinefile genes.bed	|	for coline file|
|-gL|getLAI	|	getLAI LAIfile	|	for LAI value|
|-gCop|getCopia	|	getCopia LTRfile windowfile	|	for repeat sequence of LTR type of Copia|
|-gGy|getGypsy  |	getGypsy LTRfile windowfile	|	for repeat sequence of LTR type of Gypsy|
|-gfL|getfullLTR	|	getfullLTR LAIfile	|	for repeat sequence of complete LTR|
|-gaL|getallLTR	|	getallLTR LAIfile	|	for repeat sequence of all LTR|
|-g2b|gff2bed	|	gff2bed gff3file type keyid	|	from gff3 file get bed file|
|-b2n|bed2num	|	bed2num bedfile windowfile abbr	|	from bed file get num file|

Prepare Data Output file end with "_num.txt" will be as input in draw circos!

### draw circos
`-d|draw	draw conffile `

### prepare require file
|abbr parameter |Long parameter|		Usage	|	Purpose|
|----|----|----|----|
|-k|karyotype		|karyotype genomelengthfile		|for get karyotype.txt|
|-c|conf			|conf -cc/-hi/-hm/-line/-lai/-h	|	for coline/histogram/heatmap/line/lai 5 type prepare conf file|
|-t|ticks		|ticks	|	prepare ticks.conf|


### pipline (这是一个全自动的分析流程)
`-p|pipline`		pipline		a pipline for draw circos

## 实际使用方法1：直接使用pipline流程，一次传入所有文件地址和参数，直接绘图
```
DrawCircos -p --genome ../genome.chr.fa --gff3 ../genome.gff3 \
--windowsize 100000 --ticksize 200000 --abbr Ppo --coline ../KK4D/Ppo.Ppo.anchors \
--LAI ../LTRfindchr/genomes.chr.fa.out.LAI \
--repeat ../final.genome.fasta.RepeatMasker.out.gff \
--SNP ../WGS/3.gvcf/04.vcf/All.final.snp.vcf \
--INDEL ../WGS/3.gvcf/04.vcf/All.indel.vcf \
--LTR ../LTRfind/genome.chr.fa.pass.list \
--gff-type mRNA \
--gff-keyid 1 \
--circos_type coline heatmap histogram line line histogram histogram LAI line \
--circos_file coline genes GC Copia Gypsy SNP INDEL LAI repeat
```
自动化流程的参数说明：`DrawCircos -p`和`bash pipline.bash`是相同的作用。后续的参数说明：
+ --genome 			基因组文件，必须参数
+ --gff3			基因组gff3文件，必须参数
+ --windowsize		窗口大小，默认是1000000， 表示1M
+ --ticksize		刻度盘最小刻度，默认是windowsize的10倍，格式也是10000000
+ --abbr			输出前缀，
+ --coline			共线性文件，可以使用KK4D获得
+ --LAI				LAI文件，可以使用LTRfind获得
+ --repeat			基因组重复文件，可以由repeatmasker获得
+ --SNP				SNP文件
+ --INDEL			INDEL文件
+ --bam				指定转录组的bam文件，格式是 `-bam repeat1.bam repeat2.bam repeat3.bam`。如果没有重复，只指定一个bam文件也可以。输出是fpkm_num.txt
+ --LTR				LTR文件，可以使用LTRfind获得，一般是*.pass.list
+ --gff-type		指定gff3文件中第3列对应基因id的字段，一般是mRNA或gene
+ --gff-keyid		指定gff3文件中第9列对应基因id的字段的位置，一般是1或2
+ --circos_type		指定要绘制的图像的类型，可以指定类型有coline，heatmap,line,histogram,LAI。必须是这5个字符串其中之一，使用空格分开不同的值。
+ --circos_file 	格式是：使用空格分割开不同的输出_num.txt文件的前缀

上述参数中，`--circos_file`和`--circos_type`的参数数量必须上下一一对应，最终输出的绘图顺序，是按照--circos_file这个顺序从前到后对应从内圈到外圈。

上述会输出2个关键文件${abbr}.run.conf和conf.txt。
如果没有报错，则可以使用`circos -conf conf.txt`绘图。
+ ${abbr}.run.conf 这个是生成的命令文件，`bash ${abbr}.run.conf`即会调用DrawCircos生成下面的conf.txt文件。一般情况下程序运行时会自动运行这个命令。
+ conf.txt 这个就是完整的circos绘图的conf文件

## 实际使用方法2：分布获取每个文件，最后合并绘图

#### 第1步：先获取所有的_num.txt文件
```
##获得基因组的窗口文件，滑动窗大小是10kb, 输出文件是Ppo.window
DrawCircos -gw genome.chr.fa 10000 Ppo 

##获得基因组的GC文件,输出文件是GC_num.txt
DrawCircos -gGC genome.chr.fa Ppo.window

##获取基因密度,输出文件是genes_num.txt
DrawCircos -gd genome.gff3 Ppo.window

## 计算基因组的重测序SNP数据的分布,输出文件是SNP_num.txt
DrawCircos -gv ../WGS/3.gvcf/04.vcf/All.final.snp.vcf Ppo.window SNP

## 计算基因组的重测序indel数据的分布，输出文件是INDEL_num.txt
DrawCircos -gv ../WGS/3.gvcf/04.vcf/All.indel.vcf Ppo.window INDEL

#获取基因组的基因id的文件,输出文件是genes.ID.bed
DrawCircos -gIb genome.gff3 mRNA 1
## 准备基因组的内部的共线性文件,输出文件是coline_num.txt
DrawCircos -gc ../KK4D/Ppo.Ppo.anchors genes.ID.bed jcvi

## 准备基因组的LTR的Copia的鉴定结果，输出文件是Copia_num.txt
DrawCircos -gCop ../LTRfind/genome.chr.fa.pass.list Ppo.window

## 准备基因组的LTR的Gypsy的分布，输出文件是Gypsy_num.txt
DrawCircos -gGy ../LTRfind/genome.chr.fa.pass.list Ppo.window

## 准备基因组的LAI文件，输出是LAI_num.txt
DrawCircos -gL ../LTRfindchr/genomes.chr.fa.out.LAI

## 准备基因组重复文件，输出是repeat_num.txt
grep -v ^# ../final.genome.fasta.RepeatMasker.out.gff|cut -f 1,4,5  >repeat.bed
DrawCircos bed2num repeat.bed Ppo.window repeat rate

##准备获取刻度文件,输出文件是karyotype.txt
DrawCircos -k Ppo.genome.txt

##获取刻度文件，参数是坐标轴的每个齿的最小刻度大小，输出文件是ticks.conf
DrawCircos -t 100000
```

上面的LTR和LAI相关的结果都是[LTRfind](https://github.com/chaimol/LTRfind) 输出的结果，共线性的结果是[KK4D](https://github.com/chaimol/KK4D) 输出的结果，重复序列是repeatmasker输出的gff3结果。
#### 第2步，指定绘图的圈数和位置 
`-c` 参数从V0.04版本开始，可以支持多个参数连续使用。
你已经通过第1步的命令，获取了如下的文件：
+ coline_num.txt （共线性文件）
+ GC_num.txt GC（GC含量文件）
+ full_LTR_num.txt （完整LTR的百分比）
+ Gypsy_num.txt (Gypsy的百分比)
+ LTR_num.txt (所有LTR的百分比)
+ Copia_num.txt(Copia的百分比)
+ genes_num.txt (基因密度)
+ LAI_num.txt(LAI的分布)
+ SNP_num.txt (SNP的分布)
+ INDEL_num.txt (INDEL的分布)

现在准备circos绘图的conf文件，可以如下运行：
```
DrawCircos -c -cc 8 \
-hm genes_num.txt 2 9 reds-9-seq genedensity \
-hi GC_num.txt 3 9 oranges-9-seq \
-line Copia_num.txt 4 9 BuGn-9-seq \
-line Gypsy_num.txt 5 9 greens-9-seq \
-hi SNP_num.txt 6 9 green \
-hi INDEL_num.txt 7 9 yellow \
-lai LAI_num.txt 8 9 grey \
-line repeat_num.txt 9 9 oranges-9-seq 
```
这里的-c之后的参数说明：
+ -cc参数是指定绘制共线性文件，这个只能在最内圈，所以只需要一个参数即总圈数。
+ -hi|-line|-hm|-lai 后面的参数格式都是相同的， 第一个参数是_num文件，第2个参数是绘制在第几圈，第3个参数是总共的圈数，第4个参数是绘图的颜色，第5个参数是该圈数输出前缀。

+ -cc只能使用一次，除了-cc之外的这4种类型，都可以重复使用，而且这些类型后面的5个参数，只有第1个参数，即_num文件必须传入，其他参数都可以省略，程序会有默认值。
+ 这里如果不输入圈数，会按照输入的先后顺序，对应从内到外的圈数。并自动计算总圈数。
第2步最终输出的文件是conf.txt，如果程序没有报错。那么就可以直接绘图了。`circos -conf conf.txt`这个命令即可绘图了。
如果你对颜色不满意，可以后期使用AdobeIllustrator修改，也可以手动修改conf.txt里的圈的尺寸或颜色信息，之后再重新绘图。


# 3. Notes
1. please be careful of your gff3 type keyid ,make sure the output gene ID is same with your genome sequence. check it is  or  type.
2. all the output file ( _num.txt ) are the input file of Circos.

# 4. Author info
Author Email: chaimol@163.com

# 5. Update information
#### 2021.07.01 release the Version to 0.01
#### 2022.08.11 release the Version to 0.02
#### 2023.07.05 release the Version to 0.03 (预览版)
#### 2025.11.07 release the Version to 0.04（正式版）
- 修复了绘图圈数，现在是从内往外数圈数。
- 修复了输入圈数后输出的长度为正确的值。
- 修复了其中注释文件的部分错别字。
- 新增了绘制LAI的功能。
- 新增pipline功能，用户一次性输入所有参数后，可以直接完成所有分析，直接绘图。删除了config.ini的传参方式，只接受命令行传参。

