use http-nu/html *

{|req|
  let body = $in
  match $req.path {
    # Home page
    "/" => {
      HTML [
        (HEAD [
          (TITLE "Basic Demo - http-nu")
          (LINK {rel: "stylesheet" href: "/assets/core.css"})
        ])
        (BODY {class: "p-8 max-w-2xl mx-auto"} [
          (H1 {class: "text-4xl font-bold text-header mb-8 shadow-offset rotate-ccw-1"} "Basic Demo")
          (DIV {class: "bg-dark p-6 rounded-lg shadow-float mb-8"} [
            (P "This page demonstrates basic routing and responses in http-nu.")
          ])
          (UL {class: "space-y-4"} [
            (LI (A {href: "hello", class: "text-xl hover:text-accent"} "Hello World (Plain Text)"))
            (LI (A {href: "json", class: "text-xl hover:text-accent"} "JSON Response"))
            (LI (A {href: "echo", class: "text-xl hover:text-accent"} "POST Echo Service"))
            (LI (A {href: "time", class: "text-xl hover:text-accent"} "Real-time Clock (Streaming)"))
            (LI (A {href: "info", class: "text-xl hover:text-accent"} "Request Diagnostics"))
          ])
          (FOOTER {class: "mt-12 pt-8 border-t border-white border-opacity-10"} [
            (A {href: "../", class: "opacity-60"} "← Back to Examples")
          ])
        ])
      ] | get __html
    }

    # Hello world example
    "/hello" => {
      "Hello, World!"
    }

    # JSON response example
    "/json" => {
      {
        message: "This is a JSON response"
        timestamp: (date now | into int)
        server: "http-nu"
        mode: "Nushell-native"
      }
    }

    # Echo POST data
    "/echo" => {
      if $req.method == "POST" {
        # Return the request body
        $body
      } else {
        HTML [
          (HEAD [
            (TITLE "Echo Service - http-nu")
            (LINK {rel: "stylesheet" href: "/assets/core.css"})
          ])
          (BODY {class: "p-8 max-w-2xl mx-auto"} [
            (H1 {class: "text-4xl font-bold text-header mb-8"} "Echo Service")
            (P {class: "mb-6 opacity-80"} "Send a POST request to this URL and the server will echo the body back to you.")
            (FORM {method: "post", class: "space-y-4"} [
              (TEXTAREA {name: "data", class: "w-full bg-dark text-white p-4 rounded-lg border border-purple h-32"})
              (BUTTON {type: "submit", class: "bg-orange text-white px-6 py-2 rounded-lg font-bold shadow-offset"} "Submit Echo")
            ])
            (FOOTER {class: "mt-12 pt-8 border-t border-white border-opacity-10"} [
              (A {href: "./", class: "opacity-60"} "← Back to Basic Demo")
            ])
          ])
        ] | get __html
      }
    }

    # Time stream example
    "/time" => {
      generate {|_|
        sleep 1sec
        {out: $"Current server time: (date now | format date '%Y-%m-%d %H:%M:%S')\n" next: true}
      } true 
      | metadata set --content-type "text/plain" 
      | metadata set --merge {
          'http.response': {
            headers: {
              'Cache-Control': 'no-cache',
              'X-Accel-Buffering': 'no'
            }
          }
        }
    }

    # Show request info
    "/info" => {
      $req
    }

    # 404 for everything else
    _ => {
      "404 - Page not found" | metadata set --merge {'http.response': {status: 404}}
    }
  }
}
