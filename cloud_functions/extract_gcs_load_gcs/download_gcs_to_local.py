from gcloud import storage


def download_gcs_to_local(
    source_bucket: str, blob_file_name: str, destination_path: str
):
    client = storage.Client()
    bucket = client.bucket(source_bucket)
    blob = bucket.blob(blob_file_name)
    blob.download_to_filename(destination_path)
