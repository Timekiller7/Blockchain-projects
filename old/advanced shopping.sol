pragma solidity 0.5.1;

contract Computer_Shop {
    
uint256 startTime=1605225600;                                //начало работы с 1 структурой
    
    modifier plsOpenOnlyWhen(){                          //модификатор - временная метка
        require(block.timestamp>=startTime);
        _;
    }

    New_Computer[] public new_c;               //1 структура

    struct New_Computer {
    string operatingSystem;
    string version;
    int releaseDate;
    }


    function addComputer (string memory operatingSystem, string memory version, int releaseDate) public plsOpenOnlyWhen{
        new_c.push(New_Computer(operatingSystem, version,releaseDate));
        }

mapping (uint=>Trade) public trade;                                //начало работы с 2 структурой

    uint256 public trades=0;                                    //сколько покупок было совершено

    struct Trade {                                              //2 структура
    int nubmerOfComputer;
    int moneyFromTrade;
    bool computerIsNew;
    }

   function addTrade (int nubmerOfComputer,int moneyFromTrade,bool computerIsNew) public {
    trade[trades]=Trade(nubmerOfComputer, moneyFromTrade,computerIsNew);
    trades+=1;    
    }

uint256 public vacancyNeeded=0;                                 //начало работы с 3 структурой; количество открытых вакансий
    mapping(uint=>Vacancy) public vacancy;
    address owner;                                          
    modifier onlyOwner(){                                       // модификатор - только владелец может проводить транзакцию
    require (msg.sender==owner);
    _;
    }

    struct Vacancy{                                             //3 структура
    string whatJob;
    int requiredExperience;
    bool urgently;
    }

    constructor() public {                     //по умолчанию устанавливается адрес владельца
    owner=msg.sender;
    }

    function addVacancy(string memory whatJob, int requiredExperience,uint8 _employeesNow) public onlyOwner {
    bool _urgently;                  //локал переменная,срочно ли требуется человек на новую вакансию
    if (_employeesNow<25){ 
         _urgently=true;
    }   
    else _urgently=false;
    
    vacancy[vacancyNeeded]=Vacancy(whatJob, requiredExperience, _urgently);
    vacancyNeeded+=1;
    }

}    
    
    
