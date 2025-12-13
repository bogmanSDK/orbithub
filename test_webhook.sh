#!/bin/bash

# Test GitHub repository_dispatch webhook
# Usage: ./test_webhook.sh YOUR_GITHUB_TOKEN TICKET_KEY

if [ -z "$1" ]; then
  echo "❌ Error: GitHub token is required"
  echo "Usage: ./test_webhook.sh YOUR_GITHUB_TOKEN TICKET_KEY"
  echo ""
  echo "To get your token:"
  echo "1. Go to GitHub → Settings → Developer settings → Personal access tokens"
  echo "2. Generate new token (classic)"
  echo "3. Select 'repo' scope"
  exit 1
fi

GITHUB_TOKEN="$1"
TICKET_KEY="${2:-AIH-1}"  # Default to AIH-1 if not provided

echo "🧪 Testing GitHub repository_dispatch webhook..."
echo "📋 Ticket key: $TICKET_KEY"
echo "🔗 Repository: bogmanSDK/orbithub"
echo ""

# Make the request
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  https://api.github.com/repos/bogmanSDK/orbithub/dispatches \
  -d "{
    \"event_type\": \"ai-teammate-trigger\",
    \"client_payload\": {
      \"ticket_key\": \"$TICKET_KEY\"
    }
  }")

# Split response and status code
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
HTTP_BODY=$(echo "$RESPONSE" | sed '$d')

echo "📊 Response:"
echo "HTTP Status: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" = "204" ]; then
  echo "✅ SUCCESS! Webhook triggered successfully!"
  echo ""
  echo "🔍 Check GitHub Actions:"
  echo "   https://github.com/bogmanSDK/orbithub/actions"
  echo ""
  echo "💡 The workflow should appear in a few seconds"
elif [ "$HTTP_CODE" = "401" ]; then
  echo "❌ AUTHENTICATION FAILED"
  echo "   Check if your token is valid and has 'repo' scope"
elif [ "$HTTP_CODE" = "404" ]; then
  echo "❌ NOT FOUND"
  echo "   Check if repository 'bogmanSDK/orbithub' exists and is accessible"
elif [ "$HTTP_CODE" = "422" ]; then
  echo "❌ VALIDATION ERROR"
  echo "   Response: $HTTP_BODY"
  echo "   Check if event_type matches workflow configuration"
else
  echo "❌ ERROR: HTTP $HTTP_CODE"
  echo "   Response: $HTTP_BODY"
fi

echo ""
echo "📝 Full response body:"
echo "$HTTP_BODY" | jq . 2>/dev/null || echo "$HTTP_BODY"

