## Description

Move Dynamodb data to another region or account using AWS cli and Bash

## Installation

```bash (Linux/Mac)

Install aws cli and jq before start

#setup aws cli
$aws configure

```

## Running the app
```bash
#Export
# export data as json from dynamodb and convert it to batch-write-item format
$ ./exportData.sh


#Import
# Import data using batch-write-item to AWS
$ ./importData.sh


#Import from some dynamo table to other dynamotable
$ ./import.sh

#please ensure your aws configure is using correct key

```


CREDITS FROM https://github.com/mickey2012ex/dynamodb-data-migrator/tree/main