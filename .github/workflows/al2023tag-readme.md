## Check AmazonLinux 2023 dockerhub tag date and save it as tag in git
- After each successfull v* tag check the al2023 tag date and push it as al2023-<epoch time> tag on same commit as v* tag
- When running docker buildx workflow check again docker al2023 epoch date and check if the tag al2023-<epoch time> exists
- If the tag exists build from self latest image
- If the tag doesn't exits means there is new version of Amazon Linux 2023, build image from new tag as base and addd all tools 
