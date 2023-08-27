FROM python:3.11
ARG VERSION
ARG TOKEN
ENV HUGGING_FACE_HUB_TOKEN="<your token>"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV GPU_FLAGS=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 --no-install-recommends -y libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 python-is-python3 python3-venv build-essential python3-opencv libopencv-dev && \
    apt-get clean
ENV INVOKEAI_ROOT=/InvokeAI
RUN mkdir -p $INVOKEAI_ROOT
WORKDIR $INVOKEAI_ROOT
ENV VIRTUAL_ENV=/opt/invokeai_venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN python -m pip install --upgrade pip
RUN pip install InvokeAI[xformers]$VERSION --use-pep517 --extra-index-url https://download.pytorch.org/whl/cu118
RUN invokeai-configure -y --root=$TOKEN
VOLUME /InvokeAI
EXPOSE 9090/tcp
CMD ["invokeai", "--no-nsfw_checker","--web", "--host=0.0.0.0"]

