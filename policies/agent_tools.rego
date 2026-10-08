package agent.tools

import future.keywords.in

default allow = false

# Allow tool invocation only if all safety checks pass
allow {
    valid_tool
    not denied_command
    not illegal_target
}

# Whitelist allowed tool operations
valid_tool {
    input.tool_name in ["read_file", "search_docs", "run_sandbox_command"]
}

# Block destructive shell patterns in agent command execution
denied_command {
    input.tool_name == "run_sandbox_command"
    regex.match("(rm -rf|mkfs|chmod \+x|curl.*\|.*sh|wget|nc -e|sudo)", input.tool_args.command)
}

# Prevent file access outside ephemeral workspace
illegal_target {
    input.tool_name in ["read_file", "write_file"]
    not startswith(input.tool_args.path, "/tmp/")
}
