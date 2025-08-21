# Simple image to replace the one used for the 'Deploy prod' stage

# Create this image from this existing docker image, we never start from scratch
FROM mcr.microsoft.com/playwright:v1.49.1-noble

# RUN is a command that runs during the build process of the image
RUN npm install -g netlify-cli@20.1.1 serve

# The image we are using above (noble) is a version of ubuntu, so we can also use linux commands
RUN apt update
RUN apt install jq -y
