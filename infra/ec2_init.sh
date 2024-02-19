#!/bin/bash

# vars
FILE_MAIN_RS="./main.rs"
FILE_BROADCAST_RS="./broadcast.rs"
FILE_CARGO_TOML="./Cargo.toml"
FILE_IPTABLES_SERVICE="./iptableset.service"
FILE_IPTABLES_EXEC="./iptableset"
FILE_BACKEND_SERVICE="./backend.service"
FILE_BACKEND_EXEC="./backend"
HOME="/root"


# directory for application
yum update -y
mkdir /opt/apps
cd /opt/apps

######### create and run application
mkdir backend-src
cd backend-src

cat > $FILE_CARGO_TOML <<- EOM
[package]
name = "actix-sse"
version = "0.1.0"
edition = "2021"


[dependencies]
actix-web = { version = "4.4" }
actix-web-lab = { version = "0.18" }
parking_lot = { version = "0.12" }
futures-util = { version = "0.3", default-features = false, features = ["std"] }
chrono = "0.4.34"
EOM


mkdir src
cd src

cat > $FILE_MAIN_RS <<- EOM
use actix_web::HttpResponse;
use actix_web::Responder;
use actix_web::{web, App, HttpServer};
use actix_web_lab::extract::Path;
use std::sync::Arc;

use self::broadcast::Broadcaster;

mod broadcast;

pub struct AppState {
    broadcaster: Arc<Broadcaster>,
}

// SSE
pub async fn sse_client(state: web::Data<AppState>) -> impl Responder {
    println!("in api");
    state.broadcaster.new_client().await
}

pub async fn broadcast_msg(
    state: web::Data<AppState>,
    Path((msg,)): Path<(String,)>,
) -> impl Responder {
    state.broadcaster.broadcast(&msg).await;
    HttpResponse::Ok().body("msg sent")
}

async fn health_check() -> impl Responder {
    HttpResponse::Ok().body("OK")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let broadcaster = Broadcaster::create();

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(AppState {
                broadcaster: Arc::clone(&broadcaster),
            }))
            .route("/events{_:/?}", web::get().to(sse_client))
            .route("/events/{msg}", web::get().to(broadcast_msg))
            .route("/health-check", web::get().to(health_check))
    })
    .bind(format!("{}:{}", "0.0.0.0", "8000"))?
    .run()
    .await
}
EOM


cat > $FILE_BROADCAST_RS <<- EOM
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
                        "ping! You are connected for {}m:{}s (total {}s) Hostname: {}",
                        diff_minutes, diff_seconds, diff,
                        "$(hostname -f)"
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

        tx.send(sse::Data::new("connected to $(hostname -f)")).await.unwrap();
        println!("creating new clients success {:?}", tx);
        self.inner.lock().clients.push((tx, Utc::now()));
        rx
    }

    /// Broadcasts msg to all clients.
    pub async fn broadcast(&self, msg: &str) {
        let clients = self.inner.lock().clients.clone();

        let send_futures = clients
            .iter()
            .map(|client| client.0.send(sse::Data::new(msg)));

        // try to send to all clients, ignoring failures
        // disconnected clients will get swept up by remove_stale_clients
        let _ = future::join_all(send_futures).await;
    }
}
EOM

cd ..

sudo yum groupinstall -y 'Development Tools'
curl https://sh.rustup.rs -sSf | sh -s -- -y # no confirm
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
######### create and run application


######### backend application service
cd /etc/systemd/system
cat > $FILE_BACKEND_SERVICE <<- EOM
[Unit]
Description=Backend service
After=syslog.target network.target
[Service]
SuccessExitStatus=143
User=root
Group=root

Type=simple

ExecStart=/opt/apps/backend
ExecStop=/bin/kill -15 $MAINPID

[Install]
WantedBy=multi-user.target
EOM

cd /opt/apps
cat > $FILE_BACKEND_EXEC <<- EOM
#!/bin/bash

WORKDIR=/opt/apps/backend-src
cd \$WORKDIR
$HOME/.cargo/bin/cargo run
EOM

chmod 777 $FILE_BACKEND_EXEC
######### backend application service


######### run backend
systemctl daemon-reload
systemctl start backend.service
systemctl status backend.service
systemctl enable backend.service
######### run backend

