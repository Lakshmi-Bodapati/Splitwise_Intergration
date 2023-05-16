# Splitwise_Intergration

This Code base allows you to post your total balance in your Splitwise account into your Gsheets.

## Prequsits

1. Add an input variable file (As shown in the Example section) to the directorie from where you run the terraform or you can provide inputs while running the terraform.
    | Input Variables | Description |
    | ------------- | ------------- |
    | Bucket  | Give Name to the bucket which will get created by terraform|
    | Bucket_key  | Name of the JSON File that should be uploaded. Follow step 2 for JSON file| 
    | CRON | Provide CRON JOB to run lambda in specified intervals |
    | split-key | Key can be obtained by following this Document https://dev.splitwise.com/#section/Authentication |
    | Gsheet-name | Name of the G-Sheet |
    | Place-to-insert  | Enter Cell at which value from splitwise should appear in G-Sheet |
2. Folow the steps from this Document (https://www.geeksforgeeks.org/how-to-automate-google-sheets-with-python/) until downloading keys in JSON File, Add that Json file in your working directory.
3. Run the following terraform commands to start creating infra on AWS Cloud. (Dont forget to Configure AWS (aws configure) on your terminal and install terraform before running these commands)

```
terraform init
terraform plan -var-file <provide your input variable file here>
terraform apply -var-file <provide your input variable file here>
```
