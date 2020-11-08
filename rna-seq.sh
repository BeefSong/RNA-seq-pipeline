#（一）建立fastq文件超链接
cd 01.data
ls ../../../rawdata/sus.muscle.rnaseq/*.gz |while read id; do ln -s $id $(basename $id); done

#（二）质控[fastqc]
cd ../02.qc
ls ../01.data/*.gz | awk '{print "fastqc "$1" -o ./ &"}' fq.txt  >qc.sh
nohup sh qc.sh.&
#整合qc质控结果，忽略html文件
multiqc *fastqc.zip --ignore *.html

#（三）过滤[trim-galore]
#构建配置文件
cd ../03.filter
ls ../01.data/*1.fastq.gz | xargs -I {} basename {} | cut -d "_" -f 1,2 > 1
ls ../01.data/*1.fastq.gz > 2
ls ../01.data/*2.fastq.gz > 3
paste 1 2 3 > config.txt
#批量生成过滤脚本
cat config.txt | awk '{print "trim_galore --stringency 3 --paired "$2" "$3"  --gzip -o ./"}' >filter.sh
