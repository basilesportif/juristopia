use alloy_sol_types::SolEvent;
use kinode_process_lib::{
    await_message, call_init,
    eth::{Address as EthAddress, Provider},
    get_blob, http, println, Address, Message, Request, Response,
};
use serde::{Deserialize, Serialize};
use std::str::FromStr;

mod sol_juristopia;
use sol_juristopia::{Juristopia, Juristopia::Point};

wit_bindgen::generate!({
    path: "target/wit",
    world: "process-v0",
});

pub const JURISTOPIA_ADDRESS: &str = "0x7a2088a1bFc9d81c55368AE168C2C02570cB814F";
pub const WALLET_KEY: &str = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

#[derive(Serialize, Deserialize, Clone)]
struct Cube {
    x: i32,
    y: i32,
    z: i32,
    halfSideLength: i32,
}

#[derive(Serialize, Deserialize, Clone)]
struct World {
    x: i32,
    y: i32,
    z: i32,
    name: String,
    description: String,
    commitmentHash: String,
    containingCube: Cube,
}

#[derive(Serialize, Deserialize)]
enum JuristopiaRequest {
    Get,
}

#[derive(Serialize, Deserialize)]
struct JuristopiaResponse {
    worlds: Vec<World>,
}

struct State {
    worlds: Vec<World>,
    channel_id: Option<u32>,
    juristopia_caller: sol_juristopia::Caller,
}

impl State {
    fn new() -> Self {
        Self {
            worlds: vec![],
            channel_id: None,
            juristopia_caller: sol_juristopia::Caller::new(
                JURISTOPIA_ADDRESS,
                Provider::new(31337, 5),
                31337,
                WALLET_KEY,
            ),
        }
    }
}

fn handle_ws_message(state: &mut State, channel_id: u32) -> anyhow::Result<()> {
    let blob = get_blob().ok_or_else(|| anyhow::anyhow!("Failed to get blob"))?;
    let message: JuristopiaRequest = serde_json::from_slice(&blob.bytes)?;

    match message {
        JuristopiaRequest::Get => {}
    }

    let response = JuristopiaResponse { worlds: vec![] };
    let response_bytes = serde_json::to_vec(&response)?;

    http::send_ws_push(
        channel_id,
        http::WsMessageType::Text,
        kinode_process_lib::LazyLoadBlob {
            mime: Some("application/json".to_string()),
            bytes: response_bytes,
        },
    );
    Ok(())
}

fn handle_message(our: &Address, state: &mut State) -> anyhow::Result<()> {
    let message = await_message()?;

    if message.source().node != our.node {
        return Ok(());
    }
    /* debug only */
    let body: serde_json::Value = serde_json::from_slice(message.body())?;
    println!("got {body:?}");

    let p = Point { x: 6, y: 8, z: 7 };
    let cost = state.juristopia_caller.spawn_cost_of_point(p).unwrap();
    println!("cost: {} WEI", cost.to_string());

    /*
    match state.juristopia_caller.spawn_world(
        Point { x: 6, y: 8, z: 7 },
        "test".to_string(),
        "a stupid test world".to_string(),
        [1u8; 32],
        cost,
    ) {
        Ok(tx_hash) => {
            println!("spawnWorld tx_hash: {:?}", tx_hash.to_string());
        }
        Err(e) => {
            println!("Error spawning world: {:?}", e);
        }
    }
    */

    if let Ok(logs) = state.juristopia_caller.get_world_spawn_logs() {
        logs.iter()
            .filter_map(|log| Juristopia::WorldSpawned::decode_log_data(log.data(), true).ok())
            .for_each(|event| println!("WorldSpawned: {:?}", event));
    }

    match message {
        Message::Request { ref body, .. } => {
            let http_request: http::HttpServerRequest = serde_json::from_slice(body)?;
            match http_request {
                http::HttpServerRequest::Http(req) => {
                    println!("Unexpected Http request");
                    Err(anyhow::anyhow!("Unexpected Http request"))
                }
                http::HttpServerRequest::WebSocketOpen { channel_id, .. } => {
                    state.channel_id = Some(channel_id);
                    Ok(())
                }
                http::HttpServerRequest::WebSocketClose(channel_id) => {
                    state.channel_id = None;
                    Ok(())
                }
                http::HttpServerRequest::WebSocketPush { channel_id, .. } => {
                    if state.channel_id != Some(channel_id) {
                        return Err(anyhow::anyhow!("Unexpected channel ID"));
                    }
                    handle_ws_message(state, channel_id)
                }
            }
        }
        _ => Ok(()),
    }
}

call_init!(init);
fn init(our: Address) {
    println!("begin");

    let mut state = State::new();
    http::bind_ws_path("/ws", false, false).expect("Failed to bind WebSocket path");

    loop {
        match handle_message(&our, &mut state) {
            Ok(()) => {}
            Err(e) => {
                println!("error: {:?}", e);
            }
        };
    }
}
