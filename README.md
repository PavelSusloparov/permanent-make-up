# permanent-make-up

Bootstrap for the multi tier permanent-make-up project.

Project [link](https://permanent-make-up.appspot.com/)

## Local run

Run frontend locally:

```
In separate console tab:
cd frontend
./run.sh
```

Start local MySQL:
```
docker-compose up
```

Run service locally:
```
In separate console tab:
cd service
./run-local.sh
```

Run service against cloud database:
Upload project editor service account to ~/google/permanent-make-up/project-editor.json
```
In separate console tab:
cd service
./run-cloud.sh
```

## Deployment

Deploy to app engine:
```
cd frontend
./deploy.sh
```

```
cd service
./deploy.sh
```
