# Use an NVIDIA L4T CUDA runtime for ARM architecture
FROM nvcr.io/nvidia/l4t-cuda:11.4.19-runtime

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    python3-pip \
    libopenblas-dev \
    libcudnn8 \
    libcudnn8-dev \
    && rm -rf /var/lib/apt/lists/*


# Install Miniconda (ARM-compatible) and set up Conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda init && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

# Set Conda path
ENV PATH="/opt/conda/bin:$PATH"

# Copy the Conda environment file into the container
COPY j40_conda_environment.yml /app/environment.yml

# Install the Conda environment
RUN /opt/conda/bin/conda env create -f /app/environment.yml

# Copy project files
COPY PycharmProjects/testModel1 /app/testModel1

# Activate the Conda environment and install PyTorch for Jetson platform
RUN /bin/bash -c "source activate modelenv && python3 -m pip install --no-cache-dir https://developer.download.nvidia.com/compute/redist/jp/v50/pytorch/torch-1.12.0a0+2c916ef.nv22.3-cp38-cp38-linux_aarch64.whl"

# Set the working directory to the project folder
WORKDIR /app/testModel1

# Final command to activate the environment and start the script
CMD ["/bin/bash", "-c", "source activate modelenv && exec python3 test.py"]
