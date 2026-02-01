# Production HTTP Handler with All Examples
# This handler mounts all examples at dedicated /examples/* endpoints
# Usage: http-nu --store /data/store :${PORT} ./serve.nu

use http-nu/router *
use http-nu/html *

# ============================================================================
# Helper Functions
# ============================================================================

# Helper: Generate a modified request with stripped prefix
def strip-prefix [prefix: string] {
  let req = $in
  let new_path = ($req.path | str replace $prefix "")
  let new_path = if ($new_path | is-empty) { "/" } else { $new_path }
  $req | update path $new_path | update uri $new_path
}

# Helper: Check if path starts with a prefix (supports exact match or sub-paths)
def prefix-match [prefix: string] {
  let path = $in.path
  if ($path == $prefix) or ($path | str starts-with $"($prefix)/") { {} } else { null }
}

# ============================================================================
# Main Request Handler
# ============================================================================

{|req|
  dispatch $req [
    # Static Assets
    (route {|req| $req | prefix-match "/assets"} {|req ctx|
      let modified = ($req | strip-prefix "/assets")
      .static "www/assets" $modified.path
    })

    # ========================================================================
    # Core Infrastructure Endpoints
    # ========================================================================
    
    # Health check (required for Render.com)
    (route {path: "/health"} {|req ctx|
      {
        status: "ok"
        service: "http-nu"
        version: "0.10.2"
        timestamp: (date now | into int)
        uptime: "healthy"
      }
    })
    
    # ========================================================================
    # Landing Page
    # ========================================================================
    
    (route {path: "/"} {|req ctx|
      HTML [
        (HEAD [
          (META {charset: "utf-8"})
          (META {name: "viewport" content: "width=device-width, initial-scale=1"})
          (TITLE "http-nu - The Nushell-scriptable HTTP Server")
          (LINK {rel: "preconnect" href: "https://fonts.googleapis.com"})
          (LINK {rel: "preconnect" href: "https://fonts.gstatic.com" crossorigin: ""})
          (LINK {href: "https://fonts.googleapis.com/css2?family=Source+Code+Pro:ital,wght@0,200..900;1,200..900&family=Source+Sans+3:ital,wght@0,200..900;1,200..900&display=swap" rel: "stylesheet"})
          (LINK {rel: "stylesheet" href: "/assets/core.css"})
        ])
        (BODY {class: "flex flex-col items-center pt-12 p-4"} [
          (DIV {class: "flex flex-col items-center w-full max-w-4xl"} [
            (DIV {class: "flex flex-col md:flex-row items-center justify-between w-full mb-12 gap-8"} [
              (DIV {class: "flex flex-col items-center md:items-start"} [
                (DIV {class: "flex items-center gap-4 mb-2"} [
                  (H1 {class: "text-5xl font-bold tracking-wide text-header shadow-offset rotate-ccw-1"} "http-nu")
                  (SPAN {class: "bg-orange text-white px-3 py-1 rounded-full text-sm font-bold shadow-offset rotate-cw-2"} "v0.10.x")
                ])
                (P {class: "text-xl opacity-90"} "The Nushell-scriptable HTTP Server")
              ])
              (DIV {class: "flex gap-2 flex-wrap justify-center"} [
                (SPAN {class: "bg-red text-white px-4 py-2 rounded-lg font-bold shadow-offset rotate-ccw-3"} "Datastar-ready")
                (SPAN {class: "bg-green text-white px-4 py-2 rounded-lg font-bold shadow-glow rotate-cw-4"} "High Performance")
              ])
            ])

            (DIV {class: "w-full space-y-8"} [
              (DIV {class: "bg-dark p-8 rounded-lg mb-12 border border-purple shadow-float"} [
                (P {class: "text-lg leading-relaxed"} "Welcome to the live demo gallery. Each example below is a standalone Nushell script running on the http-nu engine. Explore the power of hypermedia, real-time streams, and scriptable backends.")
              ])

              (DIV {class: "grid gap-8 w-full"} [
                # Cards Container
                (DIV {class: "flex flex-col gap-6"} [
                  # Basic Example
                  (DIV {class: "bg-card border border-white p-6 rounded-lg shadow-offset transition-colors hover:border-purple"} [
                    (DIV {class: "flex items-center justify-between mb-4"} [
                      (H3 {class: "text-2xl font-bold text-header"} (A {href: "/examples/basic/", class: "no-underline hover:text-accent"} "Basic HTTP Server"))
                      (SPAN {class: "bg-purple text-white px-3 py-1 rounded-full text-xs uppercase tracking-wide"} "Standard")
                    ])
                    (P {class: "mb-6 opacity-80"} "Fundamental HTTP patterns: routing, JSON, POST echo, and streaming time updates.")
                    (DIV {class: "flex gap-2"} [
                      (SPAN {class: "text-xs border border-white opacity-50 px-2 py-1 rounded"} "Routing")
                      (SPAN {class: "text-xs border border-white opacity-50 px-2 py-1 rounded"} "Streaming")
                    ])
                  ])

                  # Quotes Example
                  (DIV {class: "bg-card border border-white p-6 rounded-lg shadow-offset transition-colors hover:border-purple"} [
                    (DIV {class: "flex items-center justify-between mb-4"} [
                      (H3 {class: "text-2xl font-bold text-header"} (A {href: "/examples/quotes/", class: "no-underline hover:text-accent"} "Live Quotes"))
                      (SPAN {class: "bg-red text-white px-3 py-1 rounded-full text-xs uppercase tracking-wide"} "Real-time")
                    ])
                    (P {class: "mb-6 opacity-80"} "Real-time quote updates using Server-Sent Events, Datastar, and the embedded cross-stream store.")
                    (DIV {class: "flex gap-2"} [
                      (SPAN {class: "text-xs border border-white opacity-50 px-2 py-1 rounded"} "SSE")
                      (SPAN {class: "text-xs border border-white opacity-50 px-2 py-1 rounded"} "Storage")
                    ])
                  ])

                  # Datastar SDK Example
                  (DIV {class: "bg-card border border-white p-6 rounded-lg shadow-offset transition-colors hover:border-purple"} [
                    (DIV {class: "flex items-center justify-between mb-4"} [
                      (H3 {class: "text-2xl font-bold text-header"} (A {href: "/examples/datastar/", class: "no-underline hover:text-accent"} "Datastar SDK Demo"))
                      (SPAN {class: "bg-orange text-white px-3 py-1 rounded-full text-xs uppercase tracking-wide"} "Interactive")
                    ])
                    (P {class: "mb-6 opacity-80"} "Interactive demonstrations of Datastar SDK features including signals, script execution, and element patching.")
                    (DIV {class: "flex gap-2"} [
                      (SPAN {class: "text-xs border border-white opacity-50 px-2 py-1 rounded"} "SDK")
                      (SPAN {class: "text-xs border border-white opacity-50 px-2 py-1 rounded"} "Signals")
                    ])
                  ])

                  # Template Inheritance Example
                  (DIV {class: "bg-card border border-white p-6 rounded-lg shadow-offset transition-colors hover:border-purple"} [
                    (DIV {class: "flex items-center justify-between mb-4"} [
                      (H3 {class: "text-2xl font-bold text-header"} (A {href: "/examples/templates/", class: "no-underline hover:text-accent"} "Template Inheritance"))
                      (SPAN {class: "bg-green text-white px-3 py-1 rounded-full text-xs uppercase tracking-wide"} "Minijinja")
                    ])
                    (P {class: "mb-6 opacity-80"} "Minijinja template system demonstration with template inheritance and composition.")
                    (DIV {class: "flex gap-2"} [
                      (SPAN {class: "text-xs border border-white opacity-50 px-2 py-1 rounded"} "Brotli")
                      (SPAN {class: "text-xs border border-white opacity-50 px-2 py-1 rounded"} "Layouts")
                    ])
                  ])
                ])
              ])
            ])

            (FOOTER {class: "mt-20 py-8 w-full border-t border-white border-opacity-20 text-center"} [
              (P {class: "opacity-60 text-sm"} [
                "Built with "
                (A {href: "https://github.com/EricEisaman/http-nu", class: "hover:text-white"} "http-nu")
                " • "
                (A {href: "https://www.nushell.sh", class: "hover:text-white"} "Nushell")
                " • "
                (A {href: "https://data-star.dev", class: "hover:text-white"} "Datastar")
              ])
            ])
          ])
        ])
      ] | get __html
    })
    
    # ========================================================================
    # Example Routes
    # ========================================================================
    
    # Basic Example - Simple routing and responses
    (route {|req| $req | prefix-match "/examples/basic"} {|req ctx|
      if $req.path == "/examples/basic" { 
        return ("Redirecting..." | metadata set --merge {'http.response': {status: 301, headers: {Location: "/examples/basic/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/basic")
      let handler = (source "examples/basic.nu")
      do $handler $modified_req
    })
    
    # Quotes Example - SSE, Datastar, and Store
    (route {|req| $req | prefix-match "/examples/quotes"} {|req ctx|
      if $req.path == "/examples/quotes" { 
        return ("Redirecting..." | metadata set --merge {'http.response': {status: 301, headers: {Location: "/examples/quotes/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/quotes")
      let handler = (source "examples/quotes/serve.nu")
      do $handler $modified_req
    })
    
    # Datastar SDK Example
    (route {|req| $req | prefix-match "/examples/datastar"} {|req ctx|
      if $req.path == "/examples/datastar" { 
        return ("Redirecting..." | metadata set --merge {'http.response': {status: 301, headers: {Location: "/examples/datastar/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/datastar")
      let handler = (source "examples/datastar-sdk/serve.nu")
      do $handler $modified_req
    })
    
    # Datastar Test Example
    (route {|req| $req | prefix-match "/examples/datastar-test"} {|req ctx|
      if $req.path == "/examples/datastar-test" { 
        return ("Redirecting..." | metadata set --merge {'http.response': {status: 301, headers: {Location: "/examples/datastar-test/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/datastar-test")
      let handler = (source "examples/datastar-sdk-test/serve.nu")
      do $handler $modified_req
    })
    
    # Template Inheritance Example
    (route {|req| $req | prefix-match "/examples/templates"} {|req ctx|
      if $req.path == "/examples/templates" { 
        return ("Redirecting..." | metadata set --merge {'http.response': {status: 301, headers: {Location: "/examples/templates/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/templates")
      # Note: Instead of source/do, we directly execute the MJ command with the correct base path.
      # This allows Minijinja's loader to find base.html and nav.html automatically.
      { name: "World" } | .mj "examples/template-inheritance/page.html"
    })
    
    # ========================================================================
    # Error Handlers
    # ========================================================================
    
    # 404 - Not Found
    (route true {|req ctx|
      {
        error: "Not Found"
        path: $req.path
        message: $"The requested path '($req.path)' was not found"
        available_endpoints: {
          root: "/"
          health: "/health"
          examples: {
            basic: "/examples/basic"
            quotes: "/examples/quotes"
            datastar: "/examples/datastar"
            datastar_test: "/examples/datastar-test"
            templates: "/examples/templates"
          }
        }
      } | metadata set --merge {'http.response': {status: 404}}
    })
  ]
}

# ============================================================================
# Usage:
# ============================================================================
# 
# Local (without store):
#   http-nu :3001 ./serve.nu
#
# Local (with store for quotes example):
#   http-nu --store ./store :3001 ./serve.nu
#
# Production (Render.com):
#   http-nu --store /app/store :${PORT} /app/serve.nu
#
# Test endpoints:
#   curl http://localhost:3001/
#   curl http://localhost:3001/health
#   curl http://localhost:3001/examples/basic
#   curl http://localhost:3001/examples/quotes
#   curl http://localhost:3001/examples/datastar
#
# ============================================================================
