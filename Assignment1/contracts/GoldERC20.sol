// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract GoldERC20 {
    uint256 public totalSupply;
    string public name = "GOLD";
    string public symbol = "GLD20";
    uint8 public decimals = 8;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(uint256 _initial_supply) {
        totalSupply = _initial_supply;
        balanceOf[msg.sender] = _initial_supply;
    }

    function transfer(address _to, uint256 amount) external returns (bool) {
        require(amount <= balanceOf[msg.sender]);
        balanceOf[msg.sender] -= amount;
        balanceOf[_to] += amount;

        emit Transfer(msg.sender, _to, amount);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowances[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}
