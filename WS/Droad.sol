pragma solidity ^0.8.11;

/*Характеристики транспортного средства:
Категория (A, B, C);
Рыночная стоимость (Рс, монет);
Срок эксплуатации (Сэ, лет);
Характеристики водителя:
ФИО
Водительское удостоверение со всеми параметрами (номер, срок действия, категория транспортного средства);
Год начала водительского стажа (для определения стажа; например, если стаж начался в 2001 году, то на 2020 год стаж будет равен 19 лет);
Количество ДТП;
Количество неоплаченных штрафов;
Страховой взнос;
Текущий баланс.

 /*Водитель:
+добавляет в своем личном кабинете данные водительского удостоверения: номер, срок действия, категория транспортного средства (все водительские удостоверения в рамках текущего конкурсного задания перечислены в табл. 1);
+запрос на регистрацию транспортного средства;
+ запрос на продление срока действия водительского удостоверения;
+оформление
 и получение страховки;
+оплата штрафа.

Сотрудник ДПС:
подтверждает данные водительского удостоверения (функция может быть реализована автоматически);
+ регистрирует транспортное средство (функция может быть реализована автоматически);
+ продлевает срок прав (функция может быть реализована автоматически);
+ выписывает штраф;
+делает отметку о ДТП.
*/


contract Info {
    mapping(address => Transport) transp;
    struct Transport {
        string category;
        uint256 price;
        uint256 srok;
    }
 
    function getSrok(address person)public view returns(uint) {
        return(transp[person].srok);
    }
}

 /////все что связано со штрафами/////
contract Shtrafi {
    address m;
    address bank;  
    mapping(uint => uint[])shtr;

    event newShtraf(uint indexed number, uint timestamp,uint id);
    event PogashenShtraf(uint indexed number,uint id);

    constructor(address b,address contMain) {
        bank = b;
        m = contMain;
    }
 
    modifier ifDPS(address user) {
    Main cont = Main(m);
        require(cont.DPSRole(user)==true);
       _;
    }

    function addShtrafi(uint256 number) ifDPS(msg.sender) public {          //добавление штрафа
      shtr[number].push(block.timestamp);
      emit newShtraf(number,block.timestamp,shtr[number].length-1);
    }

    function oplShtrafa(uint256 numb, uint256 id) payable public {
        require(msg.value==5 || msg.value==10);
        if (shtr[numb][id] + 5 days <= block.timestamp) {
            require(msg.value==5);
            shtr[numb][id] = 0;
            emit PogashenShtraf (numb,id);
        } else {
            require(msg.value==10,"You should pay ten coins.");
            shtr[numb][id] = 0;
            emit PogashenShtraf (numb,id);
        } 
        payable(bank).transfer(msg.value);
    }
}
 

contract Main is Info {
    address payable bank;
    address payable strahCompany;
    uint debt;
 
    mapping(uint256 => person) per;
    struct person {
        string FIO;
        address user;            //номер для дпс
        uint256 kolDTP;             //количество дтп
        uint256 kolNeOplShtr;
        uint256 srok; 
 
    }
    mapping(address => person2) per2;
    struct person2 {
        uint8 role;                //0-нет в системе,1-дпс,2-водитель, 3-и дпс и водитель
        string categor;
        uint256 vodStaj;             //год начала
        uint256 strahVznos;
    }

    event formStrahovanie(uint256 numberDriver,uint256 amount);
    event viplataStrahovanie(uint256 number,uint256 amount);
 
    constructor(address b,address st) {
        bank = payable(b);
        strahCompany = payable(st);
    }

    modifier onlyDPS(address user) {
        require(per2[msg.sender].role==1||per2[msg.sender].role==3);
        _;
    }
     modifier onlyBank(address user) {
        require(user==bank);
        _;
    }
 
    modifier onlyStrah() {
        require(msg.sender==bank);
        _;
    }

    function addDriver(string memory FIO, uint256 srok,string memory categor, uint256 number,uint32 vodStaj,uint8 role) public { //добавление водителя 
        if (per2[msg.sender].role == 0) {
            per[number]=person(FIO,msg.sender,0,0,srok);
            per2[msg.sender]=person2(role,categor,vodStaj,0);
        }
    }
 
    function formStrah(uint256 number) public {                 //формирование страховки  
        per2[msg.sender].strahVznos=uint256(abs(int(abs(1-int(getSrok(msg.sender)/10))*int(1)/10))+int(per[number].kolNeOplShtr)*int(2)/10+int(per[number].kolDTP)-int(per2[msg.sender].vodStaj)*int(5)/100);
        emit formStrahovanie(number,per2[msg.sender].strahVznos);
    }
 
    function payToStrahCompany() external payable {       
        require(msg.value == uint256(per2[msg.sender].strahVznos),
            "Not enough money for paying the fine or an uppropriate value"
        );           
        if(debt>0&&debt>msg.value) {
            debt-=msg.value;
            bank.transfer(msg.value); 
        } else if(debt > 0) {
            debt=0;
            bank.transfer(debt);
            strahCompany.transfer(msg.value-debt); 
        } else {
            strahCompany.transfer(msg.value); 
        }
    }
 
    function payToBank() external onlyStrah() payable {
        debt -= msg.value;          
        bank.transfer(msg.value);  
    }
 
    // сделать бы на страх компанию задолженность, чтобы потом выплатили (и отметка о дтп тож сделана)
    function oformDTP(uint256 number) public onlyDPS(msg.sender) {       //оформл дтп=>выплата страховки
        per[number].kolDTP += 1;
        address user = per[number].user;
        uint256 amount = uint256(per2[user].strahVznos)*10;

        if(strahCompany.balance < amount) {
            revert("Not enough money to form DTP");
        } else {
            payable(user).transfer(amount);
            emit viplataStrahovanie(number,amount);
        }
    }
 
    function addTranspDPS(uint256 id, string memory category, uint256 price, uint256 srok) onlyDPS(msg.sender) public {          //добавление транспорта
        require(((keccak256(abi.encodePacked(per2[msg.sender].categor))) == keccak256(abi.encodePacked(category))));
        address user = per[id].user;
        transp[user]=Transport(category,price,srok);
    } 
 
    function registerTransp(string memory cat, uint256 price, uint256 srok) public {          //регистрация водителем
        require(((keccak256(abi.encodePacked(per2[msg.sender].categor))) == keccak256(abi.encodePacked(cat))));
        transp[msg.sender] = Transport(cat,price,srok);
    }
 
    function prodlevSrokVodYdost(uint number,uint howMuch) public {                //продление срока удостоверения
        if(per[number].kolNeOplShtr == 0 && 
            (block.timestamp + 31 days <= per[number].srok)) {
           per[number].srok= howMuch *1 days;  
        } else {
            revert("extension denied");
        }
    }
 
    function toStrahFromBank() onlyBank(msg.sender)external payable {
        debt += msg.value;
        payable(strahCompany).transfer(msg.value);
    }
 
    function DPSRole(address user) public view returns(bool) {          
        if(per2[user].role==1 || per2[user].role==3)
            return true;
        else 
            return false;
    }
 
//////////////////getters///////////////////////////
     function getBANK()public view returns(uint) {
         return bank.balance;
     }
 
     function getStSum()public view returns(uint) {
         return (uint(per2[msg.sender].strahVznos));
     }
  
     function getSTRAH()public view returns(uint) {
         return strahCompany.balance;
}
//////////////////////////////////////////////////////////
 
     function abs(int x) private pure returns(int) {
        if(x >= 0)
            return x;
        else
            return(-x);
    }
}
