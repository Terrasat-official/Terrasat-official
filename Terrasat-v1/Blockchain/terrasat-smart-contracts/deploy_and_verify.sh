#!/bin/bash/
set -euo pipefail

# -------------------------------
# Deploy & Verify CarbonCreditToken
# -------------------------------

CONTRACT_PATH="src/CarbonCreditToken.sol:CarbonCreditToken"
CHAIN_ID=80002
PYTHON_SCRIPT="test_contract.py"

# 0️⃣ Load environment variables from .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "❌ .env file not found. Exiting."
  exit 1
fi

# 1️⃣ Check required vars
if [ -z "${AMOY_RPC_URL:-}" ]; then
  echo "❌ Please set AMOY_RPC_URL in .env"
  exit 1
fi

if [ -z "${PRIVATE_KEY:-}" ]; then
  echo "❌ Please set PRIVATE_KEY in .env"
  exit 1
fi

# 2️⃣ Compile the contract
echo "🔹 Compiling contract..."
forge build

# 3️⃣ Deploy the contract
echo "🔹 Deploying contract..."
CONTRACT_OUTPUT=$(forge create "$CONTRACT_PATH" \
    --rpc-url "$AMOY_RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --chain-id "$CHAIN_ID" \
    --broadcast \
    --json)

CONTRACT_ADDRESS=$(echo "$CONTRACT_OUTPUT" | jq -r '.deployedTo')

if [ -z "$CONTRACT_ADDRESS" ] || [ "$CONTRACT_ADDRESS" == "null" ]; then
    echo "❌ Deployment failed. Exiting."
    exit 1
fi

echo "✅ Contract deployed at $CONTRACT_ADDRESS"

# 4️⃣ Update .env automatically
if grep -q "CONTRACT_ADDRESS=" .env; then
    sed -i "s/^CONTRACT_ADDRESS=.*/CONTRACT_ADDRESS=$CONTRACT_ADDRESS/" .env
else
    echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS" >> .env
fi
echo "✅ Updated .env with new contract address"

# 5️⃣ Verify contract on Polygonscan (if API key available)
if [ -n "${ETHERSCAN_API_KEY:-}" ]; then
    echo "🔹 Verifying contract on Polygonscan..."
    if forge verify-contract \
        --chain-id "$CHAIN_ID" \
        --etherscan-api-key "$ETHERSCAN_API_KEY" \
        "$CONTRACT_ADDRESS" \
        "$CONTRACT_PATH"; then
        echo "✅ Contract verified on Polygonscan"
    else
        echo "⚠️ Verification failed or skipped"
    fi
else
    echo "⚠️ ETHERSCAN_API_KEY not set. Skipping verification."
fi

# 6️⃣ Run Python script
if [ -f "$PYTHON_SCRIPT" ]; then
    echo "🔹 Running Python interaction script..."
    python3 "$PYTHON_SCRIPT"
else
    echo "⚠️ Python script $PYTHON_SCRIPT not found. Skipping."
fi

echo "🎉 Deployment, verification & interaction completed!"
















