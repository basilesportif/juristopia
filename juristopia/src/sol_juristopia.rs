use alloy::rpc::types::eth::TransactionRequest;
use alloy_primitives::{Address as AlloyAddress, I256};
use alloy_sol_types::{sol, SolCall, SolValue};
use anyhow;
use kinode_process_lib::eth::{Address as EthAddress, Provider};
use std::str::FromStr;

pub struct Caller {
    contract_address: EthAddress,
    provider: Provider,
}

/* ABI import */
sol!(
    #[allow(missing_docs)]
    #[sol(rpc)]
    Juristopia,
    "abi/Juristopia.json"
);

impl Caller {
    pub fn new(contract_address: EthAddress, provider: Provider) -> Self {
        Self {
            contract_address,
            provider,
        }
    }

    pub fn spawn_cost(&self, density: i32, distance_from_center: i64) -> anyhow::Result<I256> {
        let call = Juristopia::spawnCostCall {
            _density: density,
            _distanceFromCenter: I256::unchecked_from(distance_from_center),
        }
        .abi_encode();

        let tx = TransactionRequest::default()
            .to(self.contract_address)
            .input(call.into());

        match self.provider.call(tx, None) {
            Ok(result) => {
                let cost = I256::abi_decode(&result, false)?;
                Ok(cost)
            }
            Err(e) => Err(anyhow::anyhow!("Error getting spawn cost: {:?}", e)),
        }
    }
}
