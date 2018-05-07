#!/bin/bash

### Sar Standalone vizualizer
### Graphs -> http://dygraphs.com/1.0.1/dygraph-combined.js
### Created by Raivis Saldabols 2014 May
###
### v.1.0 - initial creation

### Compability: 
### tested with: sysstat version 9.0.4

###### MANUAL CONFIG VAR SECTION
## configure these parameters if not in PATH
C_SADF=`which sadf`
C_SED=`which sed`
C_AWK=`which awk`
C_XARGS=`which xargs`

## output filename pattern
O_FILE=SAR_VIZ_REP_`hostname -s`_`date +%Y%m%d%H%M%S`.html

## getting / parsing input files
for var in "$@" ; do eval "export list_${var}"; done
if [ -z "$list_file" ] ; then
  echo "Not given SAR files to Vizualize:.
  Usage:
    `basename $0` file=file_1[,file_n]* "
  exit 1
fi

list_file=`echo $list_file | ${C_SED} 's/,/ /g'`
l=`echo $list_file | wc -w` 	# file count
l_server=`sadf \`echo $list_file | ${C_AWK} '{print $1}'\` | head -1 | ${C_AWK} '{print $1}'`

###### FUNCTION SECTION
## Generate Output Header
function GET_H (){
	echo "<html><head><title>SAR VIZUALIZER</title>"
	echo "<style>h1 {font-size: 24px;} p.footer{font-size:10px; font-color:grey;} td{vertical-align:top;border: 0px solid black;}</style>"
	echo "</head>"
	echo "<script type='text/javascript' src='http://dygraphs.com/1.0.1/dygraph-combined.js'></script>"
	echo "<body>"
	echo "Report generated @ `date`"
	echo "<h1>SAR VIZUALIZER report : server ${l_server}</h1>"	
	echo "<h3>Files used to generate this report</h3>"
	echo "<blockquote><pre style=white-space:pre-wrap>"
	uname -a; echo $list_file | ${C_XARGS} -n1 ls -l
	echo "</pre></blockquote>" 
	echo "<h3>Please refer to SAR manual for detailed graph explanation </h3>"
	echo "<table>"
}

function GET_HE (){
	echo "</table></body></html>"

}

function PREP_DIV_B(){
	## UNIQ_ID
	echo "<tr><td><div id='${1}' style='width:1000px; height:350px;'></div></td>"
	echo "<td><div id='${1}_lab' style='padding-top:25px; width:200px; font-size:0.8em;'></div></td></tr>"
	echo "<script type='text/javascript'>"
	echo "g2 = new Dygraph(document.getElementById('${1}'),"
}

function PREP_DIV_E_ST(){
	## UNIQ_ID Header H-axis V-Axis IS_STACK
	echo "{"
        echo "title: '${2}',"
        echo "xlabel: '${3}',"
        echo "ylabel: '${4}',"
        echo "labelsDiv: document.getElementById('${1}_lab'),"
        if [ "$5" = 1 ]; then echo "stackedGraph: true,"; fi
        echo "showRangeSelector: true, showRoller: true,xValueFormatter: Dygraph.dateString_,xTicker: Dygraph.dateTicker,"
        echo "labelsSeparateLines: true,labelsKMB: true,drawXGrid: false,width: 740,height: 300,rollPeriod: 1, strokeWidth: 1}"
	echo ");</script>"
}

## CPU
function GET_CPU_1 () {
c=1
PREP_DIV_B "CPU1"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$10","$6","$7","$8","$9","$5" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"Man Added timestamp,%idle,%nice,%system,%iowait,%steal,%user \n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$10","$6","$7","$8","$9","$5"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$10","$6","$7","$8","$9","$5"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "CPU1" "CPU Usage" "Date & Time" "Percentage" 1
}

function GET_LA_1 () {
c=1
PREP_DIV_B "LA1"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -q ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$6","$7","$8" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,ldavg-1,ldavg-5,ldavg-15\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -q ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$6","$7","$8"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -q ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$6","$7","$8"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "LA1" "Load Average (sar -q)" "Date & Time" "LA"
}

function GET_LA_2 () {
c=1
PREP_DIV_B "LA2"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -q ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$5" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,runq-sz\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -q ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$5"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -q ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$5"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "LA2" "Load Average: Number of tasks in the task list (sar -q)" "Date & Time" "LA"
}

function GET_LA_3 () {
c=1
PREP_DIV_B "LA3"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -q ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,runq-sz\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -q ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -q ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "LA3" "Load Average: Run queue lenght (sar -q)" "Date & Time" "LA"
}

function GET_IO_1() {
c=1
PREP_DIV_B "IO1"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -b ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,tps,rtps,wtps\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -b ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -b ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "IO1" "IO: Total number of read/write/transfer requests per second issued to physical devices  (sar -b)" "Date & Time" "IO"
}

function GET_IO_2() {
c=1
PREP_DIV_B "IO2"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -b ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$7","$8" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,bread/s,bwrtn/s\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -b ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$7","$8"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -b ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$7","$8"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "IO2" "IO: Total amount of data read/write from the devices in blocks per second (sar -b)" "Date & Time" "IO"
}

function GET_MEM_1() {
c=1
PREP_DIV_B "MEM1"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -R ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,frmpg/s,bufpg/s,campg/s\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -R ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -R ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "MEM1" "Memory: Report memory statistics (sar -R)" "Date & Time" "KB"
}

function GET_MEM_2() {
## CUSTOM Function - forumla applies
c=1
PREP_DIV_B "MEM2"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		echo "\"MA timestamp,GB_FREE,GB_USED\n\" +"
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -r ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","($4+$7+$8)/1024/1024","($5-$7-$8)/1024/1024"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -r ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","($4+$7+$8)/1024/1024","($5-$7-$8)/1024/1024"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "MEM2" "Memory: Amount of used/free memory in GB (sar -r) + FORMULA to get ACTUALS" "Date & Time" "GB" 1
}

function GET_MEM_3() {
c=1
PREP_DIV_B "MEM3"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -r ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$6" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,%memused\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -r ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$6"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -r ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$6"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "MEM3" "Memory:Percentage of used memory (sar -r)" "Date & Time" "Percents"
}

function GET_SWAP_1() {
c=1
PREP_DIV_B "SWA1"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -S ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$6","$8" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,%swpused,%swpcad\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -S ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$6","$8"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -S ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$6","$8"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "SWA1" "SWAP: Percentage of used swap space / cached swap memory (sar -S)" "Date & Time" "KB"
}

function GET_SWAP_2() {
c=1
PREP_DIV_B "SWA2"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -S ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,kbswpfree,kbswpused\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -S ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -S ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "SWA2" "SWAP: Amount of free/used swap space in kilobytes (sar -S)" "Date & Time" "KB"
}

function GET_SWAP_3() {
c=1
PREP_DIV_B "SWA3"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -W ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,pswpin/s,pswpout/s\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -W ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -W ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "SWA3" "SWAP: Total number of swap pages the system brought in/out per second (sar -W)" "Date & Time" "KB"
}

function GET_PAG_1() {
c=1
PREP_DIV_B "PAG1"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -B ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7","$8","$9","$10","$11" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,pgpgin/s,pgpgout/s,fault/s,majflt/s,pgfree/s,pgscank/s,pgscand/s,pgsteal/s\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -B ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7","$8","$9","$10","$11"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -B ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7","$8","$9","$10","$11"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "PAG1" "Paging: Report paging statistics (sar -B)" "Date & Time" "Count"
}

function GET_INO_1() {
c=1
PREP_DIV_B "INO1"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -v ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,dentunusd,file-nr,inode-nr,pty-nr\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -v ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -v ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "INO1" "Inodes: Report status of inode, file and other kernel tables (sar -v)" "Date & Time" "Count"
}

function GET_TASK_1() {
c=1
PREP_DIV_B "TASK1"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -w ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,proc/s\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -w ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -w ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "TASK1" "Tasks: Total number of tasks created per second (sar -w)" "Date & Time" "Count"
}

function GET_TASK_2() {
c=1
PREP_DIV_B "TASK2"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -w ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$5" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,cswch/s\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -w ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$5"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -w ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$5"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "TASK2" "Tasks: Total number of context switches per second (sar -w)" "Date & Time" "Count"
}

function GET_TTY_1() {
tty=`${C_SADF} -d -t -- -y \`echo $list_file | ${C_AWK} '{print $1}'\` | grep -v "hostname" | ${C_AWK} -F ';' '{print $4}' | sort | uniq -c | ${C_AWK} '{print $2}'`
for j in ${tty}; do	
	c=1
	PREP_DIV_B "TTY1_${j}"
	for i in ${list_file} ; do
		if [ "$c" = 1 ]; then 			
			H=`${C_SADF} -d -t -- -y ${i} | grep "#" | ${C_AWK} -F ';' '$4 == "'${j}'" {print "\""$3","$4","$5","$6","$7","$8","$9","$10" \\\n\" +"}'`
			if [ -z "${H}" ]; then echo "\"MA timestamp,TTY,rcvin/s,txmtin/s,framerr/s,prtyerr/s,brk/s,ovrun/s\n\" +"; else echo ${H}; fi
		fi
		if [ $c = $l ]; then 	
			${C_SADF} -d -t -- -y ${i} | grep -v "#" | ${C_AWK} -F ';' '$4 == "'${j}'" {print "\""$3","$4","$5","$6","$7","$8","$9","$10"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
		else 							
			${C_SADF} -d -t -- -y ${i} | grep -v "#" | ${C_AWK} -F ';' '$4 == "'${j}'" {print "\""$3","$4","$5","$6","$7","$8","$9","$10"\\n\" +"}'
		fi
		c=$(($c + 1))
	done
	PREP_DIV_E_ST "TTY1_${j}" "TTY: Report TTY${j} device activity (sar -y)" "Date & Time" "Count"
done
}

## Magic with Network:
function GET_NET_1() {
c=1
PREP_DIV_B "NET1"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -n SOCK ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7","$8","$9" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,totsck,tcpsck,udpsck,rawsck,ip-frag,tcp-tw\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -n SOCK ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7","$8","$9"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -n SOCK ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7","$8","$9"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "NET1" "Network: statistics on sockets in use are reported (IPv4) (sar -n SOCK)" "Date & Time" "Number"
}

function GET_NET_2() {
c=1
PREP_DIV_B "NET2"
for i in ${list_file} ; do
	if [ "$c" = 1 ]; then 			
		H=`${C_SADF} -d -t -- -n NFS ${i} | grep "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7","$8","$9" \\\n\" +"}'`
		if [ -z "${H}" ]; then echo "\"MA timestamp,call/s,retrans/s,read/s,write/s,access/s,getatt/s\n\" +"; else echo ${H}; fi
	fi
	if [ $c = $l ]; then 	
		${C_SADF} -d -t -- -n NFS ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7","$8","$9"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
	else 							
		${C_SADF} -d -t -- -n NFS ${i} | grep -v "#" | ${C_AWK} -F ';' '{print "\""$3","$4","$5","$6","$7","$8","$9"\\n\" +"}'
	fi
	c=$(($c + 1))
done
PREP_DIV_E_ST "NET2" "Network: statistics about NFS client activity (sar -n NFS)" "Date & Time" "Number"
}

function GET_NET_3() {
iface=`${C_SADF} -d -t -- -n DEV \`echo $list_file | ${C_AWK} '{print $1}'\` | grep -v "IFACE" | ${C_AWK} -F ';' '{print $4}' | sort | uniq -c | ${C_AWK} '{print $2}'`
for j in ${iface}; do
	c=1
	PREP_DIV_B "NET3_${j}"
	for i in ${list_file} ; do
		if [ "$c" = 1 ]; then 			
			H=`${C_SADF} -d -t -- -n DEV ${i} | grep "#" | ${C_AWK} -F ';' '$4 == "'${j}'" {print "\""$3","$4","$5","$6","$7","$8","$9","$10" \\\n\" +"}'`
			if [ -z "${H}" ]; then echo "\"MA timestamp,rxpck/s,txpck/s,rxkB/s,txkB/s,rxcmp/s,txcmp/s,rxmcst/s\n\" +"; else echo ${H}; fi
		fi
		if [ $c = $l ]; then 	
			${C_SADF} -d -t -- -n DEV ${i} | grep -v "#" | ${C_AWK} -F ';' '$4 == "'${j}'" {print "\""$3","$4","$5","$6","$7","$8","$9","$10"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
		else 							
			${C_SADF} -d -t -- -n DEV ${i} | grep -v "#" | ${C_AWK} -F ';' '$4 == "'${j}'" {print "\""$3","$4","$5","$6","$7","$8","$9","$10"\\n\" +"}'
		fi
		c=$(($c + 1))
	done
	PREP_DIV_E_ST "NET3_${j}" "Network: statistics from the network device ${j} (sar -n DEV)" "Date & Time" "Number"
done
}

function GET_DISK_1() {
disk=`${C_SADF} -d -t -- -d \`echo $list_file | ${C_AWK} '{print $1}'\` | grep -v "hostname" | ${C_AWK} -F ';' '{print $4}' | sort | uniq -c | ${C_AWK} '{print $2}'`
for j in ${disk}; do
	c=1
	PREP_DIV_B "DISK_${j}"
	for i in ${list_file} ; do
		if [ "$c" = 1 ]; then 			
			H=`${C_SADF} -d -t -- -d ${i} | grep "#" | ${C_AWK} -F ';' '$4 == "'${j}'" {print "\""$3","$4","$5","$6","$7","$8","$9" \\\n\" +"}'`
			if [ -z "${H}" ]; then echo "\"MA timestamp,tps;rd_sec/s,wr_sec/s,avgrq-sz,avgqu-sz,await,svctm\n\" +"; else echo ${H}; fi
		fi
		if [ $c = $l ]; then 	
			${C_SADF} -d -t -- -d ${i} | grep -v "#" | ${C_AWK} -F ';' '$4 == "'${j}'" {print "\""$3","$4","$5","$6","$7","$8","$9"\\n\" +"}'  | ${C_SED} '$ s/+/,/g'
		else 							
			${C_SADF} -d -t -- -d ${i} | grep -v "#" | ${C_AWK} -F ';' '$4 == "'${j}'" {print "\""$3","$4","$5","$6","$7","$8","$9"\\n\" +"}'
		fi
		c=$(($c + 1))
	done
	PREP_DIV_E_ST "DISK_${j}" "Disk: Report activity for block device ${j} (sar -d)" "Date & Time" "Number"
done
}


###### ACTUAL EXECUTION

GET_H 			> ${O_FILE}
GET_CPU_1 		>> ${O_FILE}
GET_LA_1 		>> ${O_FILE}
GET_LA_2 		>> ${O_FILE}
GET_LA_3 		>> ${O_FILE}
GET_IO_1 		>> ${O_FILE}
GET_IO_2 		>> ${O_FILE}
GET_MEM_1 		>> ${O_FILE}
GET_MEM_2 		>> ${O_FILE}
GET_MEM_3 		>> ${O_FILE}
GET_SWAP_1 		>> ${O_FILE}
GET_SWAP_2 		>> ${O_FILE}
GET_SWAP_3 		>> ${O_FILE}
GET_PAG_1 		>> ${O_FILE}
GET_INO_1 		>> ${O_FILE}
GET_TASK_1 		>> ${O_FILE}
GET_TASK_2 		>> ${O_FILE}
GET_TTY_1 		>> ${O_FILE}
# Network
GET_NET_1 		>> ${O_FILE}
GET_NET_2 		>> ${O_FILE}
GET_NET_3		>> ${O_FILE}
GET_DISK_1		>> ${O_FILE}

GET_HE 			>> ${O_FILE}

echo "Outpufile: ${O_FILE}"
