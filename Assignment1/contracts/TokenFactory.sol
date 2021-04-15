// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Token.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract TokenFactory is Ownable {
    /// @dev struct to store minter and burner details
    struct TokenData {
        address minter;
        address burner;
    }
    /// @dev Store minter and burner details of token
    mapping(address => TokenData) tokenMapping;
    /// @dev Store all the tokens address
    /// @return address of tokens
    Token[] public tokenAddresses;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _token a parameter is an address to token
    /// @param _from sender address
    /// @param _to receiver address
    /// @param _value amount sent
    event Transfer(
        address indexed _token,
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    /// @dev Check whether token is present or not
    /// @param _token a parameter just like in doxygen (must be followed by parameter name)
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

    /// @dev Create token
    /// @param _name a parameter is name of the token
    /// @param _symbol a parameter is a symbol of token
    /// @param _cap a parameter is which set cap on total supply of given token
    /// @param _minter a parameter is an address whose balance we need to check
    /// @param _burner a parameter is an address whose balance we need to check
    /// @return Token objects
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

    /// @dev provides balance of token related to desired token
    /// @param _token a parameter is an address to token
    /// @param _owner a parameter is an address whose balance we need to check
    /// @return uint balance of address wrt token
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

    /// @dev Pause/unpause the token minting and burning
    /// @param _token a parameter is an address to token
    /// @param _pause a parameter is an boolean value to tell to pause/unpause
    /// @return success boolean value
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

    /// @dev Mint `amount` tokens from the given address.
    /// @param _token a parameter is an address to token
    /// @param _to a parameter is an address to which we will mint tokens
    /// @param _value a parameter amount of token minted
    /// @return success boolean value
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

    /// @dev Destroys `amount` tokens from the given address.
    /// @param _token a parameter is an address to token
    /// @param _to a parameter is an address from which we will burn tokens
    /// @param _value a parameter amount of token burn
    /// @return success boolean value
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

    /// @dev gives sum of all the tokens total supply
    /// @return uint totalSupply
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
