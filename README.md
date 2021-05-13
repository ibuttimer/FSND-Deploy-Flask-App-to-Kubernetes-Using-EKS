# Deploying a Flask API

This is the project starter repo for the fourth course in the [Udacity Full Stack Nanodegree](https://www.udacity.com/course/full-stack-web-developer-nanodegree--nd004): Server Deployment, Containerization, and Testing.

In this project you will containerize and deploy a Flask API to a Kubernetes cluster using Docker, AWS EKS, CodePipeline, and CodeBuild.

The Flask app that will be used for this project consists of a simple API with three endpoints:

- `GET '/'`: This is a simple health check, which returns the response 'Healthy'. 
- `POST '/auth'`: This takes a email and password as json arguments and returns a JWT based on a custom secret.
- `GET '/contents'`: This requires a valid JWT, and returns the un-encrypted contents of that token. 

The app relies on a secret set as the environment variable `JWT_SECRET` to produce a JWT. The built-in Flask server is adequate for local development, but not production, so you will be using the production-ready [Gunicorn](https://gunicorn.org/) server when deploying the app.

## Initial setup
1. Fork this project to your Github account.
2. Locally clone your forked version to begin working on the project.

## Dependencies

- Python 3.9
    - Follow instructions to install the latest version of python for your platform in the [python docs](https://docs.python.org/3/using/unix.html#getting-and-installing-the-latest-version-of-python)
- Docker Engine
    - Installation instructions for all OSes can be found [here](https://docs.docker.com/install/).
    - For Mac users, if you have no previous Docker Toolbox installation, you can install Docker Desktop for Mac. If you already have a Docker Toolbox installation, please read [this](https://docs.docker.com/docker-for-mac/docker-toolbox/) before installing.
 - AWS Account
     - You can create an AWS account by signing up [here](https://aws.amazon.com/#).
     
## Project Steps

Completing the project involves several steps:

1. Write a Dockerfile for a simple Flask API
2. Build and test the container locally
3. Create an EKS cluster
4. Store a secret using AWS Parameter Store
5. Create a CodePipeline pipeline triggered by GitHub checkins
6. Create a CodeBuild stage which will build, test, and deploy your code

For more detail about each of these steps, see the project lesson [here](https://classroom.udacity.com/nanodegrees/nd004/parts/1d842ebf-5b10-4749-9e5e-ef28fe98f173/modules/ac13842f-c841-4c1a-b284-b47899f4613d/lessons/becb2dac-c108-4143-8f6c-11b30413e28d/concepts/092cdb35-28f7-4145-b6e6-6278b8dd7527).


## Implementation
### Setup
#### Virtual Environment
It is recommended that a virtual environment be used for development purposes.
Please see [Creating a virtual environment](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment) for details.

>**Note:** The following instructions are intended to be executed from a terminal window in the project folder,
> in which the [virtual environment is activated](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#activating-a-virtual-environment).

#### Install dependencies
Run the following command:
````shell
> pip3 install -r requirements.txt
````
Also see [Using requirements files](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#using-requirements-files).

#### Configuration
The application utilises a secret when generating a JSON Web Token. This may be configured by setting the
`JWT_SECRET` environment variable.
```bash
For Linux and Mac:                            For Windows:
$ export JWT_SECRET=JWTencodeSecret           > set JWT_SECRET=JWTencodeSecret
```
In addition, the application log level may be configured by setting the `LOG_LEVEL` environment variable. 
The default level is `INFO`. See [Logging Levels](https://docs.python.org/3.9/library/logging.html#logging-levels) for valid settings.
```bash
For Linux and Mac:                            For Windows:
$ export LOG_LEVEL=DEBUG                      > set LOG_LEVEL=DEBUG
```
### Run the application
The application may be run using the `flask` command or directly by running the script.
#### Run using script
From a terminal window in the project folder, run the following commands:
From a terminal window in the `backend` folder, run the following commands:
```bash
For Linux and Mac:                            For Windows:
$ cd /path/to/project                         > cd \path\to\project
$ export PYTHONPATH=/path/to/project          > set PYTHONPATH=/path/to/project
$ python main.py                              > python main.py
```
The application will be available at http://localhost:8080/.

#### Run using `flask`
From a terminal window in the project folder, run the following commands:
```bash
For Linux and Mac:                     For Windows:
$ export FLASK_APP=main                > set FLASK_APP=main
$ export FLASK_ENV=development         > set FLASK_ENV=development
$ flask run                            > flask run
```
See [Run The Application](https://flask.palletsprojects.com/en/1.1.x/tutorial/factory/#run-the-application) for other operating systems.

The application will be available at http://localhost:5000/.


### Test
#### pytest
The [pytest](https://docs.pytest.org/) framework is used to provide test functionality.  
From a terminal window, run the following commands to set the `PYTHONPATH` environment variable, and run the script:
```bash
For Linux and Mac:                            For Windows:
$ cd /path/to/project/test                    > cd \path\to\project\test
$ export PYTHONPATH=/path/to/project          > set PYTHONPATH=/path/to/project
$ pytest test_main.py                         > pytest test_main.py
```
#### curl
Alternatively, [curl](https://curl.se/) may be used to do some basic testing 
```bash
$ curl  http://localhost:8080/
"Healthy"

$ curl -d '{"email": "abc@xyz.com", "password":"shhh!"}' -H 'Content-Type: application/json' http://localhost:8080/auth
{
  "token": "Header.Payload.Signature"
}

$ curl -H "Authorization: Header.Payload.Signature"  http://localhost:8080/contents
{
  "email": "a@b.com",
  "exp": 1621941570,
  "nbf": 1620731970
}
```
The command-line JSON processor [jq](https://stedolan.github.io/jq/) may also be used to simplify the process. 
Refer to [Download jq](https://stedolan.github.io/jq/download/) for installation instruction for different OS.
```bash
$ export TOKEN=`curl --data '{"email":"abc@xyz.com","password":"shhh!"}' --header "Content-Type: application/json" -X POST localhost:8080/auth  | jq -r '.token'`
auth  | jq -r '.token'`
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   217  100   175  100    42    175     42  0:00:01 --:--:--  0:00:01   923
$ curl --request GET 'http://localhost:5000/contents' -H "Authorization: Bearer ${TOKEN}" | jq .
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    73  100    73    0     0     73      0  0:00:01 --:--:--  0:00:01   333
{
  "email": "abc@xyz.com",
  "exp": 1621969631,
  "nbf": 1620760031
}
```


