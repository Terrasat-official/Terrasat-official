import os
import json
from web3 import Web3
from dotenv import load_dotenv

# Load secrets from .env
load_dotenv()

AMOY_RPC_URL = os.getenv("AMOY_RPC_URL")
PRIVATE_KEY = os.getenv("PRIVATE_KEY")
ACCOUNT_ADDRESS = os.getenv("ACCOUNT_ADDRESS")
CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS")
ABI_PATH = os.getenv("ABI_PATH")

# Connect to Polygon Amoy RPC
web3 = Web3(Web3.HTTPProvider(AMOY_RPC_URL))
assert web3.is_connected(), "❌ Could not connect to Polygon Amoy RPC"

print("✅ Connected to Polygon Amoy")
print("Chain ID:", web3.eth.chain_id)

# Load ABI
with open(ABI_PATH, "r") as f:
    abi = json.load(f)

# Get contract object
contract = web3.eth.contract(address=CONTRACT_ADDRESS, abi=abi)

# Example: Read totalSupply() from ERC20-like contract
try:
    total_supply = contract.functions.totalSupply().call()
    print("📦 Total Supply:", total_supply)
except Exception as e:
    print("⚠️ Could not read totalSupply:", e)
 