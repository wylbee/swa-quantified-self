import zipfile


def unzip_file(source_path: str, destination_path: str):
    zip_file = zipfile.ZipFile(source_path, "r")
    zip_file.extractall(destination_path)
