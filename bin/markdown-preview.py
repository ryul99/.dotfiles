#!/usr/bin/env python3
# Acknowledgment: https://github.com/selimacerbas/markdown-preview.nvim
"""Preview a Markdown file in a browser using a standard-library SSE server."""

import argparse
import mimetypes
import re
import secrets
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlsplit


HTML_FILE = (Path(__file__).resolve().parent.parent / "assets" / "markdown-preview.html")


class PreviewServer(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, source, port, theme, allow_html):
        self.source = source
        self.token = secrets.token_urlsafe(24)
        self.changed = threading.Condition()
        self.stopped = threading.Event()
        self.version = 0
        self.content = source.read_text(encoding="utf-8")
        page = HTML_FILE.read_text(encoding="utf-8")
        for key, value in {
            "__THEME__": theme,
            "__BOTTOM_PADDING__": "0.5",
            "__MERMAID_ELK__": "false",
            "__LIVE_TOKEN__": self.token,
            "__YAML_MODE__": "panel",
            "__ALLOW_HTML__": str(allow_html).lower(),
        }.items():
            page = page.replace(key, value)
        self.page = page.encode("utf-8")
        super().__init__(("127.0.0.1", port), PreviewHandler)

    def watch(self):
        while not self.stopped.wait(0.3):
            try:
                content = self.source.read_text(encoding="utf-8")
            except (OSError, UnicodeError):
                # Keep the last readable content during atomic saves.
                continue
            with self.changed:
                if content != self.content:
                    self.content = content
                    self.version += 1
                    self.changed.notify_all()


class PreviewHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def respond(self, body, content_type, status=200):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        try:
            self.get()
        except (BrokenPipeError, ConnectionResetError, TimeoutError):
            pass

    def get(self):
        url = urlsplit(self.path)
        query = parse_qs(url.query)
        if query.get("t", [""])[0] != self.server.token:
            self.respond(b"Unauthorized", "text/plain", 401)
            return
        if url.path == "/":
            self.respond(self.server.page, "text/html; charset=utf-8")
        elif url.path == "/content.md":
            with self.server.changed:
                content = self.server.content
            if self.server.source.suffix.lower() in (".mmd", ".mermaid"):
                fence = "`" * max(3, max(map(len, re.findall(r"`+", content)), default=0) + 1)
                content = f"{fence}mermaid\n{content}\n{fence}\n"
            self.respond(content.encode("utf-8"), "text/plain; charset=utf-8")
        elif url.path == "/__live/events":
            self.events()
        elif url.path == "/__live/asset":
            self.asset(query.get("p", [""])[0])
        else:
            self.respond(b"Not found", "text/plain", 404)

    def asset(self, name):
        root = self.server.source.parent
        try:
            path = (root / unquote(urlsplit(name).path)).resolve()
            path.relative_to(root)
            content_type = mimetypes.guess_type(str(path))[0] or "application/octet-stream"
            if not content_type.startswith("image/"):
                self.respond(b"Only images are served", "text/plain", 403)
                return
            body = path.read_bytes()
        except (OSError, ValueError, RuntimeError):
            self.respond(b"Not found", "text/plain", 404)
            return
        self.respond(body, content_type)

    def events(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("X-Accel-Buffering", "no")
        self.end_headers()
        self.connection.settimeout(5)
        version = -1
        while not self.server.stopped.is_set():
            with self.server.changed:
                self.server.changed.wait_for(
                    lambda: self.server.version != version or self.server.stopped.is_set(),
                    timeout=10,
                )
                current = self.server.version
            if self.server.stopped.is_set():
                break
            if current != version:
                self.wfile.write(b"event: reload\ndata: {}\n\n")
                version = current
            else:
                self.wfile.write(b": keepalive\n\n")
            self.wfile.flush()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", type=Path, help="UTF-8 Markdown or Mermaid file")
    parser.add_argument("--port", type=int, default=0, help="local port (default: automatic)")
    parser.add_argument("--no-browser", action="store_true", help="only print the preview URL")
    parser.add_argument("--theme", choices=("dark", "light"), default="dark")
    parser.add_argument("--allow-html", action="store_true", help="render embedded HTML")
    args = parser.parse_args()
    if not 0 <= args.port <= 65535:
        parser.error("port must be between 0 and 65535")
    try:
        server = PreviewServer(args.file.resolve(), args.port, args.theme, args.allow_html)
    except (OSError, UnicodeError) as error:
        parser.error(str(error))
    watcher = threading.Thread(target=server.watch, daemon=True)
    watcher.start()
    url = f"http://127.0.0.1:{server.server_port}/?t={server.token}"
    print(f"Preview: {url}\nPress Ctrl+C to stop.", flush=True)
    if not args.no_browser:
        try:
            webbrowser.open(url)
        except webbrowser.Error:
            print("Could not open a browser. Open the URL above manually.", flush=True)
    try:
        server.serve_forever(poll_interval=0.2)
    except KeyboardInterrupt:
        pass
    finally:
        server.stopped.set()
        with server.changed:
            server.changed.notify_all()
        server.server_close()
        watcher.join()


if __name__ == "__main__":
    main()
