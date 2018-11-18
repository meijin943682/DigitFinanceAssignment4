pragma solidity ^0.5.0;

contract Bank {
  // 此合約的擁有者
  address payable private owner;

  // 儲存所有會員的餘額
  mapping (address => uint256) private balance;
  mapping (address => uint256) private CD;
  mapping (address => uint256) private periods;
  mapping (address => uint256) private interest;

  // 事件們，用於通知前端 web3.js
  event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
  event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
  event TransferEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);
  event CertiDepositEvent(address indexed from, uint256 value, uint256 timestamp);
  event CertiDepositPaybackEvent(address indexed from, uint256 value, uint256 timestamp);

  modifier isOwner() {
    require(owner == msg.sender, "you are not owner");
    _;
  }

  // 建構子
  constructor() public payable {
    owner = msg.sender;
  }

  // 存錢
  function deposit() public payable {
    balance[msg.sender] += msg.value;

    emit DepositEvent(msg.sender, msg.value, now);
  }

  // 提錢
  function withdraw(uint256 etherValue) public {
    uint256 weiValue = etherValue * 1 ether;

    require(balance[msg.sender] >= weiValue, "your balances are not enough");

    msg.sender.transfer(weiValue);

    balance[msg.sender] -= weiValue;

    emit WithdrawEvent(msg.sender, etherValue, now);
  }

  // 轉帳
  function transfer(address to, uint256 etherValue) public {
    uint256 weiValue = etherValue * 1 ether;

    require(balance[msg.sender] >= weiValue, "your balances are not enough");

    balance[msg.sender] -= weiValue;
    balance[to] += weiValue;

    emit TransferEvent(msg.sender, to, etherValue, now);
  }

  // 檢查銀行帳戶餘額
  function getBankBalance() public view returns (uint256) {
    return balance[msg.sender];
  }

  // 檢查定存金額
  function getCDBalance() public view returns (uint256){
    return CD[msg.sender];
  }

  // 檢查定存利潤金額
  function getInterestBalance() public view returns (uint256){
    return interest[msg.sender];
  }

  // 定存
  function certiDeposit(uint256 period) public payable{
    require(CD[msg.sender] == 0, "you can only make a certificate deposit.");
    require(period >= 0 && period <= 12, "the period can only between 0 and 12");
    CD[msg.sender] = msg.value;
    periods[msg.sender] = period;
    emit CertiDepositEvent(msg.sender, msg.value,now);
  }

  // 定存到期
  function certiDepositPayback(bool isExpired, uint256 months) public{
    require(months >= 0 && months < periods[msg.sender], "the number of periods can't exceed contract's.");
    msg.sender.transfer(CD[msg.sender]);
    interest[msg.sender] += (isExpired? CD[msg.sender] * periods[msg.sender] : CD[msg.sender] * months) / 100;
    emit CertiDepositPaybackEvent(msg.sender, CD[msg.sender], now);
    CD[msg.sender] = 0;
  }

  function kill() public isOwner {
    selfdestruct(owner);
  }
}
