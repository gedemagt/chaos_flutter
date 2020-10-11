FROM python:3.7

RUN mkdir -p /server && mkdir -p /static

COPY . /server/

WORKDIR /server

RUN pip install -r requirements.txt

EXPOSE 5000:5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]