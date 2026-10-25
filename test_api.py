#!/usr/bin/env python3

import requests
import json

# API endpoint
url = "https://palengke-plus-api.onrender.com/api/vendor-auth/login"
headers = {
    "Content-Type": "application/json"
}

# Test data
payload = {
    "username": "vendor@example.com",
    "password": "password123"
}

# Send POST request
response = requests.post(url, headers=headers, data=json.dumps(payload))

# Print response
print(f"Status Code: {response.status_code}")
print(f"Response: {response.text}")