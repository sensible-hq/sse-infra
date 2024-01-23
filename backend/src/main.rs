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
    })
    .bind(format!("{}:{}", "127.0.0.1", "8000"))?
    .run()
    .await
}
