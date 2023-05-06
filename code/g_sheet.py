import gspread
from oauth2client.service_account import ServiceAccountCredentials
import boto3
import json
import os

Bucket_name = os.environ['Bucket']
Bucket_key = os.environ['Bucket_key']

def post_the_info(value):
    scope = ["https://spreadsheets.google.com/feeds",'https://www.googleapis.com/auth/spreadsheets',"https://www.googleapis.com/auth/drive.file","https://www.googleapis.com/auth/drive"]
    s3 = boto3.client('s3')
    s3.download_file(Bucket_name, Bucket_key, '/tmp/gspread_json_file.json')
    creds = ServiceAccountCredentials.from_json_keyfile_name("/tmp/gspread_json_file.json",scope)
    client = gspread.authorize(creds)
    sheet = client.open(os.environ['Sheets'])
    sheet_instance = sheet.get_worksheet(0)
    print (sheet_instance)
    sheet_instance.update(os.environ['Column'], value)