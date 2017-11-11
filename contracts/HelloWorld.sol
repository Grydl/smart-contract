pragma solidity ^0.4.0;

contract HelloWorld {

    uint public numero;

    function set (uint valeur) public {
        numero = valeur;
    }

    function get() public constant returns (uint) {
        return numero;        
    }

    function setInf(uint valeur) public {
        while (true){numero = valeur;}
    }
    
}