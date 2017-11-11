pragma solidity ^0.4.11;

import "./StandardToken.sol";
import "./Owner.sol";



/**
 * @title Grydl Analytics CrowndSale
 * @author Charles Azanlekor <c.azanlekor@grydl.com>
 * @dev ERC20 Token for GrydlCrownSale, with token creation
 */
contract GrydlCrownSale is StandardToken , Owner  {


      //The name of the token
  string public constant name = "GrydlCrownSale";

  //Symbol of the Token
  string public constant symbol = "GRDL";

  //Amount of decimal for display purposes
  // @TODO Remember to change this value
  uint public constant decimals = 18;

  //Version of the Token
  string public constant version = "1.0";


  // 1 ether = 500 GRDL tokens
  //#######  remember to initialize the price of the Token
  uint internal price = 500;


   mapping (address => uint256) internal depositBalanceOf;
   mapping (address => uint256) internal withdrawBalanceOf;
   mapping (address => uint256) internal withdrawRequestBalanceOf;


  //This is the value of max token in Grydl Token
  //Remember to change this value for you Market Cap
  // @TODO
  uint256 public constant tokenCap =  20 * (10**6) * 10**decimals;
 
  /**
   * @dev Fallback function which receives ether and put the appropriate Ether in the Grydl Bank
   * 
   */
  function () payable {
    depositFund();
  }


   /**
   * @dev this function allow user to deposit their Ether Grydl Crowdsale
   *
   */
   function depositFund() payable {
       require (msg.value > 0) ;
       require (totalSupply < tokenCap);
       depositBalanceOf[msg.sender] = depositBalanceOf[msg.sender].add(msg.value);
       createTokens(msg.sender);
       DepositeDone(msg.sender, msg.value);
   }


  /**
   * @dev Creates tokens and send to the specified address.
   * This function transfer fund to the owner of this Smart Contract
   * @param _user address which will recieve the new tokens.
    */
  function createTokens(address _user) {
    uint256 amount = depositBalanceOf[_user];      
    uint tokens = amount.mul(getPrice());
    totalSupply = totalSupply.add(tokens);
    balances[_user] = balances[_user].add(tokens);
    depositBalanceOf[_user] = 0 ;
    TokenCreated(_user, amount);
  }

  /**
   * @dev this function allow user to ask for withdraw, User Want to sell his token and get Ether from Grydl Crowdsale
   * The user won't receive his Ether directly , the Grydl  have to valide the Withdraw before
   * @param _amount The amount of SBCI the user want to withdraw
   */
   function withdrawRequest(uint256 _amount) {
       require (_amount > 0);       
       withdrawRequestBalanceOf[msg.sender] = withdrawRequestBalanceOf[msg.sender].add(_amount);
       if(balances[msg.sender] < withdrawRequestBalanceOf[msg.sender]) throw;
       WithdrawRequest(msg.sender,_amount);
   }


   /**
   * @dev this function allow Grydl  Owner to withdraw Ether from Grydl Crowdsale
   * @param _amount the Owner withdraw from the Grydl Crowdsale
   */
   function withdrawFund(uint256 _amount) onlyOwner() {
       require(_amount > 0);
       if(!owner.send(_amount))  throw;
       OwnerWithdraw(msg.sender, _amount);
   }


   /**
   * @dev this function allow Grydl  Owner to send Ether to Grydl Crowdsale
   * 
   */
   function allocateFund() onlyOwner() payable {
       require(msg.value > 0);
       OwnerDeposited(msg.sender, msg.value);
   }


    /**
   * @dev destroy tokens and send corresponding Eth to the specified address.
   * @param _recipient The address which will recieve the Eth
   */
  function validateWithdraw(address _recipient)  onlyOwner() {

    uint256 tokens = withdrawRequestBalanceOf[_recipient];
    require(tokens > 0);
    uint256 amount = tokens.div(getPrice());
    totalSupply = totalSupply.sub(tokens);

    balances[_recipient] = balances[_recipient].sub(tokens);
    withdrawRequestBalanceOf[_recipient] = 0;

     if (!_recipient.send(amount)) throw;
      WithdrawDone(msg.sender,amount);
  }


  /**
   * @dev replace this with any other price function
   * @return The price per unit of token. 
   */
  function getPrice() constant returns (uint result) {
    return price;
  }

 /**
  * @dev change the value by sending transsaction to contract
  * @param _price new price of the NAV , only the Grydl  owner can change the NAV price
  */
  function setPrice(uint _price) onlyOwner() {
      require(_price > 0);
      price = _price;
    }

    event DepositeDone(address indexed by, uint256 amount); //When a user deposit Ether on Grydl Crowdsale
    event TokenCreated(address indexed by, uint256 amount); //When a user get his SBCI token
    event WithdrawRequest(address indexed by, uint256 amount); // When a user ask for a withdraw of his Ether
    event WithdrawDone(address indexed by, uint256 amount); // When a user get back his Ether and sell his SBCI Token to Grydl Crowdsale


    event OwnerDeposited(address indexed by, uint256 amount); //When a Grydl  Owner deposit Ether on Grydl Crowdsale
    event OwnerWithdraw(address indexed by, uint256 amount); // When a Grydl  Ownerwithdown Ether from the contrcat

}