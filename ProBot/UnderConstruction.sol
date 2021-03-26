pragma solidity ^0.8.3;

contract Order {
    
address payable public seller; 
address payable public buyer; 

uint256 public sum=0;                                  //защита??? - будет ли отображ в боте
uint256 public time;
uint256 public changeTime=0;

bool buyerOK=false;

constructor(address payable _buyer, uint256 stamp) public{ 
        buyer = _buyer; 
        seller = payable(msg.sender);
        time=(block.timestamp + stamp*1 minutes);       //+ 7 days  - потом дни сделать везде 
    } 
    
//////////////Модификаторы//////////////
    modifier onlyBuyer(){ 
        require(msg.sender == buyer);  
        _; 
    } 
  

    modifier onlySeller(){ 
        require(msg.sender == seller); 
        _; 
    } 
    
    modifier onlyBS(){ 
        require((msg.sender == seller)||(msg.sender == buyer)); 
        _; 
    } 
     

//////////////Основные функции//////////////

function setOK(bool bOk) private onlyBuyer {               // для соглашений - переправки селлеру и изменения временной метки
        buyerOK=bOk;
    }
    
function pay_to_Contract() onlyBuyer public payable{ 
        require(msg.value < (msg.sender).balance,
            "Not enough Ether provided."
        ); 
        sum+=msg.value;
    } 
    

function deliver_from_Contract_to_Seller() onlyBS private{   //сделать bool all от покупателя?
          require(sum>0,                                                 // 1=>все, 0=>какие-то% от суммы
            "Not enough Ether provided."
        );
        
        seller.transfer(address(this).balance); 
        
          if (block.timestamp>(time)){
              seller.transfer(address(this).balance); 
              sum=0;
          }
          else if ((buyerOK)==true){
          seller.transfer(address(this).balance); 
          sum=0;
          buyerOK=false;
          }
          else {
          revert("No permission or impossible amount.");
          }
    } 
    

function return_payment() private { 
       require(sum>0,
            "Not enough Ether provided."
        );
          if (msg.sender==seller){
              buyer.transfer(address(this).balance);
              sum=0;
        }
          else if (block.timestamp>(time+30 days)){
              buyer.transfer(address(this).balance);
              sum=0;
          }
    }  
    
//////////////Дополнительные//////////////

function change(uint256 newStamp) private onlyBuyer {               // для изменения переменной
        changeTime=newStamp;
    }   

function changeStamp(uint256 howMuchDaysNeeded) onlySeller private {    //изменение временного штампа - необходимо согласие 2 сторон 
        if ((changeTime==howMuchDaysNeeded)&&(buyerOK==true)&&(changeTime!=0)){
            time+=changeTime*1 minutes;
            changeTime=0;
            buyerOK=false;
        }
    }
    
function kill() onlySeller private {                                            
            if ((address(this).balance)==0){
                selfdestruct(seller);
            }
    }

}
