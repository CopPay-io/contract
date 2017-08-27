pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract ConpayToken is StandardToken, Ownable {
  string public name = 'ConpayToken';
  string public symbol = 'COP';
  uint public decimals = 18;

  uint public constant crowdsaleEndTime = 1509580800;
  uint public constant crowdsaleTokensSupply = 1000000000 * (10**18);

  uint256 public startTime;
  uint256 public endTime;
  uint256 public tokensSupply;
  uint256 public rate;
  uint256 public perAddressCap;
  address public wallet;

  uint256 public tokensSold;

  bool public stopped; 
  event SaleStart();
  event SaleStop();

  modifier crowdsaleTransferLock() {
    require(now > crowdsaleEndTime || tokensSold >= crowdsaleTokensSupply);
    _;
  }

  function ConpayToken() {
    totalSupply = 2325000000 * (10**18);
    balances[msg.sender] = totalSupply;
    startSale(
      1503921600, /*pre-ico start time*/
      1505131200, /*pre-ico end time*/
      75000000 * (10**18), /*pre-ico tokensSupply*/
      45000, /*pre-ico rate*/
      0, /*pre-ico perAddressCap*/
      address(0x2D0a11e28b71788ae72A9beae8FAb937584B05Fd) /*pre-ico wallet*/
    );
  }

  function() payable {
    buy(msg.sender);
  }

  function buy(address buyer) public payable {
    require(!stopped);
    require(buyer != 0x0);
    require(msg.value > 0);
    require(now >= startTime && now <= endTime);

    uint256 tokens = msg.value.mul(rate);
    assert(perAddressCap == 0 || balances[buyer].add(tokens) <= perAddressCap);
    assert(tokensSupply.sub(tokens) >= 0);

    balances[buyer] = balances[buyer].add(tokens);
    balances[owner] = balances[owner].sub(tokens);
    tokensSupply = tokensSupply.sub(tokens);
    tokensSold = tokensSold.add(tokens);

    assert(wallet.send(msg.value));
    Transfer(this, buyer, tokens);
  }

  function startSale(
    uint256 saleStartTime,
    uint256 saleEndTime,
    uint256 saletokensSupply,
    uint256 saleRate,
    uint256 salePerAddressCap,
    address saleWallet
  ) onlyOwner {
    startTime = saleStartTime;
    endTime = saleEndTime;
    tokensSupply = saletokensSupply;
    rate = saleRate;
    perAddressCap = salePerAddressCap;
    wallet = saleWallet;
    stopped = false;
    SaleStart();
  }

  function stopSale() onlyOwner {
    stopped = true;
    SaleStop();
  }

  function transfer(address _to, uint _value) crowdsaleTransferLock returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) crowdsaleTransferLock returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}
