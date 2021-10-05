pragma solidity 0.8.7;      


contract Escrow { 
    address payable public buyer; 
    address payable public seller; 
    address public arbiter; 
    mapping(address => uint) TotalAmount; 
    State public state; 
 
    enum State { awate_payment, awate_delivery, complete }                                                
      
    modifier instate(State expected_state) { 
        require(state == expected_state); 
        _; 
    } 

    modifier instate2(State expected_state) { 
        require(state == expected_state || state == State.complete); 
        _; 
    } 

    modifier onlyBuyer() { 
        require(msg.sender == buyer || msg.sender == arbiter);  
        _; 
    } 
  
    modifier onlySeller() { 
        require(msg.sender == seller); 
        _; 
    } 
      
    constructor(address payable _buyer, address payable _sender) {                  
        arbiter = msg.sender; 
        buyer = _buyer; 
        seller = _sender; 
        state = State.awate_payment; 
    } 
 
    function pay() onlyBuyer instate2(State.awate_payment) public payable {         
        state = State.awate_delivery; 
    } 

    function deliverToSeller() onlyBuyer instate(State.awate_delivery) public { 
        seller.transfer(address(this).balance); 
        state = State.complete; 
    } 
  
    function returnPayment() onlySeller instate(State.awate_delivery) public {  
       buyer.transfer(address(this).balance); 
    }    
} 
