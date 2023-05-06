import requests
from fetch_api_response import get_the_info
from g_sheet import post_the_info


def Friends():
    content = get_the_info("https://secure.splitwise.com/api/v3.0/get_friends")
    Friends_user_id = {}
    User_IDs = []
    for people in range(len(content['friends'])):
        User_IDs.append(content['friends'][people]['id'])
        Friends_user_id[content['friends'][people]['first_name']] = content['friends'][people]['id']
    return Friends_user_id


def Balance():
    Buddys = Friends()
    list_of_ids = list(Buddys.values())
    all_balances = []
    for ids in range(len(list_of_ids)):
        a_friend = get_the_info("https://secure.splitwise.com/api/v3.0/get_friend/{}".format(list_of_ids[ids]))
        all_balances.append(float(a_friend['friend']['balance'][0]['amount']))
    return all_balances

def lambda_handler(event, context):
    balance = sum(Balance())
    post_the_info(balance)
    print(balance)