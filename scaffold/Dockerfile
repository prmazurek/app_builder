 FROM python:<python_version>

 ENV PYTHONUNBUFFERED 1
 ENV PYTHONDONTWRITEBYTECODE 1
 ENV PROJECT_NAME <project_name>
 
 RUN mkdir /app
 
 WORKDIR /app
 
 ADD requirements.txt /app/
 
 RUN pip install -r requirements.txt
 
 ADD . /app/