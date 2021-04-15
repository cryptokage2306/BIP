// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Token.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract TokenFactory is Ownable {
    struct TokenData {
        address minter;
        address burner;
    }

    mapping(address => TokenData) tokenMapping;

    Token[] public tokenAddresses;

    event Transfer(
        address indexed _token,
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    modifier isTokenPresent(address _token) {
        require(
            tokenMapping[_token].minter != address(0),
            "not a valid token address"
        );
        require(
            tokenMapping[_token].burner != address(0),
            "not a valid token address"
        );
        _;
    }

    function createToken(
        string memory _name,
        string memory _symbol,
        uint256 _cap,
        address _minter,
        address _burner
        ) external onlyOwner returns (Token tokenAddress) {
        Token td = new Token(_name, _symbol, _cap, _minter, _burner);
        address tokenAddress = address(td);
        tokenAddresses.push(td);
        tokenMapping[tokenAddress].minter = _minter;
        tokenMapping[tokenAddress].burner = _burner;
        return td;
    }

    function balanceOf(address _token, address _owner)
        external
        isTokenPresent(_token)
        returns (uint256 balance)
    {
        (bool success, bytes memory result) =
            _token.call(
                abi.encodeWithSignature("balanceOf(address)", _owner)
            );
        require(success, "operation is not successfull due to some error");
        return abi.decode(result, (uint256));
    }

    function pauseToken(address _token, bool _pause)
        external
        onlyOwner
        isTokenPresent(_token)
        returns (bool success)
    {
        (bool success, ) =
            _token.call(
                abi.encodeWithSignature(
                    "handlePause(bool)",
                    _pause
                )
            );
        require(success, "operation is not successfull due to some error");
        return false;
    }

    function mintCoins(
        address _token,
        address _to,
        uint256 _value
    ) external isTokenPresent(_token) returns (bool success) {
        require(
            msg.sender == tokenMapping[_token].minter,
            "Sending address is not a minter"
        );
        (bool success, ) =
            _token.call(
                abi.encodeWithSignature(
                    "mintCoinsTokenFactory(address,uint256)",
                    _to,
                    _value
                )
            );
        require(success, "operation is not successfull due to some error");
        emit Transfer(_token, msg.sender, _to, _value);
        return true;
    }

    function burnCoins(
        address _token,
        address _to,
        uint256 _value
    ) external isTokenPresent(_token) returns (bool success) {
        require(
            msg.sender == tokenMapping[_token].burner,
            "Sending address is not a burner"
        );
        (bool success, ) =
            _token.call(
                abi.encodeWithSignature(
                    "burnCoinsTokenFactory(address,uint256)",
                    _to,
                    _value
                )
            );
        require(success, "operation is not successfull due to some error");
        emit Transfer(_token, msg.sender, _to, _value);
        return true;
    }

    function getTotalSupplyOfTokens()
        public returns (uint256 totalSupply)
    {
        uint256 sumOfSupplies = 0;
        for(uint256 i = 0; i< tokenAddresses.length; i++ ) {
            sumOfSupplies += tokenAddresses[i].totalSupply();
        }
        return sumOfSupplies;
    }
}
