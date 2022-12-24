// DTP Server executable
//
// Typically intended to be deployed as a daemon (Service)
//
use clap::*;
use colored::Colorize;
use std::path::PathBuf;
use telemetry_subscribers;

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
                if let Some(x) = path {
                    println!("{}", x.into_os_string().into_string().unwrap());
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
    let _guard = telemetry_subscribers::TelemetryConfig::new("dtp-server")
        .with_env()
        .init();

    let cmd: Command = Command::parse();

    match cmd.execute().await {
        Ok(_) => (),
        Err(err) => {
            println!("{}", err.to_string().red());
            std::process::exit(1);
        }
    }
}
