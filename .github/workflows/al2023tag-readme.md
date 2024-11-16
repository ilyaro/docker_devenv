Creating the image from new base: Algorithm Overview
Check Amazon Linux 2023 Tag Date:

Fetch the latest tag date from Docker Hub for amazonlinux:2023.
Save this date (epoch format) as a new Git tag (al2023-<epoch_date>).
Handle Version Tags (v*):

After successfully creating a v* tag for your image, attach the corresponding al2023-<epoch_date> tag to the same commit.
Build Decision Logic:

When building a new image, check the amazonlinux:2023 tag date from Docker Hub.
Determine if the corresponding al2023-<epoch_date> tag exists in your Git repository.
If it exists: Build from your self-managed latest image.
If it doesn’t exist: Build a new image using the updated Amazon Linux 2023 tag as the base and add your tools.
Push Results:

Push new images and tags to your Docker registry and Git repository.
