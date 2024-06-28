use kinode_process_lib::{
    await_message, call_init, get_blob, http, println, Address, Message, Request, Response,
};
use serde::{Deserialize, Serialize};

mod sol_abi;
use sol_abi::{increment, set_number};

wit_bindgen::generate!({
    path: "target/wit",
    world: "process-v0",
});

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
}

impl State {
    fn new() -> Self {
        Self {
            worlds: vec![],
            channel_id: None,
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
