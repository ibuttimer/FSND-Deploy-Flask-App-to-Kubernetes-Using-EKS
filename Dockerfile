FROM python:3.7.10-stretch

ENV WORKDIR=/app/

COPY main.py requirements.txt ${WORKDIR}
COPY test/test_main.py requirements.txt ${WORKDIR}test/
WORKDIR ${WORKDIR}

RUN pip install --upgrade pip
RUN pip install -r requirements.txt


ENTRYPOINT ["gunicorn", "-b", ":8080", "main:APP"]

