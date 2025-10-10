#!/usr/bin/env python3
"""
Simple interactive OAuth 1.0a test client for MediaWiki OAuth extension.

Usage: fill the CONSUMER_KEY and CONSUMER_SECRET below or export them as
environment variables CONSUMER_KEY and CONSUMER_SECRET. Run with:

    python3 scripts/oauth_test_client.py

This script will:
 - fetch a request token
 - print an authorization URL for you to open in a browser
 - accept the oauth_verifier you get after authorizing
 - exchange tokens for an access token
 - make a simple API call using the access token and print the JSON

Requires: requests, requests_oauthlib
    pip install requests requests_oauthlib
"""
import os
import webbrowser
from requests_oauthlib import OAuth1Session

# Fill these in or export as env vars
CONSUMER_KEY = os.environ.get('CONSUMER_KEY') or 'YOUR_CONSUMER_KEY'
CONSUMER_SECRET = os.environ.get('CONSUMER_SECRET') or 'YOUR_CONSUMER_SECRET'

# Endpoints (edit for your wiki)
BASE = os.environ.get('MW_BASE', 'http://localhost:8080')
REQUEST_TOKEN_URL = f"{BASE}/w/index.php?title=Special:OAuth/initiate"
AUTHORIZE_URL = f"{BASE}/w/index.php?title=Special:OAuth/authorize"
ACCESS_TOKEN_URL = f"{BASE}/w/index.php?title=Special:OAuth/token"
API_URL = f"{BASE}/w/api.php"

def main():
    key = CONSUMER_KEY
    secret = CONSUMER_SECRET
    if key.startswith('YOUR_') or secret.startswith('YOUR_'):
        print('Please set CONSUMER_KEY and CONSUMER_SECRET environment variables or edit the script.')
        return

    oauth = OAuth1Session(key, client_secret=secret, callback_uri='oob')

    print('Requesting request token...')
    fetch_response = oauth.fetch_request_token(REQUEST_TOKEN_URL)
    resource_owner_key = fetch_response.get('oauth_token')
    resource_owner_secret = fetch_response.get('oauth_token_secret')

    auth_url = oauth.authorization_url(AUTHORIZE_URL)
    print('\nOpen this URL in your browser to authorize:')
    print(auth_url)
    try:
        webbrowser.open(auth_url)
    except Exception:
        pass

    verifier = input('\nAfter authorizing, enter the oauth_verifier (pin) shown: ').strip()

    oauth = OAuth1Session(key,
                          client_secret=secret,
                          resource_owner_key=resource_owner_key,
                          resource_owner_secret=resource_owner_secret,
                          verifier=verifier)

    print('\nExchanging request token for access token...')
    tokens = oauth.fetch_access_token(ACCESS_TOKEN_URL)
    access_token = tokens.get('oauth_token')
    access_secret = tokens.get('oauth_token_secret')
    print('Access token:', access_token)

    # Make a signed API call as a quick smoke test
    oauth = OAuth1Session(key,
                          client_secret=secret,
                          resource_owner_key=access_token,
                          resource_owner_secret=access_secret)

    print('\nCalling action=query&meta=userinfo...')
    r = oauth.get(API_URL, params={'action':'query','meta':'userinfo','format':'json'})
    print('\nAPI response:')
    print(r.text)

if __name__ == '__main__':
    main()
