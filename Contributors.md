# Contributors Guide

This guide provides an overview of the GitHub Actions workflows used in this repository and instructions on how to contribute to the project.

## Workflows

### 1. Docker Image CI

**File:** [`.github/workflows/docker-image.yml`](.github/workflows/docker-image.yml)

**Purpose:** This workflow builds and pushes Docker images to Docker Hub whenever a new tag starting with `v` is pushed to the git repository.

**Triggers:**
- Push events with git tags matching `v*`.

**Jobs:**
- **build:** This job runs on `ubuntu-latest` and performs the following steps:
  - Checks out the code.
  - Sets up Docker Buildx.
  - Logs in to Docker Hub using secrets.
  - Builds and pushes the Docker image defined in `Dockerfiles/Dockerfile_amazonlinux_2023` to Docker Hub with the tag that was pushed.
  - Scans the image for vulnerabilities.

### 2. Tag Docker Image as Latest

**File:** [`.github/workflows/tag-latest-image.yml`](.github/workflows/tag-latest-image.yml)

**Purpose:** This workflow tags a Docker image as `latest` on Docker Hub whenever a `latest` git tag is pushed to the repository to the same commit as v.0.* tag.
This creates `latest` dockerhub tag to the same tag as of v.0* points to

**Triggers:**
- Push events with the `latest` tag.
- Manual dispatch via the GitHub Actions interface.

**Jobs:**
- **tag-latest:** This job runs on `ubuntu-latest` and performs the following steps:
  - Retrieves the first `v*` tag on the same commit where the `latest` tag is set.
  - Sets up Docker Buildx.
  - Logs in to Docker Hub using secrets.
  - Creates a `latest` tag for the Docker image on Docker Hub.

## Contribution Guidelines

1. **Fork the Repository:** Create a fork of the repository to your GitHub account.
2. **Clone the Repository:** Clone your forked repository to your local machine.
3. **Create a Branch:** Create a new branch for your feature or bug fix.
4. **Make Changes:** Implement your changes in the appropriate files.
5. **Commit Changes:** Commit your changes with a descriptive commit message.
6. **Push Changes:** Push your changes to your forked repository.
7. **Create a Pull Request:** Open a pull request to merge your changes into the main repository.

## Triggering Workflows

To trigger the Docker image build and tagging workflows, follow these steps:

1. **Push a Version Tag:**
   - Create and push a tag that starts with `v` (e.g., `v0.0.1`) to trigger the Docker image build workflow.
   - Example:
     ```sh
     git tag v0.0.1
     git push origin v0.0.1
     ```

2. **Push the Latest Tag:**
   - After the Docker image build is successful, create and push a `latest` tag to the same commit as the `v*` tag to trigger the latest Docker Hub tag creation workflow.
   - Example:
     ```sh
     git tag latest v.0.0.1
     git push origin latest -f
     ```

## Contact

If you have any questions or need further assistance, please open an issue in the repository.

Thank you for contributing!:w
