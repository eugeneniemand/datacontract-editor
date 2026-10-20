
#!/usr/bin/env bash
set -e

cd /workspace

start_service() {
    local name="$1"
    local port="$2"
    local directory="$3"
    shift 3

    if curl -fsS "http://localhost:$port/" >/dev/null 2>&1; then
        echo "$name already running"
        return
    fi

    echo "Starting $name..."

    (
        cd "$directory"
        setsid "$@" > "/tmp/${name}.log" 2>&1 \
            < /dev/null &
    )

    echo "$name launch requested"
}

# GitHub adapter needs its /health endpoint
if ! curl -fsS http://localhost:4001/health >/dev/null 2>&1; then
    start_service "github-adapter" 4001 \
        /workspace \
        node examples/github-server/github-server.js
fi

start_service "editor" 5173 \
    /workspace/examples/github-server \
    npm run dev

echo "Startup script completed."
