# @version >=0.2.4 <0.3.0

# Total supply
totalSupply: public(uint256)

# Decimals
decimals: constant(uint256) = 18

# Token name
tokenName: public(String[32])

# Symbol
tokenSymbol: public(String[32])

# Owner of the smart contract
owner: public(address)

# Proposed owner (in case we want to change it)
proposedOwner: public(address)

# Token balance for an address
tokenBalance: public(HashMap[address, uint256])

# Token allowance for an address
tokenAllowance: public(HashMap[address, HashMap[address, uint256]])

# Paused or not
paused: public(bool)

# Events
event Transfer:
    fromUser: address
    toUser: address
    amount: uint256

event Give_Allowance:
    fromUser: address
    toUser: address
    amount: uint256

event Remove_Allowance:
    fromUser: address
    toUser: address
    amount: uint256

# Constructor
@external
def __init__(_totalSupply: uint256, _tokenName: String[32], _tokenSymbol: String[32]):
    self.owner = msg.sender
    self.totalSupply = _totalSupply
    self.tokenName = _tokenName
    self.tokenSymbol = _tokenSymbol

    # Mint the whole balance to the owner
    self.tokenBalance[msg.sender] = _totalSupply

# Give allowance function [internal]
@internal
def _give_allowance(fromUser: address, spender: address, allowance: uint256) -> bool:
    assert self.tokenAllowance[fromUser][spender] + allowance <= self.totalSupply
    self.tokenAllowance[fromUser][spender] += allowance
    log Give_Allowance(fromUser, spender, allowance)
    return True

# Remove allowance function [internal]
@internal
def _remove_allowance(fromUser: address, spender: address, allowance: uint256) -> bool:
    self.tokenAllowance[fromUser][spender] -= allowance
    log Remove_Allowance(fromUser, spender, allowance)
    return True

# Transfer function [internal]
@internal
def _transfer(fromUser: address, toUser: address, amount: uint256) -> bool:
    self.tokenBalance[fromUser] -= amount
    self.tokenBalance[toUser] += amount
    log Transfer(fromUser, toUser, amount)
    return True

# Give allowance [external]
@external
def give_allowance(spender: address, allowance: uint256):
    assert self._give_allowance(msg.sender, spender, allowance)

# Remove allowance [external]
@external
def remove_allowance(spender: address, allowance: uint256):
    assert self._give_allowance(msg.sender, spender, allowance)

# Transfer function [external]
@external
def transfer(toUser: address, amount: uint256):
    assert self._transfer(msg.sender, toUser, amount)

# Transfer from function [external]
@external
def transferFrom(fromUser: address, toUser: address, amount: uint256):
    assert self.tokenAllowance[fromUser][msg.sender] >= amount
    self._remove_allowance(fromUser, msg.sender, amount)
    self._transfer(fromUser, toUser, amount)

