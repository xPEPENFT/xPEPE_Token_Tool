import xrpl
from xrpl.models import AccountLines
from time import sleep
import os
import time

# CONFIG ---------------------------------------------------------------------
# ----------------------------------------------------------------------------
target_address = "rw5e5krAvv1DrWyzmEr1NtNzg5jR26u5Gj" # Fill out with your target address

script_dir = os.path.dirname(__file__)
rel_path = "./text_files/exempt.txt"
ex_path = os.path.join(script_dir, rel_path)
rel_path = "./text_files/richlist.txt"
rich_path = os.path.join(script_dir, rel_path)

# Get exempt list from file
list_of_exempt_addresses = []
try:
    f = open(ex_path, 'r')
    address = f.readline().replace('\n', '')
    while address != "":
        list_of_exempt_addresses.append(address)
        address = f.readline().replace('\n', '')
    f.close()
except:
    print("No exempt.txt file!")
    sleep(3)

# Declaring Variables --------------------------
account_tracker = 0
list_of_addresses = []
url = "wss://xrpl.ws/"
poll_limit = 200

# Start loop -----------------------------------
while True:
    try:
        with xrpl.clients.WebsocketClient(url) as client:
            account_lines = client.request(AccountLines(account=target_address, limit=poll_limit))
            while account_lines.result['marker']:
                for account in account_lines.result['lines']:
                    account_tracker += 1
                    list_of_addresses.append(account)
                    print(f"#{account_tracker}\tAccount {account['account']}\tBalance: {account['balance']}")
                last = account_lines.result['marker']
                account_lines = client.request(AccountLines(account=target_address, limit=poll_limit, marker=account_lines.result['marker']))

                if account_lines.status == 'error': # If error recieved, reconnect to websocket and retry
                    print("Response error received\nReconnecting...")
                    account_tracker = 0
                    list_of_addresses = []
                    break
            continue

    except KeyError as e:
        if 'marker' in e.args:
            while True:
                for account in account_lines.result['lines']:
                    account_tracker += 1
                    list_of_addresses.append(account)
                    print(f"#{account_tracker}\tAccount {account['account']}\tBalance: {account['balance']}")
                # currency = account_lines.result['lines'][0]['currency'] # Experimental line for grabbing currency name and using it in text file
                break
            break
        if 'lines' in e.args:
            account_lines = client.request(AccountLines(account=target_address, limit=poll_limit, marker=account_lines.result['marker']))
            continue
    break

# Check for duplicates-----------------------------------
cross_reference_list = []
for account in list_of_addresses:
    if account not in cross_reference_list:
        cross_reference_list.append(account)
    else:
        print(f"Duplicated found and removed: {account}")

# Convert to appropriate format -------------------------
for account in cross_reference_list:
    account['balance'] = float(account['balance']) * -1

# Sort --------------------------------------------------
def sort_list(account):
    return account['balance']
cross_reference_list.sort(key=sort_list, reverse=True)

# Write to file
with open(rich_path, "w+") as f:
    for account in cross_reference_list:
        if account['account'] not in list_of_exempt_addresses:
            if account['balance'] > 0:
                f.write(f"{account['account']}, Balance: {account['balance']}\n")