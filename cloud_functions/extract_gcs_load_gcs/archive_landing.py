from gcloud import storage


def archive_landing(
    source_bucket_name: str, destination_bucket_name: str, blob_file_name: str
):
    storage_client = storage.Client()
    source_bucket = storage_client.get_bucket(source_bucket_name)
    source_blob_file = storage_client.blob(blob_file_name)
    destination_bucket = storage_client.get_bucket(destination_bucket_name)

    # copy to new
    source_bucket.copy_blob(source_blob_file, destination_bucket, blob_file_name)

    # delete from old
    source_blob_file.delete()
