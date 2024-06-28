use alloy_sol_types::{sol, SolCall, SolValue};
use kinode_process_lib::eth::U256;

sol! {
  contract Counter {
      uint256 public number;

      function setNumber(uint256 newNumber) public {
          number = newNumber;
      }

      function increment() public {
          number++;
      }
  }
}

pub fn set_number(new_number: U256) {
    Counter::setNumberCall {
        newNumber: new_number,
    };
}

pub fn increment() {
    Counter::incrementCall {};
}
