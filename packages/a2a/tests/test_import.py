import importlib


def test_package_imports():
    importlib.import_module("agent_stack_a2a")
    importlib.import_module("agent_stack_a2a.agent")
    importlib.import_module("agent_stack_a2a.orchestrator")
