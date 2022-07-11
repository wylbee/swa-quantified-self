# %%
import os
import shutil
from gcloud import storage


def load_loop_habit(
    source_path: str, destination_path: str, partition_date: str, gcp_project: str
):

    # get file list
    file_list = []
    for (dirpath, dirnames, filenames) in os.walk(source_path):
        file_list += [os.path.join(dirpath, file) for file in filenames]

    # parse info from file names
    id_list = []
    for file in range(len(file_list)):
        file_name = file_list[file]
        habit_description = file_name.split("/")[-2]
        file_type = file_name.split("/")[-1].split(".")[0]
        id_start = habit_description.find("LH")
        id_habit = habit_description[id_start:]
        if "Habits" in file_type:
            id_habit = "Habits"
        id_list.append([file_name, id_habit, file_type])

    # upload file to GCS
    for item in id_list:
        # create directory strings
        folder_structure = f"{item[2]}/dt_processed={partition_date}/"
        destination_directory = f"{destination_path}/{folder_structure}"
        destination_filename = f"{item[1]}.csv"
        destination_filepath = f"{destination_directory}{destination_filename}"
        destinaton_folder_file = f"loop_habits/{folder_structure}{destination_filename}"

        # Skip habits with no id
        if "Habits" not in item[2] and "LH" not in item[1]:
            continue

        # Ensure new directory exists, then copy
        os.makedirs(os.path.dirname(destination_directory), exist_ok=True)
        shutil.copy(item[0], destination_filepath)

        # Upload file to GCS
        client = storage.Client()
        bucket = client.get_bucket(f"{gcp_project}-raw")
        blob = bucket.blob(destination_filepath)
        blob.upload_from_filename(destination_filepath)
        bucket.rename_blob(blob, destinaton_folder_file)
