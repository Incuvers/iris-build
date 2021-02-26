# Secrets
Modified: 2021-02

## Note on Github Actions & Secret Management
These secrets are stored as secrets under the Incuvers organization and are passed to this action through environment variables. For the sake of running this server in isolation this folder is available for dumping secrets.


Required contents:
| File           | Reason                                                                         |
|----------------|--------------------------------------------------------------------------------|
| slack.key      | Slack API webhook url notification                                             |
| access_key.key | AWS S3 bucket access key                                                       |
| access_id.key  | AWS S3 bucket access id                                                        |

## AWS S3 Access Tokens
We use AWS S3 to store completed snap build files so that any device can pull the snap file and install it. We create a bucket for this file and store the access tokens here.

## Slack API Webhook Identifier
The slack notification url will include this string sequence identifying the channel and the webhook id.
