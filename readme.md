DrawCircos: A pipline for prepare draw circos data
# 1. Install 
require software: circos,bedtools,samtools

# 2. Usage
### prepare Data
|  |  |  |	 |
---|----|----|----|----|
abbr parameter|parameter 		|Usage	|	Purpose|
-gw|getwindow	|	getwindow genome.fa windowize abbr	|	for get window file 
-gd|genedensity	|	genedensity gff3file windowfile		|for get gene density
-gGC|getGC	|	getGC genome.fa windowfile		|for get GC content in genome 
-gv|getvcf	|	getvcf vcffile windowfile abbrname	|	for vcffile 
-gc|getcoline	|	getcoline colinefile genes.bed	|	for coline file
-gL|getLAI	|	getLAI LAIfile	|	for LAI value
-gCop|getCopia	|	getCopia LTRfile windowfile	|	for repeat sequence of LTR type of Copia
-gGy|getGypsy  |	getGypsy LTRfile windowfile	|	for repeat sequence of LTR type of Gypsy
-gfL|getfullLTR	|	getfullLTR LAIfile	|	for repeat sequence of complete LTR
-gaL|getallLTR	|	getallLTR LAIfile	|	for repeat sequence of all LTR
-g2b|gff2bed	|	gff2bed gff3file type keyid	|	from gff3 file get bed file
-b2n|bed2num	|	bed2num bedfile windowfile abbr	|	from bed file get num file

Prepare Data Output file end with "_num.txt" will be as input in draw circos!

### prepare require file
|  |  |  |  |
|----|----|----|----|
|abbr parameter |parameter|		Usage	|	Purpose|
-k|karyotype		|karyotype genomelengthfile		|for get karyotype.txt
-c|conf			|conf -cc/-hi/-hm/-line/-h	|	for coline/histogram/heatmap/line 4 type prepare conf file
-t|ticks		|ticks	|	prepare ticks.conf

### draw circos
|	|	|	|
|--|--|--|
-d|draw	|	draw conffile

### pipline
|  |  |	|	|
|--|--|--|--|
-p|pipline|		pipline config.ini|		a pipline for draw circos, all the input are set in config.ini

gene density()
SNP density()
INDEL density()
genome colines()
karyotype.Spo.txt (染色体长度配置文件) *
circos.conf (主要的conf文件，画图时，通过此文件来调用其他配置文件)*
ticks.conf (刻度控制文件)*
coline_num.txt （共线性文件）
GC_num.txt GC（含量文件）
full_LTR_num.txt （完整LTR的百分比）
Gypsy_num.txt (Gypsy的百分比)
LTR_num.txt (所有LTR的百分比)
Copia_num.txt(Copia的百分比)
genes_num.txt (基因密度)
LAI_num.txt(LAI的分布)

# 3. Notes
1. please be careful of your gff3 type keyid ,make sure the output gene ID is same with your genome sequence. check it is  or  type.
2. all the output file ( _num.txt ) are the input file of Circos.

# 4. Author info
Author: Mol Chai
Email: chaimol@163.com
Githubs: https://github.com/chaimol/bio_code/tree/master/pipline/DrawCircos

# 5. Update information
#### 2021.07.01 release the Version to 0.01
#### 2022.08.11 release the Version to 0.02
#### 2023.07.05 release the Version to 0.03


