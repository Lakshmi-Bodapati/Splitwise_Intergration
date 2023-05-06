import requests
import os
import boto3

ssm = boto3.client('ssm')

def get_the_info(url):
    # Replace <YOUR_API_KEY> with your actual API key
    response = ssm.get_parameter(Name=os.environ['S_key'], WithDecryption=True)
    parameter_value = response['Parameter']['Value']
    API_KEY = parameter_value
    # Set the API key as a header in the request
    headers = {"Authorization": f"Bearer {API_KEY}"}

    # Make the GET request with the headers
    response = requests.get(url, headers=headers)

    # Check the response status code
    if response.status_code == 200:
        # Success! Do something with the response
        content = response.json()
        #print(response.json())
        return content
    else:
        # Handle the error
        print(f"Error {response.status_code}: {response.text}")