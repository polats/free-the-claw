import os


def test_process_registry_register_unregister_does_not_crash():
    from cli import process_registry as pr

    pr.register_pid(12345)
    pr.unregister_pid(12345)


def test_process_registry_kill_all_best_effort_empty_is_noop():
    from cli import process_registry as pr

    # Ensure no exception on empty set
    pr.kill_all_best_effort()


def test_process_registry_kill_all_best_effort_windows_noop_when_taskkill_missing(
    monkeypatch,
):
    from cli import process_registry as pr

    # Simulate windows path in a stable way.
    monkeypatch.setattr(pr, "_pids", {12345})
    monkeypatch.setattr(os, "name", "nt", raising=False)

    # If taskkill isn't callable, we still should not crash.
    import subprocess

    def _boom(*args, **kwargs):
        raise FileNotFoundError("taskkill missing")

    monkeypatch.setattr(subprocess, "run", _boom)
    pr.kill_all_best_effort()
