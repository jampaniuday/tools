#!/bin/bash

E_file=$1
I_file=$2

if [ "$#" -lt  "2" ] ; then
 echo "No arugments supplied"
 echo "./program.sh <full_path_export_file> <fill_path_import_file>"
 exit 
fi

echo "OVERALL object count review"
echo "---------------------------"
l_e=`cat $E_file | grep '. . exported' | wc -l`
l_i=`cat $I_file | grep '. . imported' | wc -l`
echo "Exported table count:" $l_e
echo "Imported table count:" $l_i
echo " "

cat $E_file | grep '. . exported'| sort | awk '{print $3" "$4" "$5" "$6" "$7" "$8""}' > /tmp/o1.lst

echo "TABLE status review"
echo "-------------------"

while read -r line; 
do 
  obj=`echo $line| awk '{print $2}'`
  count=`echo $line| awk '{print $5}'`
  ismatch=''
  ismatch=`cat $I_file | grep '. . imported' | grep $obj`

  i_obj=` echo $ismatch | awk '{print $4}'`
  i_count=` echo $ismatch | awk '{print $7}'`

  if [ "$obj" = "$i_obj" ]; then
    if [ "$count" = "$i_count" ]; then
      # all good
      #echo $obj" "$count" "$i_obj" "$i_count
      printf "%-50s %12s %-50s %12s\n" "Exported: $obj" "$count" " -> Imported $i_obj" "$i_count rows"
    else
      # row mismatch
      #echo $obj" "$count" "$i_obj" "$i_count >> /tmp/o2.lst
      #echo $obj" "$count" "$i_obj" "$i_count" !!! ROW mistmatch"
      printf "%-50s %12s %-50s %12s\n" "Exported: $obj" "$count" " -> Imported $i_obj" "$i_count !!! ROW MISTMATCH" >> /tmp/o2.lst
      printf "%-50s %12s %-50s %12s\n" "Exported: $obj" "$count" " -> Imported $i_obj" "$i_count !!! ROW MISTMATCH"
    fi

  else
    # object mistmatch
   #echo $obj" "$count" "$i_obj" "$i_count >> /tmp/o3.lst
   #echo $obj" "$count" "$i_obj" "$i_count" !!! TABLE  mistmatch"
   printf "%-50s %12s %-50s\n" "Exported: $obj" "$count" " -> !!! Imported TABLE NOT FOUND" >> /tmp/o3.lst
   printf "%-50s %12s %-50s\n" "Exported: $obj" "$count" " -> !!! Imported TABLE NOT FOUND" 
  fi
  
 #echo $obj" "$count" "$i_obj" "$i_count
done < /tmp/o1.lst

echo " "
echo "######"
echo "REPORT"
echo "######"

echo " "
echo "Totally exported $l_e tables & imported $l_i"

if [[ -f /tmp/o2.lst ]]; then t1=`cat /tmp/o2.lst | wc -l `; else t1=0; fi
if [[ -f /tmp/o3.lst ]]; then t2=`cat /tmp/o3.lst | wc -l `; else t2=0; fi

echo "List of missed tables: $t2"
echo "------------------------"
if [[ -f /tmp/o3.lst ]]; then cat /tmp/o3.lst ; fi

echo " "
echo "List of lines mistmatch: $t1"
echo "--------------------------"
if [[ -f /tmp/o2.lst ]]; then cat /tmp/o2.lst ; fi


if [[ -f /tmp/o1.lst ]]; then rm /tmp/o1.lst ; fi
if [[ -f /tmp/o2.lst ]]; then rm /tmp/o2.lst ; fi
if [[ -f /tmp/o3.lst ]]; then rm /tmp/o3.lst ; fi

[oracle@DLVMSTAR1 dump]$ 
[oracle@DLVMSTAR1 dump]$ 
[oracle@DLVMSTAR1 dump]$ 
[oracle@DLVMSTAR1 dump]$ 
[oracle@DLVMSTAR1 dump]$ 
[oracle@DLVMSTAR1 dump]$ 
[oracle@DLVMSTAR1 dump]$ cat compare_datapump_logs.sh 
#!/bin/bash

E_file=$1
I_file=$2

if [ "$#" -lt  "2" ] ; then
 echo "No arugments supplied"
 echo "./program.sh <full_path_export_file> <fill_path_import_file>"
 exit 
fi

echo "OVERALL object count review"
echo "---------------------------"
l_e=`cat $E_file | grep '. . exported' | wc -l`
l_i=`cat $I_file | grep '. . imported' | wc -l`
echo "Exported table count:" $l_e
echo "Imported table count:" $l_i
echo " "

cat $E_file | grep '. . exported'| sort | awk '{print $3" "$4" "$5" "$6" "$7" "$8""}' > /tmp/o1.lst

echo "TABLE status review"
echo "-------------------"

while read -r line; 
do 
  obj=`echo $line| awk '{print $2}'`
  count=`echo $line| awk '{print $5}'`
  ismatch=''
  ismatch=`cat $I_file | grep '. . imported' | grep $obj`

  i_obj=` echo $ismatch | awk '{print $4}'`
  i_count=` echo $ismatch | awk '{print $7}'`

  if [ "$obj" = "$i_obj" ]; then
    if [ "$count" = "$i_count" ]; then
      # all good
      #echo $obj" "$count" "$i_obj" "$i_count
      printf "%-50s %12s %-50s %12s\n" "Exported: $obj" "$count" " -> Imported $i_obj" "$i_count rows"
    else
      # row mismatch
      #echo $obj" "$count" "$i_obj" "$i_count >> /tmp/o2.lst
      #echo $obj" "$count" "$i_obj" "$i_count" !!! ROW mistmatch"
      printf "%-50s %12s %-50s %12s\n" "Exported: $obj" "$count" " -> Imported $i_obj" "$i_count !!! ROW MISTMATCH" >> /tmp/o2.lst
      printf "%-50s %12s %-50s %12s\n" "Exported: $obj" "$count" " -> Imported $i_obj" "$i_count !!! ROW MISTMATCH"
    fi

  else
    # object mistmatch
   #echo $obj" "$count" "$i_obj" "$i_count >> /tmp/o3.lst
   #echo $obj" "$count" "$i_obj" "$i_count" !!! TABLE  mistmatch"
   printf "%-50s %12s %-50s\n" "Exported: $obj" "$count" " -> !!! Imported TABLE NOT FOUND" >> /tmp/o3.lst
   printf "%-50s %12s %-50s\n" "Exported: $obj" "$count" " -> !!! Imported TABLE NOT FOUND" 
  fi
  
 #echo $obj" "$count" "$i_obj" "$i_count
done < /tmp/o1.lst

echo " "
echo "######"
echo "REPORT"
echo "######"

echo " "
echo "Totally exported $l_e tables & imported $l_i"

if [[ -f /tmp/o2.lst ]]; then t1=`cat /tmp/o2.lst | wc -l `; else t1=0; fi
if [[ -f /tmp/o3.lst ]]; then t2=`cat /tmp/o3.lst | wc -l `; else t2=0; fi

echo "List of missed tables: $t2"
echo "------------------------"
if [[ -f /tmp/o3.lst ]]; then cat /tmp/o3.lst ; fi

echo " "
echo "List of lines mistmatch: $t1"
echo "--------------------------"
if [[ -f /tmp/o2.lst ]]; then cat /tmp/o2.lst ; fi


if [[ -f /tmp/o1.lst ]]; then rm /tmp/o1.lst ; fi
if [[ -f /tmp/o2.lst ]]; then rm /tmp/o2.lst ; fi
if [[ -f /tmp/o3.lst ]]; then rm /tmp/o3.lst ; fi
