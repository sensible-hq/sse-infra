use actix_web::rt::time::interval;
use actix_web_lab::sse::{self, ChannelStream, Sse};
use chrono::{DateTime, Utc};
use futures_util::future;
use parking_lot::Mutex;
use std::{sync::Arc, time::Duration};

pub struct Broadcaster {
    inner: Mutex<BroadcasterInner>,
}

#[derive(Debug, Clone, Default)]
struct BroadcasterInner {
    clients: Vec<(sse::Sender, DateTime<Utc>)>,
}

impl Broadcaster {
    /// Constructs new broadcaster and spawns ping loop.
    pub fn create() -> Arc<Self> {
        let this = Arc::new(Broadcaster {
            inner: Mutex::new(BroadcasterInner::default()),
        });
        Broadcaster::spawn_ping(Arc::clone(&this));
        // println!("created success");

        this
    }

    /// Pings clients every 10 seconds to see if they are alive and remove them from the broadcast list if not.
    fn spawn_ping(this: Arc<Self>) {
        actix_web::rt::spawn(async move {
            let mut interval = interval(Duration::from_secs(10));

            loop {
                interval.tick().await;
                this.remove_stale_clients().await;
            }
        });
    }

    /// Removes all non-responsive clients from broadcast list.
    async fn remove_stale_clients(&self) {
        let clients = self.inner.lock().clients.clone();
        println!("active client {:?}", clients);

        let mut ok_clients = Vec::new();

        println!("okay active client {:?}", ok_clients);

        for client in clients {
            let now = Utc::now();
            let diff = (now - client.1).num_seconds();
            let diff_minutes = diff / 60;
            let diff_seconds = diff % 60;

            if client
                .0
                .send(sse::Event::Comment(
                    format!(
                        "ping! You are connected for {} minutes and {} seconds",
                        diff_minutes, diff_seconds
                    )
                    .into(),
                ))
                .await
                .is_ok()
            {
                ok_clients.push(client.clone());
            }
        }

        self.inner.lock().clients = ok_clients;
    }

    /// Registers client with broadcaster, returning an SSE response body.
    pub async fn new_client(&self) -> Sse<ChannelStream> {
        println!("starting creation");
        let (tx, rx) = sse::channel(10);

        tx.send(sse::Data::new("connected")).await.unwrap();
        println!("creating new clients success {:?}", tx);
        self.inner.lock().clients.push((tx, Utc::now()));
        rx
    }

    /// Broadcasts `msg` to all clients.
    pub async fn broadcast(&self, msg: &str) {
        let clients = self.inner.lock().clients.clone();

        let send_futures = clients
            .iter()
            .map(|client| client.0.send(sse::Data::new(msg)));

        // try to send to all clients, ignoring failures
        // disconnected clients will get swept up by `remove_stale_clients`
        let _ = future::join_all(send_futures).await;
    }
}
