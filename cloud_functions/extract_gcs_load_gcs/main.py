import os
import tempfile
from gcloud import storage
from infer_date_from_filename import infer_date_from_filename
from unzip_file import unzip_file
from load_loop_habit import load_loop_habit
from archive_landing import archive_landing


def extract_gcs_load_gcs(event, context):

    # set local filepaths
    tmpdir = tempfile.gettempdir()
    source_path = f"{tmpdir}/new_file.zip"
    unizp_destination_path = f"{tmpdir}/dump"
    processed_destination_path = f"{tmpdir}/clean"

    # infer project string
    event_bucket = event["bucket"]
    project_index = event_bucket.rfind("-")
    gcp_project = event_bucket[0:project_index]

    # get filename
    blob_file_name = event["name"]

    # download local copy of triggering file
    client = storage.Client()
    bucket = client.bucket(f"{gcp_project}-landing")
    blob = bucket.blob(blob_file_name)
    blob.download_to_filename(source_path)

    # unzip locally
    unzip_file(source_path, unizp_destination_path)

    # infer date from filename
    source_uri = os.path.join("gs://", event_bucket, blob_file_name)
    inferred_date = infer_date_from_filename(source_uri)

    # load file in correct format
    load_loop_habit(
        unizp_destination_path, processed_destination_path, inferred_date, gcp_project
    )

    # archive & clear landing
    archive_landing(
        source_bucket_name=event_bucket,
        destination_bucket_name=f"{gcp_project}-archive",
        blob_file_name=blob_file_name,
    )
