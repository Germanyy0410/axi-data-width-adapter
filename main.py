import os
import zipfile
import base64

def compress_and_encode(directory, output_filename="encoded_data.b64"):
    # Compress the directory into a .zip file
    zip_filename = "compressed_data.zip"
    with zipfile.ZipFile(zip_filename, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                # Add files to the zip file with relative path
                zipf.write(file_path, os.path.relpath(file_path, directory))

    # Encode the .zip file to base64
    with open(zip_filename, "rb") as zip_file:
        encoded_data = base64.b64encode(zip_file.read())

    # Write the base64 encoded data to a file
    with open(output_filename, "wb") as encoded_file:
        encoded_file.write(encoded_data)

    # Remove the temporary zip file
    os.remove(zip_filename)
    print(f"Directory encoded successfully into {output_filename}")


def decode_and_extract(encoded_filename="encoded_data.b64", output_directory="decoded_data"):
    # Read the base64 encoded data
    with open(encoded_filename, "rb") as encoded_file:
        encoded_data = encoded_file.read()

    # Decode the base64 data back to zip
    zip_filename = "decoded_data.zip"
    with open(zip_filename, "wb") as zip_file:
        zip_file.write(base64.b64decode(encoded_data))

    # Extract the zip file to the output directory
    with zipfile.ZipFile(zip_filename, "r") as zipf:
        zipf.extractall(output_directory)

    # Clean up the temporary zip file
    os.remove(zip_filename)
    print(f"Data decoded and extracted to {output_directory}")

# Example usage:
# Encode current directory
compress_and_encode(".")

# Decode to restore files
decode_and_extract()
