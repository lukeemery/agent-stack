import importlib


def test_package_imports():
    importlib.import_module("agent_stack_mcp")
    importlib.import_module("agent_stack_mcp.server")
    importlib.import_module("agent_stack_mcp.client_adapter")
