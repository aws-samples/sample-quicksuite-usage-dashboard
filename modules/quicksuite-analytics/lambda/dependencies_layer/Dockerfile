FROM public.ecr.aws/lambda/python:3.14-arm64

COPY requirements.txt .
RUN pip install -r requirements.txt -t /opt/python --no-cache-dir

# Output: /opt/python/ contains the installed packages
