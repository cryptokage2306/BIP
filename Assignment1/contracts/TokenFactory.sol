// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './Token.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';

contract TokenFactory is Ownable {
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

    /// @dev Create token
    /// @param _name a parameter is name of the token
    /// @param _symbol a parameter is a symbol of token
    /// @param _cap a parameter is which set cap on total supply of given token
    /// @param _minter a parameter is an address whose balance we need to check
    /// @param _burner a parameter is an address whose balance we need to check
    function createToken(
        string memory _name,
        string memory _symbol,
        uint256 _cap,
        address _minter,
        address _burner
    ) external onlyOwner returns (Token tokenAddress) {
        Token td = new Token(_name, _symbol, _cap, _minter, _burner);
        tokenAddresses.push(td);
        return td;
    }

    function findToken(address _token)
        internal
        view
        returns (Token tokenAddress)
    {
        Token td;
        for (uint256 index = 0; index < tokenAddresses.length; index++) {
            if (address(tokenAddresses[index]) == _token) {
                td = tokenAddresses[index];
            }
        }
        require(address(td) != address(0), 'Token not found');
        return td;
    }

    /// @param _token a parameter is an address to token
    /// @param _owner a parameter is an address whose balance we need to check
    function balanceOf(address _token, address _owner)
        external view
        returns (uint256 balance)
    {
        Token td = findToken(_token);
        return td.balanceOf(_owner);
    }

    /// @dev Pause/unpause the token minting and burning
    /// @param _token a parameter is an address to token
    /// @param _pause a parameter is an boolean value to tell to pause/unpause
    /// @return success boolean value
    function pauseToken(address _token, bool _pause)
        external
        onlyOwner
        returns (bool success)
    {
        Token td = findToken(_token);
        td.handlePause(_pause);
        return true;
    }

    /// @dev gives sum of all the tokens total supply
    function getTotalSupplyOfTokens() external view returns (uint256 totalSupply) {
        uint256 sumOfSupplies = 0;
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            sumOfSupplies += tokenAddresses[i].totalSupply();
        }
        return sumOfSupplies;
    }
}