# Production HTTP Handler with All Examples
# This handler mounts all examples at dedicated /examples/* endpoints
# Usage: http-nu --store /data/store :${PORT} ./serve.nu

use http-nu/router *
use http-nu/html *

# ============================================================================
# Helper Functions
# ============================================================================

# Helper: Generate a modified request with stripped prefix
def strip-prefix [prefix: string]: record -> record {
  let req = $in
  let new_path = ($req.path | str replace $prefix "")
  let new_path = if ($new_path | is-empty) { "/" } else { $new_path }
  $req | update path $new_path | update uri $new_path
}

# Helper: Check if path starts with a prefix (supports exact match or sub-paths)
def prefix-match [prefix: string]: record -> any {
  let path = $in.path
  if ($path == $prefix) or ($path | str starts-with $"($prefix)/") { {} } else { null }
}

# ============================================================================
# Main Request Handler
# ============================================================================

{|req|
  dispatch $req [
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
          (TITLE "http-nu Examples - Live Demo")
          (STYLE "
            * { box-sizing: border-box; margin: 0; padding: 0; }
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
              line-height: 1.6;
              color: #333;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              min-height: 100vh;
              padding: 2rem 1rem;
            }
            .container {
              max-width: 900px;
              margin: 0 auto;
              background: white;
              border-radius: 16px;
              box-shadow: 0 20px 60px rgba(0,0,0,0.3);
              overflow: hidden;
            }
            header {
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white;
              padding: 3rem 2rem;
              text-align: center;
            }
            header h1 {
              font-size: 2.5rem;
              margin-bottom: 0.5rem;
              font-weight: 700;
            }
            header p {
              font-size: 1.1rem;
              opacity: 0.95;
            }
            .content {
              padding: 2rem;
            }
            .intro {
              background: #f8f9fa;
              padding: 1.5rem;
              border-radius: 8px;
              margin-bottom: 2rem;
              border-left: 4px solid #667eea;
            }
            .examples {
              display: grid;
              gap: 1.5rem;
            }
            .example {
              border: 2px solid #e9ecef;
              border-radius: 12px;
              padding: 1.5rem;
              transition: all 0.3s ease;
              background: white;
            }
            .example:hover {
              border-color: #667eea;
              box-shadow: 0 8px 24px rgba(102, 126, 234, 0.15);
              transform: translateY(-2px);
            }
            .example h3 {
              margin-bottom: 0.75rem;
              color: #667eea;
              font-size: 1.3rem;
            }
            .example h3 a {
              color: #667eea;
              text-decoration: none;
              display: flex;
              align-items: center;
              gap: 0.5rem;
            }
            .example h3 a:hover {
              color: #764ba2;
            }
            .example p {
              color: #6c757d;
              margin-bottom: 1rem;
            }
            .example .tags {
              display: flex;
              gap: 0.5rem;
              flex-wrap: wrap;
            }
            .tag {
              background: #e9ecef;
              color: #495057;
              padding: 0.25rem 0.75rem;
              border-radius: 12px;
              font-size: 0.85rem;
              font-weight: 500;
            }
            .tag.feature {
              background: #d4edda;
              color: #155724;
            }
            footer {
              text-align: center;
              padding: 2rem;
              color: #6c757d;
              border-top: 1px solid #e9ecef;
            }
            footer a {
              color: #667eea;
              text-decoration: none;
            }
            footer a:hover {
              text-decoration: underline;
            }
            .arrow {
              display: inline-block;
              transition: transform 0.3s ease;
            }
            .example:hover .arrow {
              transform: translateX(4px);
            }
          ")
        ])
        (BODY [
          (DIV {class: "container"} [
            (HEADER [
              (H1 "http-nu Examples")
              (P "The surprisingly performant, Datastar-ready, Nushell-scriptable HTTP server")
            ])
            
            (DIV {class: "content"} [
              (DIV {class: "intro"} [
                (P "Welcome to the http-nu live demo! Explore interactive examples showcasing the capabilities of http-nu, from basic routing to real-time Server-Sent Events and Datastar integration.")
              ])
              
              (DIV {class: "examples"} [
                # Basic Example
                (DIV {class: "example"} [
                  (H3 (A {href: "/examples/basic"} [
                    "Basic HTTP Server"
                    (SPAN {class: "arrow"} "→")
                  ]))
                  (P "Fundamental HTTP server patterns including routing, JSON responses, POST echo, and streaming time updates.")
                  (DIV {class: "tags"} [
                    (SPAN {class: "tag feature"} "Routing")
                    (SPAN {class: "tag feature"} "JSON")
                    (SPAN {class: "tag feature"} "Streaming")
                  ])
                ])
                
                # Quotes Example
                (DIV {class: "example"} [
                  (H3 (A {href: "/examples/quotes"} [
                    "Live Quotes"
                    (SPAN {class: "arrow"} "→")
                  ]))
                  (P "Real-time quote updates using Server-Sent Events, Datastar, and the embedded cross-stream store.")
                  (DIV {class: "tags"} [
                    (SPAN {class: "tag feature"} "SSE")
                    (SPAN {class: "tag feature"} "Datastar")
                    (SPAN {class: "tag feature"} "Store")
                    (SPAN {class: "tag"} "Real-time")
                  ])
                ])
                
                # Datastar SDK Example
                (DIV {class: "example"} [
                  (H3 (A {href: "/examples/datastar"} [
                    "Datastar SDK Demo"
                    (SPAN {class: "arrow"} "→")
                  ]))
                  (P "Interactive demonstrations of Datastar SDK features including signals, script execution, and element patching.")
                  (DIV {class: "tags"} [
                    (SPAN {class: "tag feature"} "Datastar")
                    (SPAN {class: "tag feature"} "Interactive")
                    (SPAN {class: "tag"} "Signals")
                  ])
                ])
                
                # Datastar Test Example
                (DIV {class: "example"} [
                  (H3 (A {href: "/examples/datastar-test"} [
                    "Datastar Tests"
                    (SPAN {class: "arrow"} "→")
                  ]))
                  (P "Additional test cases and examples for Datastar SDK integration patterns.")
                  (DIV {class: "tags"} [
                    (SPAN {class: "tag feature"} "Datastar")
                    (SPAN {class: "tag"} "Testing")
                  ])
                ])
                
                # Template Inheritance Example
                (DIV {class: "example"} [
                  (H3 (A {href: "/examples/templates"} [
                    "Template Inheritance"
                    (SPAN {class: "arrow"} "→")
                  ]))
                  (P "Minijinja template system demonstration with template inheritance and composition.")
                  (DIV {class: "tags"} [
                    (SPAN {class: "tag feature"} "Templates")
                    (SPAN {class: "tag feature"} "Minijinja")
                    (SPAN {class: "tag"} "Inheritance")
                  ])
                ])
              ])
            ])
            
            (FOOTER [
              (P [
                "Powered by "
                (A {href: "https://github.com/cablehead/http-nu"} "http-nu")
                " • "
                (A {href: "https://www.nushell.sh"} "Nushell")
                " • "
                (A {href: "https://data-star.dev"} "Datastar")
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
        return ("" | metadata set --merge {'http.response': {status: 301, headers: {location: "/examples/basic/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/basic")
      let handler = (source "examples/basic.nu")
      do $handler $modified_req
    })
    
    # Quotes Example - SSE, Datastar, and Store
    (route {|req| $req | prefix-match "/examples/quotes"} {|req ctx|
      if $req.path == "/examples/quotes" { 
        return ("" | metadata set --merge {'http.response': {status: 301, headers: {location: "/examples/quotes/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/quotes")
      let handler = (source "examples/quotes/serve.nu")
      do $handler $modified_req
    })
    
    # Datastar SDK Example
    (route {|req| $req | prefix-match "/examples/datastar"} {|req ctx|
      if $req.path == "/examples/datastar" { 
        return ("" | metadata set --merge {'http.response': {status: 301, headers: {location: "/examples/datastar/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/datastar")
      let handler = (source "examples/datastar-sdk/serve.nu")
      do $handler $modified_req
    })
    
    # Datastar Test Example
    (route {|req| $req | prefix-match "/examples/datastar-test"} {|req ctx|
      if $req.path == "/examples/datastar-test" { 
        return ("" | metadata set --merge {'http.response': {status: 301, headers: {location: "/examples/datastar-test/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/datastar-test")
      let handler = (source "examples/datastar-sdk-test/serve.nu")
      do $handler $modified_req
    })
    
    # Template Inheritance Example
    (route {|req| $req | prefix-match "/examples/templates"} {|req ctx|
      if $req.path == "/examples/templates" { 
        return ("" | metadata set --merge {'http.response': {status: 301, headers: {location: "/examples/templates/"}}})
      }
      let modified_req = ($req | strip-prefix "/examples/templates")
      # Note: We avoid 'cd' here to prevent race conditions in multi-threaded env
      let handler = (source "examples/template-inheritance/serve.nu")
      do $handler $modified_req
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
