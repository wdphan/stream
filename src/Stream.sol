// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Stream {

    address payable public recipient;

    mapping (address => uint256) public balanceOfAddress;

    mapping (address => bool) public streamActive;

    mapping (address => uint256) public streamRate;

    event StreamStart(address sender, address recipient, uint256 rate);
    
    event StreamStop(address sender);
    
    event StreamUpdate(address sender, uint256 rate);

    constructor(address payable _recipient) public {
        recipient = _recipient;
    }

    function startStream(uint256 rate) public payable {
        require(balanceOfAddress[msg.sender] > rate);
        streamActive[msg.sender] = true;
        streamRate[msg.sender] = rate;
        balanceOfAddress[msg.sender] += msg.value;
        emit StreamStart(msg.sender, recipient, rate);
    }

    function updateStreamRate(uint256 rate) public {
        require(streamActive[msg.sender]);
        require(rate > 0);
        streamRate[msg.sender] = rate;
        emit StreamUpdate(msg.sender, rate);
    }

    function stopStream() public {
        require(streamActive[msg.sender]);
        streamActive[msg.sender] = false;
        emit StreamStop(msg.sender);
    }

    function deposit() public payable {
        require(streamActive[msg.sender]);
        balanceOfAddress[msg.sender] += msg.value;
    }

    function balanceOf(address wallet) public view returns (uint256) {
        return balanceOfAddress[wallet];
    }

    function stream() public {
        require(streamActive[msg.sender]);
        require(balanceOfAddress[msg.sender] >= streamRate[msg.sender]);
        balanceOfAddress[msg.sender] -= streamRate[msg.sender];
        recipient.transfer(streamRate[msg.sender]);
    }

    function cancel() public {
        stopStream();
    }
}
