docker build -t loyalty-api .
az acr login --name acrloyaltydev145303
docker tag loyalty-api acrloyaltydev145303.azurecr.io/loyalty-api:v1
docker push acrloyaltydev145303.azurecr.io/loyalty-api:v1
