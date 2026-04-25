// SPDX-License-Identifier: Proprietary
pragma solidity ^0.8.200;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// KIBBLE: The utility token (replaces the fake "Bark Yields")
contract KibbleToken is ERC20, Ownable {
    constructor() ERC20("Kibble", "KIB") Ownable(msg.sender) {}

    function mintReward(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

// PUPPY NFT: The collectible (replaces the "Tier" system)
contract PuppyNFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    KibbleToken public immutable rewardToken;
    uint256 public constant MINT_PRICE = 0.01 ether;
    uint256 public constant DAILY_REWARD = 10 * 10**18; // 10 KIB per day

    mapping(uint256 => uint256) public lastClaimed;

    constructor(address _token) ERC721("SafePuppy", "SPUP") Ownable(msg.sender) {
        rewardToken = KibbleToken(_token);
    }

    // Transparent minting logic
    function adoptPuppy() external payable nonReentrant {
        require(msg.value >= MINT_PRICE, "Insufficient ETH sent");
        uint256 tokenId = totalSupply() + 1;
        _safeMint(msg.sender, tokenId);
        lastClaimed[tokenId] = block.timestamp;
    }

    // Safe reward claiming (no "Unlimited Access" required)
    function claimRewards(uint256 tokenId) external nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "Not your puppy");
        
        uint256 timePassed = block.timestamp - lastClaimed[tokenId];
        uint256 reward = (timePassed * DAILY_REWARD) / 1 days;
        
        require(reward > 0, "No rewards accumulated");
        
        lastClaimed[tokenId] = block.timestamp;
        rewardToken.mintReward(msg.sender, reward);
    }

    // Owner cannot steal user funds
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
