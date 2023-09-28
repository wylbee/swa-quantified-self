# ---
# cmd: ["modal", "run", "10_integrations.meltano.meltano_modal::extract_and_load"]
# ---
import os
import shutil
import subprocess
from pathlib import Path

import modal

LOCAL_PROJECT_ROOT = Path(__file__).parent / "meltano"
REMOTE_PROJECT_ROOT = "/meltano"
PERSISTED_VOLUME_PATH = "/persisted"
REMOTE_DB_PATH = Path(f"{PERSISTED_VOLUME_PATH}/meltano.db")
REMOTE_LOGS_PATH = Path(f"{REMOTE_PROJECT_ROOT}/.meltano/logs")
PERSISTED_LOGS_DIR = Path(f"{PERSISTED_VOLUME_PATH}/logs")

meltano_source_mount = modal.Mount.from_local_dir(
    LOCAL_PROJECT_ROOT,
    remote_path=REMOTE_PROJECT_ROOT,
    condition=lambda path: not any(p.startswith(".") for p in Path(path).parts),
)

storage = modal.NetworkFileSystem.persisted("meltano_volume")

meltano_conf = modal.Secret.from_dict(
    {
        "MELTANO_PROJECT_ROOT": REMOTE_PROJECT_ROOT,
        "MELTANO_DATABASE_URI": f"sqlite:///{REMOTE_DB_PATH}",
        "MELTANO_ENVIRONMENT": "prod",
    }
)


def install_project_deps():
    os.environ[
        "MELTANO_DATABASE_URI"
    ] = "sqlite:////.empty_meltano.db"  # dummy during installation
    subprocess.check_call(["meltano", "install"])
    # delete empty logs dir, so running containers can add a symlink instead
    shutil.rmtree(REMOTE_LOGS_PATH, ignore_errors=True)


meltano_img = (
    modal.Image.debian_slim()
    .apt_install("git")
    .pip_install("meltano[gcs]")
    .copy_mount(meltano_source_mount)
    .run_function(install_project_deps, secret=meltano_conf)
)


stub = modal.Stub(
    image=meltano_img,
    secrets=[meltano_conf],
)


def symlink_logs():
    # symlink logs so that they end up in persisted shared volume
    # we can get rid of this if meltano gets a way to configure
    # the logging directory
    if not REMOTE_LOGS_PATH.exists():
        PERSISTED_LOGS_DIR.mkdir(exist_ok=True, parents=True)
        REMOTE_LOGS_PATH.symlink_to(PERSISTED_LOGS_DIR)


# Run this example using `modal run meltano_modal.py::extract_and_load`
@stub.function(
    network_file_systems={PERSISTED_VOLUME_PATH: storage},
    schedule=modal.Period(days=1),
    secret=modal.Secret.from_name("TOGGL_API_KEY")
)
def extract_and_load():
    symlink_logs()
    subprocess.call(
        ["meltano", "run", "tap-toggl", "target-gcs"]
    )
