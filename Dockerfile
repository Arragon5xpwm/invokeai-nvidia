FROM python:3.11
ARG VERSION
#ARG TOKEN
ENV HUGGING_FACE_HUB_TOKEN="<your token>"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV GPU_FLAGS=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV USER_ID=99
ENV GROUP_ID=100

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 --no-install-recommends -y libgl1 libglib2.0-0 libgl1-mesa-glx libsm6 libxext6 libxrender1 python-is-python3 python3-venv build-essential python3-opencv libopencv-dev sudo && \
    apt-get clean
RUN useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash invokeai
# Set the INVOKEAI_ROOT directory
ENV INVOKEAI_ROOT=/InvokeAI
# Create the directory and switch ownership to the new user
RUN mkdir -p $INVOKEAI_ROOT && chown $USER_ID:$GROUP_ID $INVOKEAI_ROOT
ENV VIRTUAL_ENV=/opt/invokeai_venv
RUN mkdir -p $VIRTUAL_ENV && chown $USER_ID:$GROUP_ID $INVOKEAI_ROOT
# Set the workdir and switch to the new user
WORKDIR $INVOKEAI_ROOT
USER invokeai

# Set up the virtual environment
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python dependencies
RUN python -m pip install --upgrade pip
RUN pip install --pre InvokeAI[xformers]$VERSION --use-pep517 --extra-index-url https://download.pytorch.org/whl/cu121

#VOLUME /InvokeAI
# Expose the port
EXPOSE 9090/tcp

# Set the default command to run as the non-root user
CMD ["sudo", "-u", $USER_ID, "-g", $GROUP_ID, "invokeai-web"]
