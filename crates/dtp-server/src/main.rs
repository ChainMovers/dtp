// DTP Server executable
//
// Typically intended to be deployed as a daemon (Service)
//
use clap::*;
use colored::Colorize;
use std::path::PathBuf;
use telemetry_subscribers::TelemetryConfig;

use futures::StreamExt;
use sui_json_rpc_types::SuiEvent;
use sui_sdk::rpc_types::SuiEventFilter;
use sui_sdk::SuiClientBuilder;

#[allow(clippy::large_enum_variant)]
#[derive(Parser)]
#[clap(
    name = "dtp-server",
    about = "Server for Decentralized Transport Protocol over Sui network",
    rename_all = "kebab-case",
    author,
    version
)]
pub enum Command {
    #[clap(name = "localnet")]
    Localnet {
        #[clap(long = "path")]
        path: Option<PathBuf>,
    },
}

impl Command {
    pub async fn execute(self) -> Result<(), anyhow::Error> {
        match self {
            Command::Localnet { path } => {
                if let Some(_x) = path {
                    let sui = SuiClientBuilder::default()
                        .build("http://0.0.0.0:9000")
                        .await?;
                    let mut subscribe_all = sui
                        .event_api()
                        .subscribe_event(SuiEventFilter::All(vec![]))
                        .await?;
                    loop {
                        // Receive Sui Network event loop goal:
                        //     Filter, parse, and forward a message to another thread to react.
                        //
                        let nxt = subscribe_all.next().await;
                        if nxt.is_none() {
                            continue;
                        }
                        if let Ok(env) = nxt.unwrap() {
                            match env.event {
                                SuiEvent::Publish { package_id, .. } => {
                                    println!("Publish package{}", package_id.to_hex())
                                }
                                SuiEvent::MoveEvent { package_id, .. } => {
                                    println!("Received event from package{}", package_id.to_hex())
                                }
                                SuiEvent::NewObject {
                                    package_id,
                                    object_id,
                                    ..
                                } => {
                                    println!(
                                        "NewObject package ID {} object ID {}",
                                        package_id.to_hex(),
                                        object_id.to_hex()
                                    )
                                }

                                _ => {}
                            }
                        }
                    }
                } else {
                    println!("Path not provided");
                }
                Ok(())
            }
        }
    }
}

#[tokio::main]
async fn main() {
    #[cfg(windows)]
    colored::control::set_virtual_terminal(true).unwrap();

    // TODO Socket for external dtp CLI binary (this is the server not the CLI!)
    // TODO Look into https://crates.io/crates/sentry-tracing for bail/panic logging.
    let _guard = TelemetryConfig::new("dtp-server").with_env().init();

    let cmd: Command = Command::parse();

    match cmd.execute().await {
        Ok(_) => (),
        Err(err) => {
            println!("{}", err.to_string().red());
            std::process::exit(1);
        }
    }
}
