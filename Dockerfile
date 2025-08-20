# Simple image to replace the one used for the 'Deploy prod' stage

# Create this image from this existing docker image, we never start from scratch
FROM mcr.microsoft.com/playwright:v1.49.1-noble

# RUN is a command that runs when the image is being built
RUN npm install -g netlify-cli@20.1.1 node-jq