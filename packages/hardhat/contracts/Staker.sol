pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  uint256 public constant threshold = 1 ether;
  uint256 public deadline = now + 30 seconds;
  

  mapping (address => uint256 ) public balances;

  event Stake(address accountAddress, uint256 amount);
  event Withdraw(address accountAddress, uint256 amount);

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    bool openForWithdraw = false;
  }



  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


    function stake() public payable returns (uint) {
      balances[msg.sender] += msg.value;
      
      emit Stake(msg.sender, msg.value);

      return balances[msg.sender];
    }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

    function execute() public {
      require(now >= deadline, "fail");
      require(address(this).balance >= threshold, "not enough staked");
      exampleExternalContract.complete{value: address(this).balance}();

    }
    
    function withdraw() public payable  {
      require(now <= deadline, "oh its too much late for that");
      (bool success, ) = msg.sender.call{value: address(this).balance}("");
      require( success, "FAILED");
      emit Withdraw(msg.sender, balances[msg.sender]);
      balances[msg.sender] = 0;
      
    }
  // if the `threshold` was not met, allow everyone to call a `withdraw()` function



  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256) {
    // check if now got a bigger timestamp than the deadline, if yes then 0 timeleft,if not return the remaining time.
    return now > deadline ? 0 : deadline - now;
  }
}
