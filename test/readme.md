# Steps with registered app

1. create an app registration named `Terraform`/ None of the quids is actually the SP_ID
2. to get the SP_ID run `az ad sp list --display-name terraform` and then find the first guid of prop objectid and like 
   ```   
    "objectId": "6f8362b9-1930-4b6d-bc5d-59cdfe0e4bdb",
    "objectType": "ServicePrincipal",
    ```

## variations - tests