docker build -t cards-api .
az acr login --name imageregistryaderkz
docker tag cards-api imageregistryaderkz.azurecr.io/cards-api:latest
docker push imageregistryaderkz.azurecr.io/cards-api:latest
