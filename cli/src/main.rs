#![doc = include_str!("../README.md")]

#[cfg(not(target_arch = "wasm32"))]
#[tokio::main(flavor = "current_thread")]
async fn main() -> anyhow::Result<()> {
    console_subscriber::init();
    lumina_cli::run().await
}

// Placeholder to allow compilation
#[cfg(target_arch = "wasm32")]
fn main() {}
