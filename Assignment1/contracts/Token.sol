// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/extensions/ERC20Pausable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/extensions/ERC20Capped.sol';
import 'openzeppelin-solidity/contracts/access/AccessControl.sol';

contract Token is ERC20, Ownable, ERC20Pausable, ERC20Capped, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

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

    modifier onlyBurner() {
        require(hasRole(BURNER_ROLE, msg.sender), 'Sender is not the Burner of token');
        _;
    }

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), 'Sender is not the Minter of token');
        _;
    }

    function handlePause(bool pause_) external returns (bool success) {
        if (pause_) {
            _pause();
        } else {
            _unpause();
        }
        return true;
    }

    function mintCoinsTokenFactory(address recipient, uint256 amount) public {
        _mint(recipient, amount);
    }

    function burnCoinsTokenFactory(address recipient, uint256 amount) public {
        _burn(recipient, amount);
    }
    
    function mintCoins(address recipient, uint256 amount) external onlyMinter {
        mintCoinsTokenFactory(recipient, amount);
    }

    function burnCoins(address recipient, uint256 amount) external onlyBurner {
        burnCoinsTokenFactory(recipient, amount);
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable) {
        ERC20Pausable._beforeTokenTransfer(from, to, amount);
    }
    
    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Capped) {
        ERC20Capped._mint(to, amount);
    }
}