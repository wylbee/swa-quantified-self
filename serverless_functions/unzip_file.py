# %%
import zipfile

def unzip_file(source_path: str, destination_path: str):
    zip_file = zipfile.ZipFile(source_path, 'r')
    zip_file.extractall(destination_path)

# %%
unzip_file('/home/brown5628/repos/sandbox/load/Loop Habits CSV 2022-06-12.zip', '/home/brown5628/repos/sandbox/raw/tmp')
# %%
