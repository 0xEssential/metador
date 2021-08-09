// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

/**
 * @title Metador
 * @notice This is a reference implementation for revealing metadata.

           ████                                                  ████
          ██▓▓██                                                ██░░██
████      ██▓▓▒▒██              ██████                          ██░░██
██░░██    ██▓▓▓▓▓▓██▓▓      ░░▓▓▒▒▓▓▓▓██                        ██░░██
██░░██      ██▓▓▓▓██▒▒██████▒▒▒▒▓▓▓▓▓▓▓▓██████████              ██░░██
██░░██        ████  ██▒▒▒▒▒▒██▓▓  ██████▒▒▒▒▒▒▒▒▒▒████          ██░░░░██
██░░██                ██████  ████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██        ██░░░░██
██░░██                      ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██      ██░░▒▒██
██░░██                    ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓██  ██░░░░▒▒██
██░░░░██                ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓██  ██░░▒▒▒▒██
██░░░░██              ██▒▒████▓▓████████▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓██░░░░▒▒██
██▒▒░░░░██            ████▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████▓▓▓▓▓▓▓▓▓▓████░░▒▒░░▒▒██
██▒▒▒▒░░░░██▓▓      ██▒▒▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓██████████░░░░░░▒▒▒▒██
  ██▒▒░░░░░░░░████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▒▒░░░░░░░░▒▒▒▒██
  ██▒▒▒▒░░▒▒░░░░░░▒▒██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▒▒░░▒▒░░▒▒▒▒██▓▓▓▓
    ██▒▒▒▒▒▒▒▒░░▒▒██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▒▒░░▒▒▒▒████▓▓▓▓██
      ██▓▓▓▓▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓██▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓██
        ██▓▓████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓████▓▓▓▓▓▓▓▓▓▓██▓▓██
        ██▓▓▓▓▓▓▓▓██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▓▓▓▓▓▓
          ██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████▓▓▓▓██████▓▓▓▓██▓▓▓▓▓▓██
            ██▒▒▒▒██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██░░██▓▓██▓▓▓▓████▓▓▓▓▓▓▓▓▓▓██
          ██▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▓▓██▓▓██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██
          ██▒▒▒▒██  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▒▒▒▒██░░██▓▓██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
        ██▒▒▒▒██      ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▒▒▒▒████▓▓▓▓██▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▓▓▓▓██
        ██▒▒▒▒▓▓      ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▒▒██▓▓▓▓▓▓██▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▓▓██
      ██▒▒██▓▓██      ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▓▓▓▓▓▓▓▓██▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓
      ████░░░░░░██    ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓
      ██░░░░██░░██    ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓██      ████▒▒▒▒▒▒▒▒▒▒▓▓▓▓
        ██▓▓██▓▓██    ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓██░░          ██▒▒▒▒▒▒▒▒▒▒██
                      ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓██              ██▒▒▒▒▒▒▒▒▓▓██
                    ██▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▓▓▓▓██                  ██▒▒▒▒▒▒▒▒██
                  ██▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓██                      ██▒▒▒▒▒▒▓▓▓▓
                  ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██                      ██▒▒▒▒▒▒▒▒██
                  ██▓▓██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▓▓▓▓██                          ██▒▒▒▒▒▒▓▓██
                  ██▓▓▓▓██▓▓▓▓▓▓▓▓▓▓████▓▓▓▓▓▓██                          ██▒▒▒▒▒▒▓▓██
                  ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██                            ██▒▒▒▒▒▒▓▓▓▓
                    ██▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓▓▓▓▓██                              ██▒▒▒▒▒▒▓▓▓▓██
                    ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██                                ██▒▒▒▒▒▒▓▓▓▓▓▓
                      ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▓▓██                              ██▒▒▒▒▒▒████████
                        ████▓▓▓▓▓▓▓▓▓▓▓▓██▓▓▓▓██▓▓                            ██▒▒████░░▒▒░░░░▓▓
                            ████████████▓▓████▒▒░░██                            ██░░░░░░██▒▒▒▒██
                                    ██▓▓██░░░░▒▒▒▒░░██                          ██▒▒▒▒▒▒▒▒██▒▒██
                                    ████░░░░▒▒██▒▒▒▒██                            ████████████
                                      ██▒▒▒▒▒▒██████                                    ░░
                                        ████████

  ░░░░                                                        ░░
  ░░░░░░░░░░░░░░░░░░░░
 */

contract Metador is ERC721PresetMinterPauserAutoId, Ownable, VRFConsumerBase {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    event RequestedRandomness(bytes32 requestId);

    uint256 public constant MAX_TOKENS = 10_000;
    uint256 public mintPrice = 0.02 ether;
    uint256 public metadataIndexOffset;
    bytes32 internal keyHash;
    uint256 internal fee;
    bytes32 internal randomnessRequestId;
    uint256 public revealBlock;

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _keyHash,
        string memory name,
        string memory symbol,
        string memory ipfsHash
    )
        VRFConsumerBase(_vrfCoordinator, _linkToken)
        ERC721PresetMinterPauserAutoId(name, symbol, string(abi.encodePacked("ipfs://", ipfsHash, "/")))
    {
        keyHash = _keyHash;
        fee = 2 * 10**18; // 2 LINK (Varies by network)
        revealBlock = block.number; // In production set this in the future
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        if (metadataIndexOffset == 0) {
            return string(abi.encodePacked(_baseURI(), "placeholder"));
        }
        uint256 rawIndex = tokenId + metadataIndexOffset;
        if (rawIndex > MAX_TOKENS) {
            rawIndex = rawIndex - MAX_TOKENS;
        }
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(rawIndex))) : "";
    }

    function revealMetadata() public {
        require(block.number >= revealBlock, "Not ready for reveal");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        require(randomnessRequestId == "", "Already requested");
        randomnessRequestId = requestRandomness(keyHash, fee);
        emit RequestedRandomness(randomnessRequestId);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        require(requestId == randomnessRequestId, "Bad Request");
        metadataIndexOffset = randomness % MAX_TOKENS;
        if (metadataIndexOffset == 0) {
            // in the 1 per MAX_TOKENS chance that we get a 0 modulus,
            // we assign the index offset to 1
            metadataIndexOffset = 1;
        }
    }

    receive() external payable {} // solhint-disable-line no-empty-blocks

    /**
     * @notice Public mint function
     */
    function publicMint() public payable {
        require(msg.value == mintPrice, "MD:pm:402");
        _mint(msg.sender, _tokenId.current());
        _tokenId.increment();
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
