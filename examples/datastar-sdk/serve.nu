use http-nu/router *
use http-nu/datastar *
use http-nu/html *

{|req|
  dispatch $req [
    # Index page
    (
      route {method: GET path: "/"} {|req ctx|
        (
          HTML
          (
            HEAD
            (META {charset: "UTF-8"})
            (TITLE "Datastar SDK Demo - http-nu")
            (LINK {rel: "stylesheet" href: "/assets/core.css"})
            (SCRIPT {type: "module" src: $DATASTAR_CDN_URL})
          )
          (
            BODY {"data-signals": "{count: 0}", class: "p-8 max-w-4xl mx-auto"}
            (DIV {class: "flex flex-col items-center"} [
              (HEADER {class: "mb-12 text-center"} [
                (H1 {class: "text-4xl font-bold tracking-wide text-header shadow-offset rotate-ccw-1"} "Datastar SDK Demo")
                (P {class: "opacity-80 mt-2"} "Interactive hypermedia patterns in Nushell")
              ])
              (
                DIV {class: "grid md:grid-cols-3 gap-6 w-full"} [
                  (
                    DIV {class: "bg-card border border-white p-6 rounded-lg shadow-offset"} [
                      (H3 {class: "text-xl font-bold text-header mb-4"} "Signals")
                      (P {class: "mb-6 opacity-70"} "Update shared client-state signals via JSON Merge Patch.")
                      (P {class: "text-2xl font-mono mb-4 text-center"} [
                        "Count: " (SPAN {"data-text": "$count", class: "text-accent"} "0")
                      ])
                      (BUTTON {class: "w-full bg-orange text-white py-2 rounded font-bold shadow-offset", "data-on:click": "@post('increment')"} "Increment")
                    ]
                  )
                  (
                    DIV {class: "bg-card border border-white p-6 rounded-lg shadow-offset"} [
                      (H3 {class: "text-xl font-bold text-header mb-4"} "Scripts")
                      (P {class: "mb-6 opacity-70"} "Dynamically push JavaScript tasks to the client execution queue.")
                      (DIV {class: "h-20 flex items-center justify-center"} [
                        (BUTTON {class: "w-full bg-purple text-white py-2 rounded font-bold shadow-offset", "data-on:click": "@post('hello')"} "Say Hello")
                      ])
                    ]
                  )
                  (
                    DIV {class: "bg-card border border-white p-6 rounded-lg shadow-offset"} [
                      (H3 {class: "text-xl font-bold text-header mb-4"} "Elements")
                      (P {class: "mb-6 opacity-70"} "Directly target and replace HTML fragments with precise selectors.")
                      (DIV {id: "time", class: "text-xl font-mono mb-4 text-center bg-dark p-2 rounded"} "--:--:--.---")
                      (BUTTON {class: "w-full bg-green text-white py-2 rounded font-bold shadow-offset", "data-on:click": "@post('time')"} "Get Time")
                    ]
                  )
                ]
              )
              (FOOTER {class: "mt-16 pt-8 border-t border-white border-opacity-10 w-full text-center"} [
                (A {href: "../", class: "opacity-60"} "← Back to Examples")
              ])
            ])
          )
        )
      }
    )

    # Increment counter signal
    (
      route {method: POST path: "/increment"} {|req ctx|
        let txt = ($in | into binary | decode utf-8)
        let body = if ($txt | is-empty) { "{}" } else { $txt }
        let signals = ($body | from datastar-signals $req)
        let count = ($signals.count? | default 0) + 1
        {count: $count} | to datastar-patch-signals | to sse
      }
    )

    # Execute script on client
    (
      route {method: POST path: "/hello"} {|req ctx|
        "alert('Hello from the server!')" | to datastar-execute-script | to sse
      }
    )

    # Update time div
    (
      route {method: POST path: "/time"} {|req ctx|
        let time = date now | format date "%H:%M:%S%.3f"
        DIV {id: "time"} $time | to datastar-patch-elements | to sse
      }
    )
  ]
}
