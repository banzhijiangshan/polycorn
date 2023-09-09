#!/bin/bash

# mpshell和iperf3的参数
up="$1"
down="$2"
delay=$3
server_ip=$4
testtime=$5
num_lines_head=$6     # 删除前几行
num_lines_tail=$7     # 删除后几行
type=$8 # tcp或udp测试
tempfile=$(mktemp)

if [ "$8" = "u" ]; then
  mpshell $delay "$up" "$down" $delay "$up" "$down" /bin/bash -c "iperf3 -u -c \"$server_ip\" -p 12345 -i 1 -t \"$testtime\"  -R -f m -b 1000M --logfile iperf_result.txt"
elif [ "$8" = "t" ]; then
  mpshell $delay "$up" "$down" $delay "$up" "$down" /bin/bash -c "iperf3 -c \"$server_ip\" -p 12345 -i 1 -t \"$testtime\"  -R -f m --logfile iperf_result.txt"
else
  echo "参数错误"
fi

killall iperf3

# 格式处理
file_path="iperf_result.txt"        

# 删除前几行
if [[ $num_lines_head -gt 0 ]]; then
  sed -i "1,${num_lines_head}d" "$file_path"
fi

# 删除后几行
if [[ $num_lines_tail -gt 0 ]]; then
  total_lines=$(wc -l < "$file_path")
  start_line=$((total_lines - num_lines_tail + 1))
  if [[ $start_line -gt 0 ]]; then
    sed -i "${start_line},\$d" "$file_path"
  fi
fi

# 保留带宽那一列
awk -F " " 'BEGIN{  
  id=0;
}
{
id=id+1;
print id " " $7"\t";
}' $file_path > $tempfile

# 将临时文件内容复制回原始文件
cp $tempfile $file_path

# 删除临时文件
rm $tempfile
