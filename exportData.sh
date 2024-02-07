echo "***************************************************************************************"
echo "Welcome to Dynamodb Data Json Exporter"
echo "It will export your DYnamodb data to multiple Json"
echo "Before we started, please check your aws configure and install jq"


echo "Please enter the table destination name: "
read -e table_target_name

echo "Please enter the table origin name: "
read -e table_name

echo "Do you want to export data from dynamodb? [Y\N]"
read -e needExport


if [ $needExport = "Y" ] || [ $needExport = "y" ]
then

echo "Please enter the region: "
read -e aws_region_name

#echo "Please enter the max-items for each json: "
#because only send up to 25 items in a single BatchWriteItem request
max_items=100

index=0
start_time="$(date -u +%s)"


if [ ! -d $table_target_name ]
then
    echo "created folder ${table_target_name}"
    mkdir $table_target_name
fi

if [ ! -d $table_target_name/data ]
then
    echo "created folder ${table_target_name}/data"
    mkdir $table_target_name/data
fi
aws dynamodb scan --table-name $table_name --region $aws_region_name --max-items $max_items --output json > ./$table_target_name/data/$index.json

nextToken=$(cat ./$table_target_name/data/$index.json | jq '.NextToken')
#[ ! -z "${nextToken}" ] && echo "not null"
#echo $nextToken

#echo $(cat ./$table_target_name/data/$index.json | jq '.Items') > ./$table_target_name/data/$index.json
((index+=1))


echo "created ${index} dataset"
  
while [ ! -z "${nextToken}" ] && [ "${nextToken}" != "null" ]
do
  aws dynamodb scan --table-name $table_name --region $aws_region_name --max-items $max_items --starting-token $nextToken --output json > ./$table_target_name/data/$index.json
  nextToken=$(cat ./$table_target_name/data/$index.json | jq '.NextToken')
  #echo $(cat ./$table_target_name/data/$index.json | jq '.Items') > ./$table_target_name/data/$index.json
  ((index+=1))
  echo "created ${index} dataset"
done

end_export_time="$(date -u +%s)"
echo "used $(($end_export_time-$start_time)) seconds for export data"

fi


if [ ! -d $table_target_name/ScriptForDataImport ]
then
    echo "created folder ${table_target_name}/ScriptForDataImport"
    mkdir $table_target_name/ScriptForDataImport
fi

#split record to aws batch insert cli
for filename in $table_target_name/data/*.json; do
    file=${filename##*/}
    cat $filename | jq '.Items' | jq -cM --argjson sublen '25' 'range(0; length; $sublen) as $i | .[$i:$i+$sublen]' | split -l 1 - ${table_target_name}/ScriptForDataImport/${file%.*}_
done

for filename in $table_target_name/ScriptForDataImport/*; do
    echo "processing ${filename##*/}"
    cat $filename | jq "{\"$table_target_name\": [.[] | {PutRequest: {Item: .}}]}" > $table_target_name/ScriptForDataImport/${filename##*/}.txt
    rm $filename
    #sed -e '1s/testing/hello/;t' -e '1,/testing/s//hello/' file3.txt > file4.txt
done

end_convert_time="$(date -u +%s)"
echo "used $(($end_convert_time-$end_export_time)) seconds for generating the  insert scripts"




echo "Completed"
echo "***************************************************************************************"
end_func_time="$(date -u +%s)"
echo "Total of $(($end_func_time-$start_time)) seconds to completed the function"

#echo $(cat ./test.txt | jq '{"my-local-table": [.Items[] | {PutRequest: {Item: .}}]}') > testFormat.txt
  
  


#cat ./test.txt | jq -cM --argjson sublen '2' 'range(0; length; $sublen) as $i | .[$i:$i+$sublen]' ./testSplit.txt

#cat ./testSplit.txt | jq '.Items' | jq -cM --argjson sublen '2' 'range(0; length; $sublen) as $i | .[$i:$i+$sublen]' | map(.a)' f?.json


#echo $(cat ./testSplit.txt | jq '.Items' | jq -cM --argjson sublen '2' 'range(0; length; $sublen) as $i | .[$i:$i+$sublen]' | jq '{"my-local-table": [.[] | {PutRequest: {Item: .}}]}' ) > arr.txt

#echo $(cat ./arr.txt | jq '{"my-local-table": [.[] | {PutRequest: {Item: .}}]}')


#cat ./testSplit.txt | jq '.Items' | jq -cM --argjson sublen '2' 'range(0; length; $sublen) as $i | .[$i:$i+$sublen]' | split -l 1 - split2


#cat ./a.txt | jq '.my-local-table'

