use alloy::{
    consensus::{SignableTransaction, TxEip1559, TxEnvelope},
    network::eip2718::Encodable2718,
    network::TxSignerSync,
    primitives::TxKind,
    rpc::types::eth::TransactionRequest,
    signers::local::PrivateKeySigner,
};
use alloy_primitives::{Bytes, FixedBytes, I256, U256};
use alloy_rlp::Encodable;
use alloy_sol_types::{sol, SolCall, SolEvent, SolValue};
use kinode_process_lib::eth::{Address as EthAddress, BlockNumberOrTag, Filter, Log, Provider};
use std::str::FromStr;

pub struct Caller {
    contract_address: String,
    provider: Provider,
    wallet: PrivateKeySigner,
}
/* ABI import */
sol!(
    #[allow(missing_docs)]
    #[sol(rpc)]
    #[derive(Debug)]
    Juristopia,
    "abi/Juristopia.json"
);

fn send_tx(
    provider: &Provider,
    signer: &PrivateKeySigner,
    contract_address: &str,
    call: Bytes,
    gas_limit: u128,
    max_fee_per_gas: u128,
    max_priority_fee_per_gas: u128,
    value: U256,
) -> anyhow::Result<FixedBytes<32>> {
    let nonce = provider
        .get_transaction_count(signer.address(), None)
        .unwrap()
        .to::<u64>();

    let mut tx = TxEip1559 {
        chain_id: 31337,
        nonce: nonce,
        to: TxKind::Call(EthAddress::from_str(contract_address).unwrap()),
        gas_limit: gas_limit,
        max_fee_per_gas: max_fee_per_gas,
        max_priority_fee_per_gas: max_priority_fee_per_gas,
        input: call,
        value: value,
        ..Default::default()
    };

    let sig = signer.sign_transaction_sync(&mut tx)?;
    let signed = TxEnvelope::from(tx.into_signed(sig));
    let mut buf = vec![];
    signed.encode_2718(&mut buf);

    let result = provider.send_raw_transaction(buf.into());
    match result {
        Ok(tx_hash) => Ok(tx_hash),
        Err(e) => Err(anyhow::anyhow!("Error sending transaction: {:?}", e)),
    }
}

impl Caller {
    pub fn new(contract_address: &str, provider: Provider, wallet_addr: &str) -> Self {
        Self {
            contract_address: contract_address.to_string(),
            provider,
            wallet: PrivateKeySigner::from_str(wallet_addr).unwrap(),
        }
    }

    pub fn get_world_spawn_logs(&self) -> anyhow::Result<Vec<Log>> {
        let filter = Filter::new()
            .address(EthAddress::from_str(&self.contract_address).unwrap())
            .from_block(0)
            .to_block(BlockNumberOrTag::Latest);
        match self.provider.get_logs(&filter) {
            Ok(logs) => Ok(logs),
            Err(_) => {
                println!("failed to fetch WorldSpawned logs!");
                Err(anyhow::anyhow!("Error fetching WorldSpawned logs!"))
            }
        }
    }

    // call overloaded version that takes a point
    pub fn spawn_cost_of_point(&self, p: Juristopia::Point) -> anyhow::Result<U256> {
        let call = Juristopia::spawnCostOfPointCall { p: p }.abi_encode();

        let tx = TransactionRequest::default()
            .to(EthAddress::from_str(&self.contract_address).unwrap())
            .input(call.into());

        match self.provider.call(tx, None) {
            Ok(result) => {
                let cost = U256::abi_decode(&result, false)?;
                Ok(cost)
            }
            Err(e) => Err(anyhow::anyhow!("Error getting spawn cost: {:?}", e)),
        }
    }
    /// Spawns a new world in the Juristopia universe.
    ///
    /// # Important
    /// Before calling this function, you should first call `spawn_cost_of_point` to determine
    /// the correct `value` to pass. The `value` parameter represents the cost in wei
    /// to spawn the world, which is calculated based on the density and distance from
    /// the center of the containing cube.
    ///
    /// # Arguments
    /// * `p` - The 3D coordinates where the world will be spawned
    /// * `name` - The name of the new world (must be non-empty and 32 characters or less)
    /// * `description` - A description of the new world (must be non-empty)
    /// * `commitment_hash` - A 32-byte hash representing the commitment to the world
    /// * `value` - The amount of wei to send with the transaction (should be >= the spawn cost)
    ///
    /// # Returns
    /// * `Ok(())` if the world was successfully spawned
    /// * `Err` with an error message if the spawning failed
    ///
    /// # Errors
    /// This function will return an error if:
    /// - The transaction fails to send
    /// - The contract reverts the transaction (e.g., if not enough ETH is sent)
    pub fn spawn_world(
        &self,
        p: Juristopia::Point,
        name: String,
        description: String,
        commitment_hash: [u8; 32],
        value: U256,
    ) -> anyhow::Result<FixedBytes<32>> {
        let call = Juristopia::spawnWorldCall {
            p,
            name,
            description,
            commitmentHash: FixedBytes::from(commitment_hash),
        }
        .abi_encode();

        match send_tx(
            &self.provider,
            &self.wallet,
            &self.contract_address,
            call.into(),
            1500000,
            10000000000,
            300000000,
            value,
        ) {
            Ok(tx_hash) => Ok(tx_hash),
            Err(e) => Err(anyhow::anyhow!("Error spawning world: {:?}", e)),
        }
    }
}
