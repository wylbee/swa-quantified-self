import os
import tempfile
from infer_date_from_filename import infer_date_from_filename
from unzip_file import unzip_file
from load_loop_habit import load_loop_habit
from archive_gcs_to_gcs import archive_gcs_to_gcs
from download_gcs_to_local import download_gcs_to_local


def extract_gcs_load_gcs(event, context):

    # set local filepaths
    tmpdir = tempfile.gettempdir()
    zip_destination_path = f"{tmpdir}/new_file.zip"
    unizp_destination_path = f"{tmpdir}/dump"
    processed_destination_path = f"{tmpdir}/clean"

    # infer project string
    event_bucket = event["bucket"]
    project_index = event_bucket.rfind("-")
    gcp_project = event_bucket[0:project_index]

    # get filename
    blob_file_name = event["name"]

    # download local copy of triggering file
    download_gcs_to_local(
        source_bucket=f"{gcp_project}-landing",
        blob_file_name=blob_file_name,
        destination_path=zip_destination_path,
    )

    # unzip locally
    unzip_file(zip_destination_path, unizp_destination_path)

    # infer date from filename
    source_uri = os.path.join("gs://", event_bucket, blob_file_name)
    inferred_date = infer_date_from_filename(source_uri)

    # load file in correct format
    load_loop_habit(
        unizp_destination_path, processed_destination_path, inferred_date, gcp_project
    )

    # archive & clear landing
    archive_gcs_to_gcs(
        source_bucket_name=event_bucket,
        destination_bucket_name=f"{gcp_project}-archive",
        blob_file_name=blob_file_name,
    )
