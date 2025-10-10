# OAuth testing (dev)

This document explains how to use the included `scripts/oauth_test_client.py` to test the MediaWiki OAuth extension in a development environment.

Prerequisites
- Python 3
- pip packages: `requests`, `requests_oauthlib` (install with `pip install requests requests_oauthlib`)
- Your MediaWiki instance should be running locally (default: `http://localhost:8080`).
- An OAuth consumer registered in the wiki (Special:OAuth) to obtain a consumer key & secret.

Quick run

1. Export your consumer credentials and optionally the wiki base URL:

```bash
export CONSUMER_KEY='your_consumer_key'
export CONSUMER_SECRET='your_consumer_secret'
export MW_BASE='http://localhost:8080'
```

2. Run the script:

```bash
python3 scripts/oauth_test_client.py
```

3. The script will print an authorization URL. Open it, authorize the consumer as your admin user, and copy the `oauth_verifier` (PIN) shown after authorization back into the script prompt.

4. The script exchanges the request token for an access token and performs a simple `action=query&meta=userinfo` API call. The JSON response is printed.

Notes
- If MediaWiki is not at the root path (for example, served under `/w` or `/wiki`), adjust the `MW_BASE` accordingly and edit `scripts/oauth_test_client.py` endpoints.
- If you prefer a browser redirect callback (instead of `oob`), change the `callback_uri` when creating the OAuth1Session and register the matching redirect URI when creating the consumer.
- For production testing, use a real SMTP provider or your organization's mail flow to receive confirmation emails (do not mark emails confirmed in DB in production).
