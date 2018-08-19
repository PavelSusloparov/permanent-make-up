# permanent-make-up

Bootstrap for the multi tier permanent-make-up project.

Project [link](https://permanent-make-up.appspot.com/)

## Local run

Start local MySQL:
In a separate console tab - 
```
docker-compose up
```

Run eureka-service(Services discovery) locally:
In a separate console tab - 
```
cd eureka-service
./run.sh
```

Run admin-service locally:
In a separate console tab - 
```
cd admin-service
./run.sh
```

Run backend-service locally:
In a separate console tab - 
```
cd backend-service
./run-local.sh
```

Run frontend-service locally:
In a separate console tab - 
```
cd frontend-service
./run.sh
```

Run service against cloud database:
Upload project editor service account to ~/google/permanent-make-up/project-editor.json

In a separate console tab - 
```
cd backend-service
./run-cloud.sh
```

## Deployment

Deploy to app engine:
```
cd frontend-service
./deploy.sh
```

```
cd backend-service
./deploy.sh
```
