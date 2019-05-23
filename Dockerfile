FROM jupyter/minimal-notebook:c39518a3252f

COPY 368.yml /tmp/368.yml
RUN conda env create --file /tmp/368.yml
RUN mv /opt/conda/share/jupyter/kernels/python3 /opt/conda/share/jupyter/kernels/python368
COPY 368.json /opt/conda/share/jupyter/kernels/python368/kernel.json

RUN rm -rf /home/jovyan/work
RUN yes | pip install jupyterlab==1.0.0a3
COPY jupyter_notebook_config.py /etc/jupyter/
