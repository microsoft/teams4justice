
```
az login
```


```
az ad app show --id 98328d53-55ec-4f14-8407-0ca5ff2f2d20
```

```
.\create_app_registrations.ps1 "7ff95b15-dc21-4ba6-bc92-824856578fc1" "madcoolsecret"
```

groups
```
az ad sp update --id [ID] --set appRoleAssignmentRequired=true
```



# Links

https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest

https://docs.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest#az-ad-app-create

https://www.vrdmn.com/2018/08/create-azure-ad-app-registration-with.html

https://www.frodehus.dev/add-scopes-to-azure-ad-via-azure-cli/

https://anmock.blog/2020/01/10/azure-cli-create-an-azure-ad-application-for-an-api-that-exposes-oauth2-permissions/

https://joonasw.net/view/defining-permissions-and-roles-in-aad

https://docs.microsoft.com/en-us/cli/azure/ad/group?view=azure-cli-latest#az-ad-group-create

https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/assign-user-or-group-access-portal

https://docs.microsoft.com/en-us/graph/api/resources/application?view=graph-rest-1.0

https://winsmarts.com/update-azure-ad-applications-signinaudience-using-microsoft-graph-79b5af3ec901

https://developer.microsoft.com/graph/graph-explorer