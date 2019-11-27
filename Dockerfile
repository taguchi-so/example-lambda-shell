FROM lambci/lambda

ENV HOME /tmp
ENV PATH $HOME/.local/bin:$PATH

RUN cd /tmp && \
  curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
  python get-pip.py --user && \
  pip install awscli --user
