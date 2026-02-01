use http-nu/router *
use http-nu/datastar *
use http-nu/html *

def quote-html [] {
  let q = $in
  (
    DIV {
      id: "quote"
      class: "flex flex-col items-center justify-center p-8 text-center h-[70vh]"
    } [
      (P {
        class: "text-fluid-xl font-bold text-header leading-tight mb-8"
        style: { transition: "all 0.5s ease" }
      } $"\"($q.quote)\"")
      (P {
        class: "text-2xl opacity-60 font-mono"
      } $"— ($q.who? | default 'Anonymous')")
    ]
  )
}

{|req|
  dispatch $req [
    (
      route {method: GET path: "/" has-header: {accept: "text/event-stream"}} {|req ctx|
        .head quotes --follow
        | each {|frame|
          $frame.meta | quote-html | to datastar-patch-elements
        }
        | to sse
      }
    )

    (
      route {method: POST path: "/"} {|req ctx|
        let raw = $in
        let body = if ($raw | is-empty) { "{}" } else { $raw | decode utf-8 }
        let data = ($body | from json)
        $data | .append quotes --meta $data
        null | metadata set --merge {'http.response': {status: 204}}
      }
    )

    (
      route {method: GET path: "/"} {|req ctx|
        (
          HTML
          (
            HEAD
            (META {charset: "utf-8"})
            (TITLE "Live Quotes - http-nu")
            (LINK {rel: "icon" href: "/assets/favicon.ico" sizes: "32x32"})
            (LINK {rel: "icon" href: "/assets/icon.webp" type: "image/webp"})
            (LINK {rel: "apple-touch-icon" href: "/assets/apple-touch-icon-152x152.png"})
            (LINK {rel: "stylesheet" href: "/assets/core.css"})
            (SCRIPT {type: "module" src: $DATASTAR_CDN_URL})
          )
          (
            BODY {data-on-load__delay.1s: "@get('.')", class: "p-4"}
            (DIV {class: "max-w-4xl mx-auto"} [
               (HEADER {class: "mb-12 pt-12 text-center"} [
                 (H1 {class: "text-4xl font-bold tracking-wide text-header shadow-offset rotate-ccw-1"} "Live Quotes")
                 (P {class: "opacity-80 mt-2"} "Streaming real-time insights from the Nushell store")
               ])
               (DIV {class: "bg-dark rounded-lg shadow-float border border-white border-opacity-10 min-h-[50vh] flex items-center justify-center"} [
                 ({quote: "Waiting for quotes..."} | quote-html)
               ])
               (FOOTER {class: "mt-12 pt-8 border-t border-white border-opacity-10 text-center"} [
                 (A {href: "../", class: "opacity-60"} "← Back to Examples")
               ])
            ])
          )
        )
      }
    )
  ]
}
