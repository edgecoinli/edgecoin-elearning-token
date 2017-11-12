pragma solidity ^0.4.17;
//version 1.3

import "browser/SafeMath.sol";
import "browser/DateTime.sol";

contract ERC20 {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint);
    function transfer(address _to, uint _value) public returns (bool);
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function approve(address _spender, uint _value) public returns (bool);
    function allowance(address _owner, address _spender) public constant returns (uint);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
} 
 

contract EdgeSmartToken is ERC20, SafeMath, DateTime {

    uint256 public constant _totalSupply = 100000000;
    uint8  public constant _decimals = 18;
    string public constant symbol = 'EST';
    string public constant name = 'Edge Smart Token';
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) approved;
    address EdgeSmartTokenOwner;

    modifier onlyOwner() {
        require(msg.sender == EdgeSmartTokenOwner);
        _;
    }    
   
    
    function EdgeSmartToken() public {
        EdgeSmartTokenOwner = msg.sender;
        balances[EdgeSmartTokenOwner] = _totalSupply;
    }

   
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != EdgeSmartTokenOwner);      
        EdgeSmartTokenOwner = newOwner;
    }    
    

    function decimals() public constant returns (uint8) {
        return _decimals;
    }

    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public constant returns (uint256) {
        return balances[_owner];
    }

    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(
            balances[msg.sender] >= _value && _value > 0
        );
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Transfer with approvement mechainsm
     * @param _from source address, `_value` tokens shold be approved for `sender`
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice from `_from` will be sended `_value` tokens to `_to`
     * @return `true` when transfer is done
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(
            approved[_from][msg.sender] >= _value && balances[_from] >= _value && _value > 0
        );
        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        approved[_from][msg.sender] = safeSub(approved[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _spender target address (future requester)
     * @param _value amount of token values for approving
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        approved[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @dev Reset count of tokens approved for given address
     * @param _spender target address (future requester)
     */
    function unapprove(address _spender) public { 
        approved[msg.sender][_spender] = 0; 
    }

    /**
     * @dev Take allowed tokens
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return approved[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
