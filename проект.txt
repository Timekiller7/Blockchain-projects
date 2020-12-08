
pragma solidity 0.6.0;      
   

contract escrow{ 
  

    address payable public buyer; 
    address payable public seller; 
    address payable public arbiter; 
    mapping(address => uint) TotalAmount; 
  
 
    enum State{                                                //стадии
         
  
        awate_payment, awate_delivery, complete                   
    } 
  
  
    State public state; 
      
      
    modifier instate(State expected_state){ 
          
        require(state == expected_state); 
        _; 
    } 
  

    modifier onlyBuyer(){ 
        require(msg.sender == buyer ||  
                msg.sender == arbiter); 
        _; 
    } 
  

    modifier onlySeller(){ 
        require(msg.sender == seller); 
        _; 
    } 
      
 
    constructor(address payable _buyer,  
                address payable _sender) public{                      //конструктор
        
        // Assigning the values of the  
        // state variables 
        arbiter = msg.sender; 
        buyer = _buyer; 
        seller = _sender; 
        state = State.awate_payment; 
    } 
      

    function confirm_payment() onlyBuyer instate(         //самая первая транзакция покупателем
      State.awate_payment) public payable{ 
      
        state = State.awate_delivery; 
          
    } 
    
     function confirm_payment_many() onlyBuyer instate(           //все последующие,чтобы новый контракт не делать и избежать дабл траты
      State.complete) public payable{  
      
        state = State.awate_delivery; 
          
    } 
    
      

    function confirm_Delivery() onlyBuyer instate( 
      State.awate_delivery) public{ 
          
        seller.transfer(address(this).balance); 
        state = State.complete; 
    } 
  

    function ReturnPayment() onlySeller instate( 
      State.awate_delivery)public{ 
        
         
       buyer.transfer(address(this).balance); 
    } 
      
} 
