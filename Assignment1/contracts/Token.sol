// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/extensions/ERC20Pausable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/extensions/ERC20Capped.sol';
import 'openzeppelin-solidity/contracts/access/AccessControl.sol';

contract Token is ERC20, Ownable, ERC20Pausable, ERC20Capped, AccessControl {
    /// @dev Byte32 object to store MINTER_ROLE keccak256
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    /// @dev Byte32 object to store BURNER_ROLE keccak256
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /// @param _name a parameter is name of the token
    /// @param _symbol a parameter is a symbol of token
    /// @param _cap a parameter is which set cap on total supply of given token
    /// @param _minter is an minter address
    /// @param _burner is an burner address
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _cap,
        address _minter,
        address _burner
    ) ERC20(_name, _symbol) ERC20Capped(_cap) {
        _setupRole(MINTER_ROLE, _minter);
        _setupRole(BURNER_ROLE, _burner);
    }
    /// @dev Modifier to check msg.sender is burner or not
    modifier onlyBurner() {
        require(hasRole(BURNER_ROLE, msg.sender), 'Sender is not the Burner of token');
        _;
    }
    /// @dev Modifier to check msg.sender is minter or not
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), 'Sender is not the Minter of token');
        _;
    }

    /// @dev To pause any token minting and burning
    /// @param pause_ to determine whether pause/unpause
    /// @return success
    function handlePause(bool pause_) external onlyOwner returns (bool success) {
        if (pause_) {
            _pause();
        } else {
            _unpause();
        }
        return true;
    }

    /// @param recipient is recipient address
    /// @param amount to amount to mint
    function mintCoins(address recipient, uint256 amount) external onlyMinter {
        _mint(recipient, amount);
    }

    /// @param recipient is recipient address
    /// @param amount to amount to burn
    function burnCoins(address recipient, uint256 amount) external onlyBurner {
        _burn(recipient, amount);
    }
    /// @dev Used to check ERC20Pausable condition before transfer
    /// @param from sender address
    /// @param to receiver address
    /// @param amount amount to transfer
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable) {
        ERC20Pausable._beforeTokenTransfer(from, to, amount);
    }
    /// @dev Used to check ERC20Capped minter condition before minting
    /// @param to receiver address
    /// @param amount amount to transfer
    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Capped) {
        ERC20Capped._mint(to, amount);
    }
}