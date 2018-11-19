// 新增定存欄位
mapping (address => uint256) private CD;
// 新增期數欄位
mapping (address => uint256) private periods;
// 新增利息欄位
mapping (address => uint256) private interest;

// 新增定存事件通知web3.js
event CertiDepositEvent(address indexed from, uint256 value, uint256 timestamp);
// 新增提出事件通知web3.js
event CertiDepositPaybackEvent(address indexed from, uint256 value, uint256 timestamp);

// 檢查定存金額，傳回定存金額
function getCDBalance() public view returns (uint256){
  return CD[msg.sender];
}

// 檢查定存利潤金額，傳回利息金額
function getInterestBalance() public view returns (uint256){
  return interest[msg.sender];
}

// 定存功能，把定存金額及利息期數寫入
function certiDeposit(uint256 period) public payable{
  // require為防呆
  require(CD[msg.sender] == 0, "you can only make a certificate deposit.");
  require(period >= 0 && period <= 12, "the period can only between 0 and 12");
  // 定存金額
  CD[msg.sender] = msg.value;
  // 利息期數
  periods[msg.sender] = period;
  // 通知前端web3.js去顯示執行結果(emit為通知web3.js有事件發生)
  emit CertiDepositEvent(msg.sender, msg.value,now);
}

// 定存到期領回
function certiDepositPayback(bool isExpired, uint256 months) public{
  // require為防呆
  require(months >= 0 && months < periods[msg.sender], "the number of periods can't exceed contract's.");
  // 把錢轉回自己帳戶
  msg.sender.transfer(CD[msg.sender]);
  // 判斷利息能拿多少%，冒號前(if)是到期所以拿回全部，冒號後(else)是提前解約所以拿回看持有了幾期
  interest[msg.sender] += (isExpired? CD[msg.sender] * periods[msg.sender] : CD[msg.sender] * months) / 100;
  // 通知前端web3.js去顯示執行結果(emit為通知web3.js有事件發生)
  emit CertiDepositPaybackEvent(msg.sender, CD[msg.sender], now);
  // 因未提出錢所以定存(銀行那邊)餘額為0
  CD[msg.sender] = 0;
}