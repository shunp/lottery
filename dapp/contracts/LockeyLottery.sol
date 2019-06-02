pragma solidity >=0.4.21 <0.6.0;
pragma experimental ABIEncoderV2;

contract LuckeyLottery {

  event Buy (
    address player,
    uint value,
    bytes32 random,
    uint randomInt,
    string judge,
    bool win
  );

  struct Entry {
    address buyer;
    uint quantity;
  }

  uint private lotteryPrice = 1e15;
  uint private totalQuantity;
  uint private depositedAmount = 0;
  Entry[] private entries;

  function setPrice (uint price) public {
    lotteryPrice = price;
  }

  function getPrice () public view returns (uint) {
    return lotteryPrice;
  }

  function buy () public payable {
    // add input due to create random number
    // https://blockchain.gunosy.io/entry/prngs-in-smartcontract 
    require(msg.value % lotteryPrice == 0);

    uint quantity = msg.value / lotteryPrice;
    totalQuantity += quantity;
    depositedAmount += msg.value;

    Entry memory entry = Entry(msg.sender, quantity);
    entries.push(entry);

    bytes32 rand = getRand();
    uint randInt = uint(rand);
    string memory judge = judge(rand);
    emit Buy(msg.sender, msg.value, rand, randInt, judge, false);
  }

  function getRand () private view returns (bytes32) {
    bytes32 blockhash32 = blockhash(block.number - 1);
    bytes memory blockhashbyte = toBytes(blockhash32);
    bytes32 rand = keccak256(blockhashbyte);
    return rand;
  }

  function judge (bytes32 rand) private pure returns (string memory) {
    uint randInt = uint(rand) % 100;
    uint8[3] memory probabilities = [60, 30, 10];
    string[3] memory rewards = ["A", "B", "C"];

    uint tempSum = 0;
    for (uint8 i = 0; i < probabilities.length; i++) {
      tempSum += probabilities[i];
      if (randInt < tempSum) {
        return rewards[i];
      }
    }
  }

  function getTotalQuantity () public view returns (uint) {
    return totalQuantity;
  }

  function getEntries () public view returns (Entry[] memory) {
    return entries;
  }

  function getDepositedAmount () public view returns (uint) {
    return depositedAmount;
  }

  function toBytes(bytes32 _data) public pure returns (bytes memory) {
    return abi.encodePacked(_data);
  }
}